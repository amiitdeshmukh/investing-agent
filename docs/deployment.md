# Deployment and Operations

**Target-state contract.** Production deployment is not configured. Today the
repository supports direct local Next.js and FastAPI processes only.

## Deployment model

Docker is intentionally excluded. The frontend and backend run as independent
host-managed processes from one source repository. The production environment
must provide Node.js, Python/uv, PostgreSQL 16 with TimescaleDB, Chroma, TLS
termination, process supervision, and scheduled-job execution.

## Build artifacts

Frontend releases install from `pnpm-lock.yaml` and run `pnpm build`. Backend
releases sync from `uv.lock`; `requirements.txt` is an exported compatibility
artifact, not the dependency source of truth.

## Configuration

Frontend receives only public API and WebSocket base URLs. Backend receives the
database URL, Chroma location, session secret/password hash, Groww HTTP API
credentials, model credentials, market timezone, paper starting balance, and
risk defaults. Secrets are injected by the host and never committed.

## Release order

1. Back up authoritative data where required.
2. Apply ordered forward database migrations.
3. Deploy the backend and verify `/health` plus database dependencies.
4. Deploy the frontend against the verified API.
5. Verify paper mode, active risk rules, WebSocket connectivity, and benchmark
   visibility.

## Rollback

Application rollback restores the previous deployable build without reversing
committed trade history. Agent rollback activates a prior immutable version.
Database migrations require an explicit compatible rollback or forward-fix
plan; destructive ad hoc rollback is prohibited.

## Observability

Logs are structured and redact credentials, cookies, prompts containing secret
material, and provider tokens. Operational monitoring tracks ingestion delay,
decision failures, rejected/approved actions, execution errors, daily halts,
WebSocket connections, and backtest job health. Logs are never the sole audit
record for decisions or trades.

## Failure behavior

Stale/missing prices prevent new execution. Database unavailability prevents
decisions from executing because they cannot be audited. Chroma unavailability
may disable retrieval but must be surfaced; it must not silently fabricate
knowledge. Provider outages back off within rate limits and do not trigger
unbounded retries.

## Configuration ownership

- Frontend receives public API and WebSocket origins only.
- Backend non-secret config includes environment, prefix, allowed origin, market
  timezone, paper balance, and enabled capabilities.
- Backend secrets include database/Chroma credentials, session/password data,
  Groww HTTP credentials, and model credentials.

Production rejects placeholders for enabled features. CORS is restricted to the
configured frontend; session cookies use secure, HTTP-only, appropriate same-
site settings. A `mode` value alone never enables real-order capability.

## Readiness and observability

Process `/health` is currently shallow. Dependency readiness is added with
PostgreSQL/Chroma/providers and distinguishes required from optional services.
Metrics cover API latency/errors, provider throttling, tick age, decision schema
failures, risk rejects/halts, ledger failures, WebSocket reconnects, job age,
and dependency availability.

## Backup and recovery

Back up PostgreSQL before risky migrations and on a documented schedule; test
restore. Chroma can be rebuilt from PostgreSQL knowledge content. Dependency
failure cannot replace portfolio history with empty state.

## Current local commands and deferred choices

```bash
cd frontend && pnpm dev
cd backend && uv run fastapi dev app/main.py
```

No deployment provider, CI platform, supervisor, scheduler, or queue is selected
yet. Choose them through an ADR when required.
