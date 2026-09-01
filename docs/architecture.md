# System Architecture

**Target-state contract.** Only the foundation health routes are implemented at
present. Components described below are introduced in the phase order from
`../PROJECT.md`.

## Overview

Investing Agent is one repository containing two runtime applications. Next.js
is the user interface; FastAPI is the authority for data, decisions, risk,
execution, and analytics. They are deployed and run separately while sharing
documented API contracts.

```text
Groww HTTP/streaming APIs     News and macro APIs
             \                    /
              v                  v
             ingestion and normalization
                        |
                        v
              PostgreSQL + TimescaleDB <----> Chroma
                        ^                         ^
                        |                         |
                  FastAPI backend ----------------+
                   |           ^
                   | REST      | one WebSocket
                   v           |
                    Next.js frontend
```

## Frontend responsibility

The frontend renders portfolio, market, decision, news, knowledge, analytics,
version, risk, and configuration views. It owns transient UI state, filtering,
loading/error states, dialogs, and the single WebSocket client. It never treats
browser state as authoritative portfolio or risk state.

## Backend responsibility

FastAPI owns:

- authentication and human-only command authorization;
- external API adapters and normalization;
- persistence and transaction boundaries;
- portfolio accounting and paper execution;
- agent context assembly and structured-output validation;
- deterministic risk evaluation;
- reward calculation and reflection;
- backtest jobs and performance analytics;
- event publication to `/ws/live`.

Routes remain thin. Domain modules call repositories through explicit services,
and external providers are isolated behind adapters so vendor changes do not
leak into business logic.

## Repository-to-component map

| Path | Target responsibility |
|---|---|
| `frontend/src/app/` | Route composition and route-local UI |
| `frontend/src/components/` | Reusable UI, charts, layout, trading views |
| `frontend/src/services/api/` | Typed REST transport |
| `frontend/src/services/websocket/` | Single live-event transport |
| `backend/app/api/` | REST/WebSocket adapters and dependencies |
| `backend/app/ingestion/` | Groww/news/macro provider adapters |
| `backend/app/agents/` | Reflection, debate, and RL proposal workflows |
| `backend/app/trading/` | Execution, ledger, portfolio, positions |
| `backend/app/risk/` | Deterministic risk policy |
| `backend/app/reward/` | Locked reward calculation |
| `backend/app/intelligence/` | Knowledge, retrieval, lessons |
| `backend/app/backtesting/` | Isolated historical evaluation jobs |
| `backend/app/analytics/` | Performance, benchmark, calibration |
| `backend/app/database/` | Sessions, models, repositories |
| `backend/app/schemas/` | Pydantic boundary contracts |
| `database/` | Ordered SQL migrations and development seeds |

## Dependency direction

Transport/provider adapters depend on typed application/domain services.
Deterministic trading/risk/reward code cannot depend on FastAPI routes, an LLM,
or provider payload shapes. Repository implementations depend on database
infrastructure; callers depend on explicit repository interfaces. The frontend
depends on generated API types and never imports backend Python implementation.

## Decision and execution sequence

1. A scheduled cycle selects a watchlisted ticker.
2. The backend assembles current price features, portfolio state, exposure,
   relevant news/macro events, and retrieved knowledge.
3. The active agent emits a Pydantic-validated decision.
4. The backend stores the decision before any execution attempt.
5. A hold ends after logging. Buy/sell proposals enter the risk service.
6. The risk service either rejects with a persisted reason or produces an
   approval valid for that proposal.
7. Only the paper execution service can turn an approval into a trade.
8. Execution updates the ledger atomically and publishes live events.
9. Closing a trade calculates reward, generates a lesson, and indexes it.

## Data ownership

PostgreSQL is authoritative for entities and audit history. TimescaleDB is used
for timestamped price observations. Chroma is a derived retrieval index; every
vector points back to a PostgreSQL knowledge entry. If the vector index is lost,
it can be rebuilt from authoritative content.

Providers are data sources, not authorities for internal audit history.
Normalized records retain source/provider time. The paper ledger is the only
authority for simulated cash and positions. WebSocket events are delivery
notifications and never replace persisted records.

## Request and streaming flow

REST reads return an authoritative snapshot. REST commands authenticate,
validate, call a domain service, commit, and only then publish events. The
frontend opens one `/ws/live` connection through a React provider. After a
disconnect it refetches affected REST resources instead of deriving missed
state from events.

## Scheduling and asynchronous work

Ingestion and agent cycles run outside request handlers. Backtests are created
through REST and processed as jobs; clients poll `/backtest-jobs/{id}`. Worker
restart must not duplicate ticks, decisions, trades, or completed jobs. The
concrete scheduler/queue technology is deferred until implementation.

## Reliability principles

- Decimal arithmetic for money and quantities.
- UTC timestamps at rest and across APIs.
- Idempotent ingestion using provider identifiers or ticker/timestamp keys.
- Database transactions around ledger mutations.
- WebSocket events are notifications, not the system of record; clients refetch
  REST state after reconnecting.
- Backtests run asynchronously and never block live request workers.
- Provider calls use timeouts, bounded backoff, rate-limit awareness, and
  idempotency where available.
- Missing audit persistence, stale prices, uncertain risk state, or active daily
  halt fails closed for execution.
- Paper state survives backend restart; memory is never its sole authority.

## Security and safety boundaries

Provider credentials exist only in backend environment variables. The browser
never receives Groww credentials, database URLs, model keys, or the configured
login password. LLM output is untrusted input and must pass schema and risk
validation. Paper mode is the default and cannot change without an authenticated
human confirmation command.

The auth target is one server-side session cookie established with an
environment-configured password/hash. Production cookies are secure and
state-changing requests receive CSRF protection. Live broker order capability
is absent from v1 and cannot be inferred from the presence of a `mode` field.

## Current foundation

Implemented: repository split, Next.js shell, FastAPI configuration/CORS,
health routes, package boundaries, environment templates, lockfiles, and
OpenAPI-to-TypeScript generation. Not implemented: provider, persistence,
authentication, scheduling, domain, WebSocket, and dashboard features above.
