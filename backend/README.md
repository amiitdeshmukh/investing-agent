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
