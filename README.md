# Investing Agent

Investing Agent is a personal AI paper-trading system for Indian equities. It
will combine live market data, news, macroeconomic events, geopolitical context,
portfolio state, and retrieved knowledge to produce explainable buy, sell, or
hold decisions. A deterministic risk layer must independently approve every
action before the paper ledger can execute it.

This repository contains two independently runnable applications with one Git
history:

- `frontend/` — Next.js, React, TypeScript, Tailwind CSS, and shadcn/ui.
- `backend/` — FastAPI and Pydantic, managed with uv.
- `database/` — ordered migrations and development seed data.
- `docs/` — authoritative product and technical contracts.
- `scripts/` — repeatable project automation.

The project is currently in the foundation phase. No Groww endpoint, database,
LLM, broker execution, or trading scheduler is connected yet.

## Prerequisites

- Node.js 22 or newer
- pnpm 10 or newer
- Python 3.13
- uv

Later phases will require PostgreSQL 16 with TimescaleDB and Chroma.

## Run locally

```bash
cp frontend/.env.example frontend/.env.local
cp backend/.env.example backend/.env
```

Frontend:

```bash
cd frontend
pnpm install
pnpm dev
```

Backend:

```bash
cd backend
uv sync
uv run fastapi dev app/main.py
```

The frontend runs at `http://localhost:3000`. The API runs at
`http://127.0.0.1:8000`; health is available at `/health`, versioned health at
`/api/v1/health`, and OpenAPI documentation at `/docs`.

## Project contracts

Start with [PROJECT.md](PROJECT.md). Architecture, API, database, agent, trading,
UI, deployment, and decision contracts live under `docs/`. These documents
describe the target system; code is added in the phase order defined by the
project specification.

Documentation map:

- [`PROJECT.md`](PROJECT.md) — scope, locked stack, safety, and phase order.
- [`AGENTS.md`](AGENTS.md) — mandatory coding-agent workflow.
- [`docs/README.md`](docs/README.md) — source-of-truth and reading guide.
- [`docs/architecture.md`](docs/architecture.md) — components and data flow.
- [`docs/api-contract.md`](docs/api-contract.md) — REST/WebSocket contract.
- [`docs/database-schema.md`](docs/database-schema.md) — persistence contract.
- [`docs/agent-design.md`](docs/agent-design.md) — agent and learning boundary.
- [`docs/trading-and-risk.md`](docs/trading-and-risk.md) — ledger/risk/reward.
- [`docs/product-and-ui.md`](docs/product-and-ui.md) — screens/interactions.
- [`docs/deployment.md`](docs/deployment.md) — configuration and operations.
- [`docs/decisions.md`](docs/decisions.md) — accepted architecture decisions.

## Useful checks

```bash
cd frontend && pnpm lint && pnpm build
cd backend && uv lock --check
./scripts/generate-types.sh
bash -n scripts/*.sh
```

`backend/requirements.txt` and
`frontend/src/types/generated/api.ts` are generated. Change their lock/schema
sources and regenerate rather than editing them directly.

## Safety status

The system is paper-only by default. No automatic paper-to-live transition is
allowed, and the agent can never bypass the risk layer.

## Current status

Foundation setup is complete. The repository does not yet connect to Groww,
PostgreSQL, TimescaleDB, Chroma, news providers, or an LLM. `/health` and
`/api/v1/health` are the only implemented backend endpoints; planned feature
folders are boundaries, not completed features.
