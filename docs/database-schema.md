# Database Contract

**Target-state contract.** No numbered migration or database connection exists
yet. Phase 1 creates `0001_initial.sql`; applied migrations, not prose alone,
become the implemented schema authority.

## Platform

The target database is PostgreSQL 16 with TimescaleDB. UUID primary keys use
`gen_random_uuid()`. All timestamps are timezone-aware. Money, price, percentage,
and quantity columns use `NUMERIC`; floating-point types are not used for ledger
values.

## Tables

### `price_ticks`

TimescaleDB hypertable keyed by `(ticker, ts)`. Stores open, high, low, close,
and volume. Re-ingesting an existing ticker/timestamp must be idempotent.

Columns: `ticker TEXT NOT NULL`, `ts TIMESTAMPTZ NOT NULL`, optional
`open/high/low/close NUMERIC`, `volume BIGINT`, primary key `(ticker, ts)`.
Convert it to a TimescaleDB hypertable on `ts`.

### `tickers`

Instrument metadata and watchlist state: ticker, name, sector, watchlist flag,
and added timestamp.

Columns: `ticker TEXT PRIMARY KEY`, `name TEXT NOT NULL`, optional `sector`,
`is_watchlisted BOOLEAN DEFAULT true`, and `added_at TIMESTAMPTZ`.

### `news_items`

Source, headline, optional body and URL, publication timestamp, category,
sentiment, related tickers, and ingestion timestamp. Categories are `macro`,
`geopolitical`, `weather`, and `company`.

Use UUID ID; require source/headline/published/category; allow body/URL;
constrain sentiment to `[-1,1]`; store related tickers as text array.

### `macro_events`

Event type, description, event date, affected tickers, and affected sectors.

Use UUID ID; require type, description, and event date; affected ticker/sector
arrays are optional.

### `agent_versions`

Immutable version label, agent type, JSON configuration, active flag, creation
timestamp, and notes. Only one executable version may be active at a time.

Initial agent types are `llm_reflection|rl_policy`. Enforce one active row with
a transactional or partial-unique strategy.

### `agent_decisions`

Producing version, ticker, action, optional size percentage, confidence,
reasoning, contributing factors, risk status, rejection reason, and decision
timestamp. Holds and rejected decisions are retained.

Action is `buy|sell|hold`; confidence is `[0,1]`; risk status is
`approved|rejected`. Size is nullable for holds. Rejected rows require a reason.

### `trades`

Originating decision, ticker, side, quantity, entry/exit prices, fees, slippage,
open/close timestamps, status, realized P&L, and reward score. Closing a trade
sets exit, realized P&L, reward, closed timestamp, and status atomically.

Open rows require ticker, `buy|sell`, positive quantity, entry price,
nonnegative fees/slippage, open time, and `open|closed` status. Closed rows
require exit price/time and realized P&L. Reward is calculated at close.

### `portfolio_snapshots`

Timestamp, cash balance, position value, total value, and operating mode. This
supports equity curves and audit reconstruction.

Mode is `paper|live` with default `paper`. Snapshot time is indexed and history
is never rewritten to improve reported performance.

### `risk_rules`

Rule type, limit value, optional ticker/sector scope, and update timestamp.
Supported initial rules are maximum position percentage, maximum sector
exposure, daily loss limit, and stop-loss percentage.

Rule types are `max_position_pct`, `max_sector_exposure_pct`,
`daily_loss_limit_pct`, and `stop_loss_pct`. Value is nonnegative;
`applies_to` is null for global or a normalized ticker/sector scope.

### `knowledge_base_entries`

Reference or lesson type, content, source, optional originating trade, Chroma
vector identifier, and creation timestamp. PostgreSQL content is authoritative.

Entry type is `reference|lesson_learned`. References may have no trade; lessons
link to their origin trade. Chroma/vector IDs support rebuild/update linkage.

## Relationships

- A decision belongs to an agent version.
- A trade may reference the decision that caused it.
- A lesson may reference its closed trade.
- Ticker text is deliberately retained on time-series/audit rows so historical
  records remain readable even if watchlist metadata changes.

Indexes support latest ticks, news publication/ticker lookup, macro dates,
decisions by time/ticker/version/risk, trades by status/ticker/time, snapshots by
time, active versions, knowledge type/time, and related trade.

## Integrity and lifecycle

- Removing a watchlist ticker never cascades into audit history.
- Referenced agent versions are immutable and retained.
- Decisions exist before trades and remain when rejected.
- Ledger mutation and portfolio snapshot commit atomically.
- Trade close cannot partially apply.
- PostgreSQL knowledge survives Chroma rebuild/outage.
- Risk/mode changes remain auditable; add audit schema before implementing them.

## Migration rules

Migrations live in `database/migrations/`, are numbered, reviewed, and applied
in order. Once shared, migrations are append-only. Destructive changes require
an explicit data-preservation plan. Seed data contains safe defaults and never
credentials or real account information.

Required first-migration extensions are `pgcrypto` for UUID generation and
TimescaleDB for the hypertable. Constraints and indexes are part of the same
reviewed migration as their table unless an online rollout requires otherwise.
