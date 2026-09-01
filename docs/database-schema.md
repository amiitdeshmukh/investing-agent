# Database Contract

## Platform

The target database is PostgreSQL 16 with TimescaleDB. UUID primary keys use
`gen_random_uuid()`. All timestamps are timezone-aware. Money, price, percentage,
and quantity columns use `NUMERIC`; floating-point types are not used for ledger
values.

## Tables

### `price_ticks`

TimescaleDB hypertable keyed by `(ticker, ts)`. Stores open, high, low, close,
and volume. Re-ingesting an existing ticker/timestamp must be idempotent.

### `tickers`

Instrument metadata and watchlist state: ticker, name, sector, watchlist flag,
and added timestamp.

### `news_items`

Source, headline, optional body and URL, publication timestamp, category,
sentiment, related tickers, and ingestion timestamp. Categories are `macro`,
`geopolitical`, `weather`, and `company`.

### `macro_events`

Event type, description, event date, affected tickers, and affected sectors.

### `agent_versions`

Immutable version label, agent type, JSON configuration, active flag, creation
timestamp, and notes. Only one executable version may be active at a time.

### `agent_decisions`

Producing version, ticker, action, optional size percentage, confidence,
reasoning, contributing factors, risk status, rejection reason, and decision
timestamp. Holds and rejected decisions are retained.

### `trades`

Originating decision, ticker, side, quantity, entry/exit prices, fees, slippage,
open/close timestamps, status, realized P&L, and reward score. Closing a trade
sets exit, realized P&L, reward, closed timestamp, and status atomically.

### `portfolio_snapshots`

Timestamp, cash balance, position value, total value, and operating mode. This
supports equity curves and audit reconstruction.

### `risk_rules`

Rule type, limit value, optional ticker/sector scope, and update timestamp.
Supported initial rules are maximum position percentage, maximum sector
exposure, daily loss limit, and stop-loss percentage.

### `knowledge_base_entries`

Reference or lesson type, content, source, optional originating trade, Chroma
vector identifier, and creation timestamp. PostgreSQL content is authoritative.

## Relationships

- A decision belongs to an agent version.
- A trade may reference the decision that caused it.
- A lesson may reference its closed trade.
- Ticker text is deliberately retained on time-series/audit rows so historical
  records remain readable even if watchlist metadata changes.

## Migration rules

Migrations live in `database/migrations/`, are numbered, reviewed, and applied
in order. Once shared, migrations are append-only. Destructive changes require
an explicit data-preservation plan. Seed data contains safe defaults and never
credentials or real account information.
