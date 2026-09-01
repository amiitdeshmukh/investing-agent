# System Architecture

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

## Reliability principles

- Decimal arithmetic for money and quantities.
- UTC timestamps at rest and across APIs.
- Idempotent ingestion using provider identifiers or ticker/timestamp keys.
- Database transactions around ledger mutations.
- WebSocket events are notifications, not the system of record; clients refetch
  REST state after reconnecting.
- Backtests run asynchronously and never block live request workers.

## Security and safety boundaries

Provider credentials exist only in backend environment variables. The browser
never receives Groww credentials, database URLs, model keys, or the configured
login password. LLM output is untrusted input and must pass schema and risk
validation. Paper mode is the default and cannot change without an authenticated
human confirmation command.
