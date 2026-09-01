<!-- BEGIN:nextjs-agent-rules -->

# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->

## Investing Agent frontend rules

- Use pnpm; do not create npm or yarn lockfiles.
- Use App Router conventions and read the installed Next.js guidance above.
- Add shadcn primitives with its CLI rather than copying component source from
  third-party examples.
- One provider owns the `/ws/live` connection. Components consume provider
  state and do not open independent sockets.
- Keep server state access in `src/services/`; do not duplicate fetch logic in
  presentation components.
- Generated API types in `src/types/generated/` are never hand-edited.
- Never calculate authoritative balances, risk approval, reward, or execution
  in the browser.
- Every async card/table needs a shape-matching skeleton, an error state, and an
  explanatory empty state.
- Mode, rule, version, strategy, and destructive actions require confirmation.
