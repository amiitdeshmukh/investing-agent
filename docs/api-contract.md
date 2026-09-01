# API Contract

**Target-state contract.** Currently implemented endpoints are `GET /health`
and `GET /api/v1/health`. Every other endpoint is planned and is unavailable
until implemented and generated into OpenAPI.

## Conventions

REST endpoints are versioned under `/api/v1`. The health endpoint also exists at
unversioned `/health` for process monitoring. JSON field names use `snake_case`.
Timestamps are UTC ISO-8601 strings. Exact money, price, and quantity values are
serialized as decimal strings.

Clients send JSON. UUIDs use canonical strings. The backend normalizes tickers.
Unknown fields are rejected for safety-sensitive commands. Authentication uses
a server-managed single-user session cookie.

List responses use:

```json
{
  "items": [],
  "page": 1,
  "page_size": 25,
  "total": 0,
  "has_next": false
}
```

Errors use:

```json
{
  "error": {
    "code": "stable_machine_code",
    "message": "Human-readable explanation",
    "details": {}
  }
}
```

## Portfolio and trades

| Method | Path | Result |
|---|---|---|
| GET | `/portfolio/summary` | Cash, position value, total value, today's P&L |
| GET | `/portfolio/history` | Equity curve filtered by range |
| GET | `/positions` | Open positions |
| GET | `/trades` | Filtered, paginated closed trades |
| GET | `/trades/{id}` | Trade, decision, and lesson detail |

`/portfolio/history` accepts `range=1d|1w|1m|3m|all`. `/trades` accepts `ticker`,
`side`, `date_from`, `date_to`, `page`, and `page_size`. `/positions` includes
current price, unrealized P&L, exposure, stop level, and valuation time.

## Decisions and market context

| Method | Path | Result |
|---|---|---|
| GET | `/decisions` | Paginated decisions, including holds/rejections |
| GET | `/decisions/{id}` | Full structured decision |
| GET | `/watchlist` | Watchlisted tickers and latest prices |
| POST | `/watchlist` | Add a validated ticker |
| DELETE | `/watchlist/{ticker}` | Remove a ticker |
| GET | `/news` | News filtered by category, ticker, and date |
| GET | `/macro-events` | Recent and upcoming macro events |

`/decisions` supports ticker/action/risk-status filters plus pagination.
Watchlist deletion removes watchlist state, never history. `/news` accepts
category, ticker, date range, and pagination. Macro events are ordered around
the current time.

## Knowledge and analytics

| Method | Path | Result |
|---|---|---|
| GET | `/knowledge-base` | List or semantic-search entries |
| POST | `/knowledge-base` | Add pasted reference content and source |
| GET | `/analytics/performance` | Sharpe, Sortino, drawdown, and win rate |
| GET | `/analytics/calibration` | Confidence buckets and actual outcomes |
| GET | `/analytics/benchmark` | Agent and Nifty 50 comparison curves |

Knowledge search accepts type/tab, semantic query, sort, and pagination. Adding
a reference accepts pasted `content` and optional `source`; upload is deferred.
Analytics identify period, currency, sample size, and paper/backtest source.

## Versions, backtests, risk, and mode

| Method | Path | Result |
|---|---|---|
| GET | `/agent-versions` | Versions, active state, and performance deltas |
| POST | `/agent-versions/{id}/activate` | Human-confirmed activation |
| POST | `/agent-versions/{id}/backtest` | Create asynchronous backtest job |
| GET | `/backtest-jobs/{id}` | Job status and result |
| GET | `/risk-rules` | Rules and live utilization |
| PUT | `/risk-rules/{id}` | Human-confirmed rule change |
| POST | `/mode` | Human-confirmed paper/live mode request |

State-changing safety requests contain `confirm: true`; the server rejects an
absent or false confirmation. Confirmation does not bypass authentication or
risk checks.

Backtest creation returns `202 Accepted` and a job UUID. Job states are
`queued`, `running`, `completed`, and `failed`. Agent activation never rewrites
historical trades. Risk updates use decimal values and retain update audit data.
A mode request includes `mode: paper|live`, but future live operation also
requires an explicit server capability; the enum alone enables nothing.

## Required response semantics

Decision detail contains ID/version, ticker, action, optional size, confidence,
reasoning, contributing factors, risk status/rejection reason, and decision
time. Trade detail contains prices, quantity, fees, slippage, status/times, P&L,
reward, originating decision, and optional lesson. Portfolio summary contains
cash, position value, total value, today's amount/percentage, valuation time,
and mode.

Implemented Pydantic/OpenAPI models are the shape authority; this document
constrains their meaning.

## HTTP behavior

- `200` successful read/update; `201` created; `202` queued; `204` deleted.
- `400` invalid command; `401` missing session; `403` missing confirmation or
  capability; `404` missing resource; `409` state conflict.
- `422` schema failure; `429` throttling; `503` required dependency unavailable
  or authoritative data too stale.

Idempotency protection is mandatory before automated execution. Clients never
blindly retry a mutation after an ambiguous network failure.

## WebSocket

`/ws/live` is the single frontend streaming connection. Events use:

```json
{
  "type": "price_tick",
  "occurred_at": "2026-09-01T00:00:00Z",
  "payload": {}
}
```

Supported types are `price_tick`, `new_decision`, `trade_opened`,
`trade_closed`, `risk_alert`, and `daily_loss_halt`. The client reconnects with
backoff and refetches REST state because events are not replayable state.

Payloads reuse REST schemas where applicable. Events never carry credentials or
full private prompts. Unknown event types are ignored/logged without crashing;
REST remains recovery state.

## Schema ownership

Pydantic request/response models are the source of truth. Generated TypeScript
types belong in `frontend/src/types/generated/` and must not be hand-edited.

Run `scripts/generate-types.sh`. An API change is incomplete until generated
types and the frontend build pass.
