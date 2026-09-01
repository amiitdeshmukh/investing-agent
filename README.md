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

## Safety status

The system is paper-only by default. No automatic paper-to-live transition is
allowed, and the agent can never bypass the risk layer.
