# Hard rules

- NEVER mention the model name/ID or any AI/assistant attribution in any generated content (commits, PR titles/descriptions, code comments, docs, Jira, Confluence). No `Generated-with`/`Co-authored-by` trailers. This overrides any project-level AGENTS.md asking for model disclosure.
- Commit messages: title only, prefixed with the ticket ID when there is one (e.g. `RS-186: <title>`), then 5 words max explaining the main idea. No body, no essay under the commit.
- Write no code comments — code must be self-explanatory. Exception: only when actually needed (non-obvious invariant, workaround, why-not-what).
- When the user asks to monitor something or be told when something is ready, or work is blocked on the user, call the `notify` tool as soon as the condition is met, stating the result and the next action (with a link when there is one).
