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

## Environment

Copy `.env.example` to `.env.local`:

```text
NEXT_PUBLIC_API_BASE_URL=http://127.0.0.1:8000/api/v1
NEXT_PUBLIC_WS_URL=ws://127.0.0.1:8000/ws/live
```

Both values are public browser configuration. Secrets never belong in a
`NEXT_PUBLIC_` variable.

## Planned routes

| Route | Responsibility | Status |
|---|---|---|
| `/` | Dashboard foundation, later portfolio overview | Foundation only |
| `/watchlist` | Watchlist table and add/remove flow | Planned |
| `/watchlist/[ticker]` | Price/news/agent ticker detail | Planned |
| `/trades` | Open positions and closed trades | Planned |
| `/trades/[id]` | Decision, execution, and lesson audit | Planned |
| `/intelligence/news` | News and macro feed | Planned |
| `/intelligence/knowledge` | References and learned lessons | Planned |
| `/performance/analytics` | Performance, benchmark, calibration | Planned |
| `/performance/versions` | Agent versions and activation | Planned |
| `/risk` | Risk utilization and rule editing | Planned |
| `/settings/agent` | Strategy and backtest controls | Planned |

## Contract generation

Pydantic/OpenAPI is authoritative. From the repository root:

```bash
./scripts/generate-types.sh
```

This replaces `src/types/generated/api.ts`. Do not edit that file by hand.

## Screen completion standard

Every implemented screen must follow `../docs/product-and-ui.md`, use the typed
API boundary, and cover loading, error, empty, and populated states. Destructive
or configuration-changing actions require confirmation. The app must retain one
WebSocket connection and recover state through REST after reconnecting.
