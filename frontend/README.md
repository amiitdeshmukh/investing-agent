# Investing Agent Frontend

Next.js control surface for portfolio monitoring, paper trades, decisions,
market intelligence, analytics, agent versions, risk status, and configuration.

The application was generated with the official `create-next-app` CLI and uses
the App Router, TypeScript, Tailwind CSS, shadcn/ui, ESLint, Turbopack, and pnpm.

## Commands

```bash
pnpm install
pnpm dev
pnpm lint
pnpm build
```

Copy `.env.example` to `.env.local` before connecting the API. Only variables
prefixed with `NEXT_PUBLIC_` are available in the browser; never place broker,
database, model, or authentication secrets here.

## Structure

- `src/app/` — route segments and route-local composition.
- `src/components/ui/` — shadcn-generated primitives.
- `src/components/layout/` — shell, sidebar, top bar, and navigation.
- `src/components/charts/` — reusable visualizations.
- `src/components/trading/` — shared trading-domain presentation.
- `src/services/api/` — typed REST client.
- `src/services/websocket/` — single live-connection transport.
- `src/providers/` — React context providers.
- `src/types/generated/` — generated API contracts; never hand-edit.
- `e2e/` — browser-level tests.

The frontend displays backend state; it does not implement authoritative risk,
rewards, portfolio accounting, or order execution.
