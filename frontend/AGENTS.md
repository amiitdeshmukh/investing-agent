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

## Required context

Before frontend work, read `../PROJECT.md`, `../docs/product-and-ui.md`,
`../docs/api-contract.md`, and `../docs/architecture.md`. For the installed
Next.js version, read the relevant local guide under `node_modules/next/dist/docs`
as required by the generated block above.

## Route ownership

- `/`: dashboard.
- `/watchlist` and `/watchlist/[ticker]`: market monitoring and ticker detail.
- `/trades` and `/trades/[id]`: open/closed positions and audit detail.
- `/intelligence/news`: news and macro context.
- `/intelligence/knowledge`: references and learned lessons.
- `/performance/analytics`: risk-adjusted metrics, benchmark, calibration.
- `/performance/versions`: immutable agent versions and activation.
- `/risk`: live risk utilization first, editing second.
- `/settings/agent`: strategy selection and backtest runner.

Folders currently contain placeholders except `/`; do not claim a route exists
until it has a `page.tsx`, loading/error behavior, and required tests.

## Component and state boundaries

- Route files compose features; reusable application shell belongs in
  `src/components/layout/`.
- shadcn primitives live only in `src/components/ui/` and are added with
  `pnpm dlx shadcn@latest add <component>`.
- Domain presentation shared across routes belongs in
  `src/components/trading/`; charts belong in `src/components/charts/`.
- REST access belongs in `src/services/api/`; WebSocket transport belongs in
  `src/services/websocket/`; provider lifecycle belongs in `src/providers/`.
- Keep server state out of ad hoc global stores. `src/stores/` is for genuine
  cross-route client state, not cached API responses by default.
- Use server components unless browser APIs, event handlers, or client hooks
  require a client boundary. Keep client boundaries small.

## Data and financial presentation

- Consume generated API types; do not duplicate backend enums/interfaces.
- Preserve decimal strings across transport and format them explicitly for
  display. Do not silently convert authoritative amounts to imprecise floats.
- Use Indian rupee formatting where applicable and `tabular-nums` for financial
  columns.
- Treat WebSocket messages as invalid until their typed envelope is validated.
- On reconnect, refetch REST state; do not assume missed events can be replayed.

## UI invariants

- Desktop-first, minimum supported width 1024px; sidebar 260px/64px and top bar
  64px per the UI contract.
- The operating-mode badge is always visible.
- Never make live mode visually ambiguous: it is red and says
  `LIVE — REAL MONEY`.
- Use shape-matching skeletons, explanatory empty states, accessible errors,
  keyboard interaction, labelled icon buttons, and focus restoration.
- Use Sonner only for background completion. Visible synchronous results stay
  in the active view.
- The benchmark is always rendered, even when the agent underperforms.

## Frontend completion checks

Run `pnpm lint` and `pnpm build`. When tests are introduced, run focused unit/
component tests and relevant e2e flows. A screen is not complete with mock data
alone: it must use the typed service boundary and implement loading, error,
empty, populated, and confirmation states specified by the product contract.
