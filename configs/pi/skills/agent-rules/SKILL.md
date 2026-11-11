---
name: agent-rules
description: Decides where an agent rule belongs (public ~/.dots or private ~/.dots-work) and words it to house style. Use when adding, editing, or reviewing RULES.md, AGENTS.md, rules/*.md, agents/*.md, or SKILL.md files.
---

# Agent rules

## Where it goes

| Rule | File | Repo |
|---|---|---|
| Holds in every session on every machine | `configs/pi/RULES.md` (sent on every request) | `~/.dots` (public) |
| Personal machine or setup fact | `configs/pi/AGENTS.md` | `~/.dots` |
| Employer-specific: company, repos, packages, classes, internal tools, tickets, people | `configs/pi/AGENTS.md` | `~/.dots-work` (private) |
| Matters only for some files or one codebase | `configs/pi/rules/<name>.md` | `~/.dots-work` |
| One agent's role and output | `configs/pi/agents/<agent>.md` | `~/.dots` |
| Procedure needed only sometimes | `configs/pi/skills/<name>/SKILL.md` | `~/.dots` |

In `~/.dots-work/configs/pi`, `RULES.md`, `agents/`, `skills/`, `extensions/`, and `themes/` are symlinks into `~/.dots`: writing there publishes it.

## House style

- `#` title naming the scope, `##` sections, bullets only. No prose paragraphs.
- One rule per bullet, imperative, at most 2 lines, checkable from the output.
- Say what to do, not only what to avoid. Add a ✗/✓ example when the rule is about code or text shape.
  ✗ `Handle errors properly.`  ✓ `Rescue the specific error class, never bare StandardError.`
- Boundaries read `Always:` / `Ask first:` / `Never:`.
- `NEVER`/`MUST` only where a miss causes damage: leaks, public posts, data loss.
- Say it once. Grep `RULES.md`, both `AGENTS.md`, `agents/`, and `rules/` first; sharpen the existing line instead of adding another.
- Leave out what the model does by default and what a linter enforces.
- Skill `description`: third person, what it does plus when to use it.
- Budgets, frontmatter excluded: `RULES.md` ≤ 10 bullets; `AGENTS.md`, agent files, and rule files ≤ 40 lines; `SKILL.md` ≤ 100 lines with details in `references/`, one level deep.

## Rule file templates

Listed by name and read on demand:

```markdown
---
description: <what it covers>
globs: ["**/*.rb"]
---
# <Scope>

## <Topic>
- <Do X>, not <Y>.
  ✗ `<bad>`  ✓ `<good>`
```

Fires when matching text is written (`interruptMode: never` delivers after the edit, `always` stops it):

```markdown
---
description: <what it catches>
condition: '<regex over the written text>'
scope: "tool:edit(*.rb), tool:write(*.rb)"
interruptMode: never
---
<One sentence: what was just written and what to do instead.>
```

Test: `omp ttsr test --rule <file> --source tool --path app/x.rb '<snippet>'`.

## Before saving to `~/.dots`

Read the diff as a stranger: anything that only makes sense at the employer moves to `~/.dots-work`.

Based on Anthropic's memory and skill-authoring docs, GitHub's agents.md study, and HumanLayer's CLAUDE.md guide.
