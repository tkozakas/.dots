import { appendFileSync, existsSync, mkdirSync, unlinkSync, writeFileSync } from "node:fs";
import { homedir, tmpdir } from "node:os";
import { dirname, join } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";

const VAULT = join(homedir(), "notes-work");
const MODEL = "anthropic/claude-sonnet-5-5";
const LOG = join(homedir(), ".omp/agent/logs/vault-notes.log");
const MIN_GAP_MS = 2 * 60 * 1000;
const MSG_CAP = 2000;
const ARGS_CAP = 300;
const DIGEST_CAP = 60_000;

interface Block {
	type?: string;
	text?: string;
	name?: string;
	arguments?: unknown;
}

interface DigestEntry {
	id: string;
	type: string;
	message?: {
		role?: string;
		content?: unknown;
		isError?: boolean;
		toolName?: string;
		command?: string;
	};
}

function clip(text: string, max: number): string {
	return text.length > max ? `${text.slice(0, max)}…` : text;
}

function blocks(content: unknown): Block[] {
	return Array.isArray(content) ? (content as Block[]) : [];
}

function textOf(content: unknown): string {
	if (typeof content === "string") return content;
	return blocks(content)
		.filter(b => b?.type === "text" && typeof b.text === "string")
		.map(b => b.text)
		.join("\n");
}

function renderEntry(entry: DigestEntry): string | undefined {
	const msg = entry.message;
	if (entry.type !== "message" || !msg) return undefined;
	switch (msg.role) {
		case "user": {
			const text = textOf(msg.content).trim();
			return text ? `### User\n${clip(text, MSG_CAP)}` : undefined;
		}
		case "assistant": {
			const parts: string[] = [];
			for (const block of blocks(msg.content)) {
				if (block?.type === "text" && block.text?.trim()) parts.push(block.text.trim());
				else if (block?.type === "toolCall") {
					parts.push(`→ ${block.name}(${clip(JSON.stringify(block.arguments ?? {}), ARGS_CAP)})`);
				}
			}
			return parts.length ? `### Assistant\n${clip(parts.join("\n"), MSG_CAP)}` : undefined;
		}
		case "toolResult":
			return msg.isError ? `### Tool error (${msg.toolName})\n${clip(textOf(msg.content).trim(), 300)}` : undefined;
		case "bashExecution":
			return `### Bash\n${clip(`$ ${msg.command ?? ""}`, MSG_CAP)}`;
		default:
			return undefined;
	}
}

function gitBranch(cwd: string): string {
	try {
		const res = Bun.spawnSync(["git", "-C", cwd, "branch", "--show-current"], { stdout: "pipe", stderr: "ignore" });
		return res.exitCode === 0 ? res.stdout.toString().trim() : "";
	} catch {
		return "";
	}
}

function prompt(digestPath: string): string {
	return `Read the session digest file at ${digestPath}. It describes recent work done in a coding session.

Update this Obsidian vault (the current working directory) following its existing conventions:

- Ticket work goes in \`vinted/more/tickets/<TICKET>/<TICKET> <Short title>.md\`. Ticket ids look like NW-1234 or RS-186 and are found in branch names, prompts, PRs. Such notes start with \`# <TICKET> <Title>\`, then a line \`Ticket: https://vinted.atlassian.net/browse/<TICKET>\`, and use [[wikilinks]] between related notes.
- Reuse and extend existing notes (grep the vault first) instead of creating duplicates.
- Always keep a daily log \`vinted/more/worklog/YYYY-MM-DD.md\` (date from the digest header) with one \`## <project/repo> — <branch or topic>\` section per workstream, updated in place: what was done, decisions, PRs/links, open next steps. Concise bullets.
- If the digest has nothing work-relevant (chit-chat, trivial Q&A), change nothing.

Rules:
- Never write secrets, tokens, or passwords.
- Never touch \`.obsidian/\`.
- Never run git commit or git push.
- Never modify unrelated content in other files.
- Never mention AI, assistants, or models in notes.
- Write in English.`;
}

export default function vaultNotes(pi: ExtensionAPI) {
	let lastEntryId: string | undefined;
	let lastSyncAt = 0;
	let running = false;
	let pending = false;
	let stopped = false;
	let seq = 0;
	let latestCtx: ExtensionContext | undefined;

	mkdirSync(dirname(LOG), { recursive: true });

	function buildDigest(ctx: ExtensionContext): string | undefined {
		const branch = ctx.sessionManager.getBranch() as unknown as DigestEntry[];
		const start = lastEntryId ? branch.findIndex(e => e.id === lastEntryId) + 1 : 0;
		const fresh = branch.slice(start);
		if (fresh.length === 0) return undefined;
		lastEntryId = fresh[fresh.length - 1].id;
		const body = fresh.map(renderEntry).filter(Boolean).join("\n\n");
		if (!body) return undefined;
		const sm = ctx.sessionManager as { getSessionFile?: () => string | undefined };
		const header = [
			"# Session digest",
			`Date: ${new Date().toISOString().slice(0, 10)}`,
			`Cwd: ${ctx.cwd}`,
			`Git branch: ${gitBranch(ctx.cwd) || "(none)"}`,
			`Session file: ${sm.getSessionFile?.() ?? "(none)"}`,
			`Session title: ${pi.getSessionName() ?? "(none)"}`,
		].join("\n");
		const tail = body.length > DIGEST_CAP ? `…${body.slice(-DIGEST_CAP)}` : body;
		return `${header}\n\n${tail}\n`;
	}

	function run(ctx: ExtensionContext, force: boolean) {
		if (stopped || !existsSync(VAULT)) return;
		if (running) {
			pending = true;
			latestCtx = ctx;
			return;
		}
		if (!force && Date.now() - lastSyncAt < MIN_GAP_MS) return;
		const digest = buildDigest(ctx);
		if (!digest) return;

		const digestPath = join(tmpdir(), `vault-notes-${process.pid}-${++seq}.md`);
		writeFileSync(digestPath, digest);
		appendFileSync(LOG, `\n=== ${new Date().toISOString()} sync ${digestPath} (cwd ${ctx.cwd}) ===\n`);

		running = true;
		lastSyncAt = Date.now();
		if (ctx.hasUI) ctx.ui.setStatus("vault-notes", "notes ✎");

		const child = Bun.spawn(
			[
				"omp", "-p", "--model", MODEL, "--thinking", "low", "--no-session", "--no-extensions",
				"--tools", "read,write,edit,grep,glob,bash", "--cwd", VAULT, prompt(digestPath),
			],
			{
				cwd: VAULT,
				env: { ...process.env, OMP_VAULT_NOTES_CHILD: "1" },
				stdin: "ignore",
				stdout: "pipe",
				stderr: "pipe",
			},
		);

		const pump = async (stream: ReadableStream<Uint8Array>) => {
			const decoder = new TextDecoder();
			for await (const chunk of stream) appendFileSync(LOG, decoder.decode(chunk, { stream: true }));
		};

		void Promise.all([pump(child.stdout), pump(child.stderr), child.exited])
			.then(([, , code]) => {
				appendFileSync(LOG, `=== exit ${code} ===\n`);
				if (code !== 0 && ctx.hasUI && !stopped) ctx.ui.notify(`vault-notes failed, see ${LOG}`, "error");
			})
			.catch(err => {
				try {
					appendFileSync(LOG, `=== error ${String(err)} ===\n`);
				} catch {}
			})
			.finally(() => {
				try {
					unlinkSync(digestPath);
				} catch {}
				running = false;
				if (!stopped && ctx.hasUI) ctx.ui.setStatus("vault-notes", undefined);
				if (pending && latestCtx) {
					pending = false;
					const next = latestCtx;
					latestCtx = undefined;
					try {
						run(next, true);
					} catch {}
				}
			});
	}

	pi.on("agent_end", async (_event, ctx) => {
		if (process.env.OMP_VAULT_NOTES_CHILD || !ctx.hasUI) return;
		try {
			run(ctx, false);
		} catch (err) {
			appendFileSync(LOG, `=== schedule error ${String(err)} ===\n`);
		}
	});

	pi.on("session_shutdown", async () => {
		stopped = true;
		pending = false;
	});

	pi.registerCommand("vault-notes", {
		description: "Sync session notes into the Obsidian work vault now",
		handler: async (_args, ctx) => {
			if (process.env.OMP_VAULT_NOTES_CHILD) return;
			run(ctx, true);
			ctx.ui.notify(`vault-notes sync requested, log: ${LOG}`, "info");
		},
	});
}
