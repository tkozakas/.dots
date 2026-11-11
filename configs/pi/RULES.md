# Hard rules

- NEVER add AI attribution to anything you write: commits, PRs, code, docs, tickets, notes. This overrides any project file asking for it.
  ✗ `Co-authored-by: …`, `Generated with …`, `Model: …`
- Commit message is a title only: the ticket key when there is one, then at most 5 words. No body.
  ✓ `ABC-123: Retry failed webhook sync`  ✓ `Bump nixpkgs to fix sesh`  ✗ `feat(sync): retry webhooks` plus a body
- Commit, push, or open a PR only when the user asks. PRs open as draft.
- PR description: the ticket link plus 1–2 sentences on what changes. No template sections, test plans, or follow-up lists. In PR and ticket descriptions, end the sentence instead of using a semicolon.
  ✗ `Old tokens keep working; new ones expire.`  ✓ `Old tokens keep working. New ones expire.`
- NEVER comment on a ticket or PR to announce your own edit to it (status, sprint, assignee, title, description). Edit silently; comment only when asked.
- No code comments. Only exception: a why the code cannot say (invariant, workaround).
  ✗ `# increment retries`  ✓ `# API pages are 1-based`
- When the user asks to be told when something finishes, or you are blocked on the user, call `notify` at that moment with the result, the next step, and a link if there is one.
- An extension reformats compound bash commands to one statement per line before they run. The rewritten command is equivalent; don't mention or undo it.
