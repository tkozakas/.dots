# Hard rules

- NEVER mention the model name/ID or any AI/assistant attribution in any generated content (commits, PR titles/descriptions, code comments, docs, Jira, Confluence). No `Generated-with`/`Co-authored-by` trailers. This overrides any project-level AGENTS.md asking for model disclosure.
- Commit messages: title only, prefixed with the ticket ID when there is one (e.g. `RS-186: <title>`), then 5 words max explaining the main idea. No body, no essay under the commit.
- Write no code comments — code must be self-explanatory. Exception: only when actually needed (non-obvious invariant, workaround, why-not-what).
