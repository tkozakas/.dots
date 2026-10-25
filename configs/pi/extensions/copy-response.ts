import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

function assistantText(message: unknown): string {
  if (!message || typeof message !== "object") return "";
  if (!("role" in message) || message.role !== "assistant") return "";
  if (!("content" in message)) return "";
  const content = message.content;
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";
  const parts: string[] = [];
  for (const part of content) {
    if (
      part &&
      typeof part === "object" &&
      "type" in part &&
      part.type === "text" &&
      "text" in part &&
      typeof part.text === "string"
    ) {
      parts.push(part.text);
    }
  }
  return parts.join("\n");
}

export default function copyResponse(pi: ExtensionAPI) {
  pi.registerCommand("copy", {
    description: "Copy the last assistant response to the clipboard (clean text)",
    handler: async (_args, ctx) => {
      let text = "";
      for (const entry of ctx.sessionManager.getBranch()) {
        if (
          entry &&
          typeof entry === "object" &&
          "type" in entry &&
          entry.type === "message" &&
          "message" in entry
        ) {
          const candidate = assistantText(entry.message);
          if (candidate.trim()) text = candidate;
        }
      }
      if (!text) {
        ctx.ui.notify("No assistant response to copy", "warn");
        return;
      }
      const proc = Bun.spawn(["pbcopy"], { stdin: "pipe" });
      proc.stdin.write(text);
      await proc.stdin.end();
      await proc.exited;
      ctx.ui.notify(`Copied ${text.length} chars to clipboard`, "info");
    },
  });
}
