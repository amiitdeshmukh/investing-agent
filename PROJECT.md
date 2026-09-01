# Investing Agent — Project Definition

## Product vision

Investing Agent is a single-user research and paper-trading platform. An AI
agent observes live and historical market data together with company news,
macroeconomic releases, weather, and geopolitical events. It combines that
context with the current portfolio and retrieved investment knowledge to issue
structured buy, sell, or hold decisions.

The product is designed to answer a measurable question: can a versioned,
explainable agent deliver repeatable risk-adjusted results against a Nifty 50
buy-and-hold benchmark while respecting strict loss and exposure limits?

## Core capabilities

1. Ingest Groww market data through HTTP APIs and persist normalized ticks.
2. Ingest and classify news and macro events from a vendor selected in the
   relevant build phase.
3. Maintain an auditable paper portfolio with cash, positions, fees, slippage,
   realized P&L, unrealized P&L, and point-in-time snapshots.
4. Produce Pydantic-validated agent decisions with confidence, reasoning, and
   contributing factors.
5. Apply deterministic position, sector, stop-loss, and daily-loss rules before
   any simulated execution.
6. Evaluate Sharpe, Sortino, drawdown, win rate, confidence calibration, and
   benchmark-relative performance.
7. Turn closed trades into lessons that can be retrieved for future decisions.
8. Compare LLM-reflection and reinforcement-learning agent versions, with safe
   activation and rollback.

## Users and operation

Version 1 is a personal, single-user system. Authentication uses a server-side
session cookie and an environment-configured password. Multi-user accounts,
roles, billing, and tenancy are intentionally out of scope.

The normal operating mode is paper trading. Live mode is represented in the
data model for an explicitly human-controlled future integration, but it is not
part of the initial implementation.

## Technical boundaries

- `frontend/` renders data and submits human commands. It does not calculate
  authoritative risk, balances, rewards, or positions.
- `backend/` owns all business logic, integrations, persistence, scheduling,
  agents, risk decisions, paper execution, and analytics.
- Groww is integrated through its documented HTTP and streaming APIs; the
  Python SDK is not a project dependency.
- PostgreSQL 16 is the system of record. TimescaleDB stores price time series.
- Chroma stores embeddings; PostgreSQL stores knowledge metadata and vector IDs.
- REST under `/api/v1` handles queries and commands. One WebSocket at `/ws/live`
  carries all live frontend events.

## Non-negotiable safety rules

- The system starts in `paper` mode.
- It never automatically graduates from paper to live trading.
- Every decision is logged, including holds and risk-layer rejections.
- The agent cannot modify, disable, or bypass risk rules.
- A risk rejection cannot be overridden by confidence or agent reasoning.
- Reaching the daily-loss limit halts new trades until the next session.
- Mode, risk-rule, strategy, and agent-version changes require an authenticated
  human confirmation.
- Benchmark underperformance remains visible.
- The reward function keeps its asymmetric drawdown penalty.

## Authoritative build order

1. Groww data ingestion and a manual paper-trading ledger.
2. Knowledge base setup and curated reference documents.
3. Single structured-output LLM decision agent.
4. Risk management layer, before automated execution.
5. Automated paper execution and evaluation dashboard v1.
6. Reward calculation and LLM reflection loop.
7. News/macro ingestion and multi-agent debate.
8. FinRL policy training and comparison with the reflection agent.
9. Agent versioning, rollback, and calibration tracking.
10. Complete UI build-out in the specified screen order.

## Foundation milestone

The current milestone establishes one repository, separate generated frontend
and backend applications, agreed package boundaries, environment templates,
documentation contracts, and validation commands. Empty module boundaries are
intentional; feature implementation begins only with Phase 1.

## Out of scope for v1

- Multi-user authentication and authorization.
- Automatic or agent-controlled real-money trading.
- A mobile-specific interface below 1024px.
- Reference document uploads; v1 accepts pasted text and source metadata.
- Premature installation of AI, trading, database, or vendor SDK dependencies.
