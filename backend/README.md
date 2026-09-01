# Investing Agent API

FastAPI authority for integrations, persistence, agent orchestration, risk,
paper execution, reward, backtesting, and analytics. The current foundation
implements configuration and health routes only; domain packages are reserved
for their corresponding build phases.

```bash
uv sync
cp .env.example .env
uv run fastapi dev app/main.py
```

Open `http://127.0.0.1:8000/docs` for the generated API documentation.

Dependencies are added with `uv add`. `uv.lock` is authoritative;
`requirements.txt` is exported for tools that do not support uv.

## Package boundaries

- `app/api/` — HTTP/WebSocket transport and dependencies.
- `app/agents/` — reflection, RL, and debate orchestration.
- `app/trading/` — execution, ledger, portfolio, and positions.
- `app/risk/` — deterministic enforcement.
- `app/reward/` — locked reward calculation.
- `app/ingestion/` — Groww HTTP, news, and macro adapters.
- `app/intelligence/` — knowledge storage, retrieval, and lessons.
- `app/database/` — persistence models, repositories, and sessions.
- `app/backtesting/` and `app/analytics/` — evaluation workloads.
- `app/schemas/` — Pydantic API and domain contracts.
- `tests/` — unit, integration, and reusable fixtures.

## Current implementation

Implemented now:

- environment-backed application metadata;
- browser-origin CORS configuration;
- unversioned `GET /health` reporting service status and paper mode; and
- versioned `GET /api/v1/health` for frontend connectivity.

All trading, persistence, agent, risk, ingestion, knowledge, backtesting, and
analytics packages are planned boundaries without feature implementations yet.

## Environment

`app/config.py` currently reads application name/environment, API prefix,
frontend origin, trading mode, and market timezone. `.env.example` reserves
future database, Chroma, Groww HTTP, authentication, and model values. Reserved
variables are not evidence that those integrations exist.

## Dependency workflow

```bash
uv add <package>
uv lock --check
uv export --format requirements.txt --no-hashes \
  --output-file requirements.txt
```

Add a dependency only in the phase that uses it. Groww is called through HTTP
APIs when Phase 1 begins; do not install `growwapi`.

## API contract workflow

Define request/response shapes as Pydantic models, update
`../docs/api-contract.md`, then run from the repository root:

```bash
./scripts/generate-types.sh
```

Commit the backend schema and generated frontend TypeScript together.

## Safety baseline

The backend starts in paper mode. Future execution must fail closed when
persistence, price freshness, risk approval, authentication, or daily-halt state
cannot be verified. Agent modules never receive direct trade-writing or rule-
mutation capabilities.
