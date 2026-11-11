import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";

const TTL_MS = 55 * 60 * 1000;
const TICK_MS = 5000;

interface WatchState {
	lastRequestAt: number;
}

function fmt(ms: number): string {
	const s = Math.max(0, Math.round(ms / 1000));
	return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`;
}

export default function cacheTtl(pi: ExtensionAPI) {
	const state: WatchState = { lastRequestAt: 0 };
	let ctx0: ExtensionContext | undefined;
	let timer: NodeJS.Timeout | undefined;

	function touch(ctx: ExtensionContext) {
		ctx0 = ctx;
		state.lastRequestAt = Date.now();
	}

	function tokens(): number {
		const usage = ctx0?.getContextUsage();
		return usage?.tokens ?? 0;
	}

	function show(text: string) {
		if (ctx0?.hasUI) ctx0.ui.setStatus("cache-ttl", text);
	}

	function tick() {
		if (!ctx0 || state.lastRequestAt === 0) return;
		if (!ctx0.isIdle()) {
			state.lastRequestAt = Date.now();
			show("cache ●");
			return;
		}
		const left = state.lastRequestAt + TTL_MS - Date.now();
		show(left > 0 ? `cache ${left < 60_000 ? "◐" : "●"} ${fmt(left)}` : `cache ○ ${fmt(-left)}`);
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
					: `Cache expired ${fmt(-left)} ago (~${tok}k tokens to re-ingest)`,
				left > 0 ? "info" : "warn",
			);
		},
	});
}
