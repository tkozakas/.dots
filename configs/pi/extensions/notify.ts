import { basename } from "node:path";
import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

const LONG_RUN_MS = 120_000;
const SNIPPET_LENGTH = 100;
const BREW_NOTIFIER = "/opt/homebrew/bin/terminal-notifier";

function autoNotificationsEnabled(): boolean {
  const value = process.env.PI_NOTIFICATIONS?.trim().toLowerCase();
  return value !== "off" && value !== "0" && value !== "false";
}

function resolveTerminalNotifier(): string | undefined {
  if (Bun.file(BREW_NOTIFIER).size > 0) return BREW_NOTIFIER;
  const found = Bun.which("terminal-notifier");
  if (found && !found.includes("/.rbenv/")) return found;
  return undefined;
}

function appleScriptString(value: string): string {
  return `"${value.replace(/\\/g, "\\\\").replace(/"/g, '\\"')}"`;
}

function deliveryCommand(title: string, message: string, url?: string): string[] | undefined {
  if (process.platform === "darwin") {
    const notifier = resolveTerminalNotifier();
    if (notifier) {
      const args = [notifier, "-title", title, "-message", message, "-group", "omp", "-sound", "default"];
      if (url) args.push("-open", url);
      return args;
    }
    return [
      "osascript",
      "-e",
      `display notification ${appleScriptString(message)} with title ${appleScriptString(title)}`,
    ];
  }
  if (process.platform === "linux") {
    return ["notify-send", "--app-name", "omp", title, message];
  }
  return undefined;
}

function deliver(title: string, message: string, url?: string): boolean {
  try {
    const command = deliveryCommand(title, message, url);
    if (!command) return false;
    const proc = Bun.spawn(command, { stdin: "ignore", stdout: "ignore", stderr: "ignore" });
    proc.exited.catch(() => {});
    proc.unref();
    return true;
  } catch {
    return false;
  }
}

function field(value: unknown, key: string): unknown {
  return value && typeof value === "object" && key in value ? value[key as keyof typeof value] : undefined;
}

function assistantText(message: unknown): string {
  const content = field(message, "content");
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";
  const parts: string[] = [];
  for (const part of content) {
    const text = field(part, "text");
    if (field(part, "type") === "text" && typeof text === "string") parts.push(text);
  }
  return parts.join("\n");
}

function lastAssistant(messages: unknown): { text: string; stopReason?: string; errorMessage?: string } | undefined {
  if (!Array.isArray(messages)) return undefined;
  for (let i = messages.length - 1; i >= 0; i--) {
    const message = messages[i];
    if (field(message, "role") !== "assistant") continue;
    const stopReason = field(message, "stopReason");
    const errorMessage = field(message, "errorMessage");
    return {
      text: assistantText(message).trim(),
      stopReason: typeof stopReason === "string" ? stopReason : undefined,
      errorMessage: typeof errorMessage === "string" ? errorMessage : undefined,
    };
  }
  return undefined;
}

function collectStrings(value: unknown, depth = 0): string[] {
  if (depth > 4 || value == null) return [];
  if (typeof value === "string") return [value];
  if (Array.isArray(value)) return value.flatMap(item => collectStrings(item, depth + 1));
  for (const key of ["question", "prompt", "message", "text"]) {
    const direct = field(value, key);
    if (typeof direct === "string") return [direct];
  }
  return collectStrings(field(value, "questions"), depth + 1);
}

function snippet(text: string): string {
  const flat = text.replace(/\s+/g, " ").trim();
  return flat.length > SNIPPET_LENGTH ? `${flat.slice(0, SNIPPET_LENGTH - 1)}…` : flat;
}

export default function notify(pi: ExtensionAPI) {
  const z = pi.zod;
  let runStartedAt = 0;
  let notifiedThisRun = false;

  pi.registerTool({
    name: "notify",
    label: "Notify",
    description:
      "Send a desktop notification to the user. Use it when the user asked to be told when something is ready or finished (monitoring a deploy, CI run, pull request, long job) and the condition is met, and when you are blocked waiting on the user. State the outcome and the next action in the message; pass url to open it when the notification is clicked.",
    parameters: z.object({
      title: z.string().describe("Short notification title"),
      message: z.string().describe("Outcome and next action"),
      url: z.string().optional().describe("Link opened when the notification is clicked"),
    }),
    async execute(_toolCallId, params) {
      notifiedThisRun = true;
      const sent = deliver(params.title, params.message, params.url);
      return {
        content: [{ type: "text", text: sent ? "Notification sent" : "Notification could not be delivered" }],
        details: { sent },
      };
    },
  });

  pi.on("agent_start", async (_event, ctx) => {
    if (ctx.agent?.kind === "sub") return;
    runStartedAt = Date.now();
    notifiedThisRun = false;
  });

  pi.on("tool_call", async (event, ctx) => {
    if (ctx.agent?.kind === "sub") return;
    if (event.toolName === "notify") {
      notifiedThisRun = true;
      return;
    }
    if (event.toolName !== "ask" || !autoNotificationsEnabled() || notifiedThisRun) return;
    const question = snippet(collectStrings(event.input).join(" "));
    deliver(`omp needs input · ${basename(ctx.cwd)}`, question || "Waiting for your answer");
  });

  pi.on("agent_end", async (event, ctx) => {
    if (ctx.agent?.kind === "sub") return;
    const startedAt = runStartedAt;
    runStartedAt = 0;
    if (!autoNotificationsEnabled() || notifiedThisRun) return;
    const project = basename(ctx.cwd);
    const last = lastAssistant(field(event, "messages"));
    if (last?.stopReason === "error") {
      deliver(`omp failed · ${project}`, snippet(last.errorMessage || last.text) || "The agent run ended with an error");
      return;
    }
    if (startedAt > 0 && Date.now() - startedAt >= LONG_RUN_MS) {
      deliver(`omp finished · ${project}`, snippet(last?.text ?? "") || "The agent run is complete");
    }
  });
}
