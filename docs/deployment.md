# Deployment and Operations

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
