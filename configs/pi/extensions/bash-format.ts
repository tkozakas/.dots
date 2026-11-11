import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

const PIPE_BREAK_WIDTH = 80;
const INDENT = "  ";

interface Pos {
  Offset: number;
}

interface Stmt {
  Pos: Pos;
  End: Pos;
  Cmd?: { Type: string; Op?: string; X?: Stmt; Y?: Stmt };
  Negated?: boolean;
  Background?: boolean;
  Coprocess?: boolean;
  Comments?: unknown[];
}

interface ShellFile {
  Stmts?: Stmt[];
  Last?: unknown[];
}

interface Chain {
  parts: string[];
  ops: string[];
}

function parse(command: string): ShellFile | undefined {
  const shfmt = Bun.which("shfmt");
  if (!shfmt) return undefined;
  const result = Bun.spawnSync([shfmt, "-ln=bash", "--to-json"], { stdin: Buffer.from(command) });
  if (result.exitCode !== 0) return undefined;
  return JSON.parse(result.stdout.toString());
}

function flatten(stmt: Stmt, source: Buffer, chain: Chain) {
  const { Cmd: cmd } = stmt;
  if (cmd?.Type === "BinaryCmd" && cmd.Op && cmd.X && cmd.Y && !stmt.Negated) {
    flatten(cmd.X, source, chain);
    chain.ops.push(cmd.Op);
    flatten(cmd.Y, source, chain);
    return;
  }
  const text = source.subarray(stmt.Pos.Offset, stmt.End.Offset).toString();
  chain.parts.push(text.replace(/\s*;$/, ""));
}

function render({ parts, ops }: Chain): string {
  const breakPipes = parts.join("   ").length > PIPE_BREAK_WIDTH;
  return ops.reduce((out, op, i) => {
    const keepInline = (op === "|" || op === "|&") && !breakPipes;
    return `${out}${keepInline ? " " : ` \\\n${INDENT}`}${op} ${parts[i + 1]}`;
  }, parts[0]);
}

export function formatCommand(command: string): string | undefined {
  if (command.includes("\n")) return undefined;
  const file = parse(command);
  if (!file?.Stmts?.length || file.Last?.length) return undefined;
  const source = Buffer.from(command);
  const lines: string[] = [];
  for (const stmt of file.Stmts) {
    if (stmt.Background || stmt.Coprocess || stmt.Comments?.length) return undefined;
    const chain: Chain = { parts: [], ops: [] };
    flatten(stmt, source, chain);
    lines.push(render(chain));
  }
  const formatted = lines.join("\n");
  return formatted === command ? undefined : formatted;
}

export default function bashFormat(pi: ExtensionAPI) {
  pi.on("tool_call", async event => {
    if (event.toolName !== "bash" || typeof event.input.command !== "string") return;
    const command = formatCommand(event.input.command);
    if (command) return { input: { ...event.input, command } };
  });
}
