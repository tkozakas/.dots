import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";

const TTL_MS = 55 * 60 * 1000;
const TICK_MS = 5000;
const ASK_MIN_TOKENS = 50_000;
const AUTO_COMPACT = false;

interface WatchState {
	lastRequestAt: number;
	asked: boolean;
	asking: boolean;
}

function fmt(ms: number): string {
	const s = Math.max(0, Math.round(ms / 1000));
	return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`;
}

export default function cacheTtl(pi: ExtensionAPI) {
	const state: WatchState = { lastRequestAt: 0, asked: false, asking: false };
	let ctx0: ExtensionContext | undefined;
	let timer: NodeJS.Timeout | undefined;

	function touch(ctx: ExtensionContext) {
		ctx0 = ctx;
		state.lastRequestAt = Date.now();
		state.asked = false;
	}

	function tokens(): number {
		const usage = ctx0?.getContextUsage();
		return usage?.tokens ?? 0;
	}

	async function offerCompact() {
		if (!ctx0 || state.asking || !ctx0.isIdle()) return;
		const tok = tokens();
		if (tok < ASK_MIN_TOKENS) return;
		state.asked = true;
		if (AUTO_COMPACT) {
			ctx0.ui.notify(`Prompt cache expired at ~${Math.round(tok / 1000)}k tokens — compacting`, "info");
			await ctx0.compact();
			return;
		}
		if (!ctx0.hasUI) return;
		state.asking = true;
		try {
			const yes = await ctx0.ui.confirm(
				"Prompt cache expired",
				`Context is ~${Math.round(tok / 1000)}k tokens and will be re-ingested at full cost. Compact now?`,
			);
			if (yes) await ctx0.compact();
		} finally {
			state.asking = false;
		}
	}

	function show(text: string) {
		if (ctx0?.hasUI) ctx0.ui.setStatus("cache-ttl", text);
	}

	function tick() {
		if (!ctx0 || state.lastRequestAt === 0) return;
		if (!ctx0.isIdle()) {
			state.lastRequestAt = Date.now();
			state.asked = false;
			show("cache ●");
			return;
		}
		const left = state.lastRequestAt + TTL_MS - Date.now();
		if (left > 0) {
			show(`cache ${left < 60_000 ? "◐" : "●"} ${fmt(left)}`);
		} else {
			show(`cache ○ ${fmt(-left)}`);
			if (!state.asked) void offerCompact();
		}
	}

	pi.on("session_start", async (_event, ctx) => {
		ctx0 = ctx;
		timer ??= setInterval(tick, TICK_MS);
	});

	pi.on("message_end", async (_event, ctx) => touch(ctx));
	pi.on("turn_end", async (_event, ctx) => {
		touch(ctx);
		tick();
	});

	pi.on("session_compact", async (_event, ctx) => touch(ctx));

	pi.on("session_shutdown", async () => {
		clearInterval(timer);
		timer = undefined;
	});

	pi.registerCommand("ttl", {
		description: "Show prompt-cache TTL state",
		handler: async (_args, ctx) => {
			ctx0 = ctx;
			if (state.lastRequestAt === 0) {
				ctx.ui.notify("No request yet this session — cache not warm", "info");
				return;
			}
			const left = state.lastRequestAt + TTL_MS - Date.now();
			const tok = Math.round(tokens() / 1000);
			ctx.ui.notify(
				left > 0
					? `Cache warm: ${fmt(left)} left (~${tok}k tokens cached)`
					: `Cache expired ${fmt(-left)} ago (~${tok}k tokens to re-ingest) — /compact to shrink`,
				left > 0 ? "info" : "warn",
			);
		},
	});
}
