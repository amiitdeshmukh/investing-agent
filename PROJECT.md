# Investing Agent — Project Definition

**Document role:** authoritative product scope and delivery contract.
**Current status:** foundation complete; Phase 1 implementation has not begun.

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

## Success measures

The system is evaluated on more than raw return. Primary measures are net return
after simulated costs, Sharpe ratio, Sortino ratio, maximum drawdown, win rate,
turnover/overtrading, confidence calibration, and delta versus Nifty 50
buy-and-hold over the same dates and starting capital. Backtest, paper, and any
future live results remain clearly separated.

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

## Locked technology stack

- Frontend: Next.js App Router, React, TypeScript, Tailwind CSS, shadcn/ui,
  Recharts, and Sonner; pnpm manages packages.
- Backend: Python, FastAPI, Pydantic, and uv. LangGraph enters with the agent
  phase; vectorbt and FinRL enter only in their planned phases.
- Data: PostgreSQL 16, TimescaleDB for prices, and Chroma as a rebuildable vector
  index.
- Contracts: Pydantic/OpenAPI is authoritative, with generated TypeScript types.
- Integrations: Groww documented HTTP/streaming APIs, not its SDK. The news API
  vendor is deliberately deferred until Phase 7.
- Runtime: separate frontend/backend processes in one repository; no Docker.

## Primary domain records

The target system records tickers, price ticks, news, macro events, immutable
agent versions, every decision, paper trades, portfolio snapshots, risk rules,
and knowledge entries. PostgreSQL is authoritative. Chroma stores derived
vectors linked back to PostgreSQL content.

## Core operating flow

1. Ingestion normalizes timestamped provider data and stores it idempotently.
2. A scheduled cycle assembles market, portfolio, news, macro, and retrieved
   knowledge context for a ticker.
3. The active agent returns a schema-validated buy/sell/hold proposal.
4. The proposal is persisted before action.
5. Holds stop after logging; buys/sells enter deterministic risk checks.
6. Rejections are persisted. Only approvals reach paper execution.
7. Execution atomically updates trade, cash/position state, and snapshots.
8. Close computes reward and produces a retrievable lesson.
9. Analytics compare performance, calibration, versions, and Nifty 50.

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

The locked close-trade reward is:

```text
raw_return_pct = (exit_price - entry_price) / entry_price
                 * (1 if side == "buy" else -1)
risk_adjusted = raw_return_pct / max(position_volatility, epsilon)
drawdown_penalty = -2.0 * max(0, max_unrealized_loss_during_trade_pct)
overtrade_penalty = -0.1 * max(0, trades_today_for_ticker - 1)
oversize_penalty = -1.5 * max(0, position_size_pct - max_position_pct)
reward_score = risk_adjusted + drawdown_penalty
               + overtrade_penalty + oversize_penalty
```

The `-2.0` loss/drawdown asymmetry is intentional and cannot be simplified to
raw P&L.

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

Every phase must leave a tested, usable boundary. Automated paper execution
cannot precede risk enforcement. RL cannot precede a stable ledger, reward,
backtest path, and data-quality baseline.

## Foundation milestone

The current milestone establishes one repository, separate generated frontend
and backend applications, agreed package boundaries, environment templates,
documentation contracts, and validation commands. Empty module boundaries are
intentional; feature implementation begins only with Phase 1.

Foundation acceptance criteria already met:

- one public repository at `amiitdeshmukh/investing-agent`;
- separate generated Next.js and FastAPI applications;
- pnpm and uv lockfiles plus generated compatibility requirements;
- credential-free environment templates;
- documented module/route boundaries and OpenAPI type generation; and
- passing frontend lint/build and backend health checks.

## User interface scope

The desktop v1 includes Dashboard, Watchlist/ticker detail, Positions/Trade Log
and trade detail, News & Macro, Knowledge Base, Analytics, Agent Versions, Risk
Console, and Agent Config. It supports widths down to 1024px, uses a collapsible
sidebar, always exposes operating mode, and opens one app-wide WebSocket. Exact
layout and interactions live in `docs/product-and-ui.md`.

## API scope

The planned API covers portfolio summary/history, positions, trades, decisions,
watchlist, news, macro events, knowledge entries, performance/calibration/
benchmark analytics, agent versions, async backtests, risk rules, and confirmed
mode changes. Exact methods and paths live in `docs/api-contract.md`.

## Out of scope for v1

- Multi-user authentication and authorization.
- Automatic or agent-controlled real-money trading.
- A mobile-specific interface below 1024px.
- Reference document uploads; v1 accepts pasted text and source metadata.
- Premature installation of AI, trading, database, or vendor SDK dependencies.

Also excluded are GraphQL, gRPC, multi-repository service splitting,
agent-controlled risk changes, hidden benchmarks, and unlabelled mixing of
backtest and paper results.

## Document map

Use `docs/README.md` to select a detailed contract. `PROJECT.md` defines what is
built; topic documents define boundary behavior; nested `AGENTS.md` files define
how code under their subtree is changed.
