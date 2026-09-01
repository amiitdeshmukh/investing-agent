# API Contract

## Conventions

REST endpoints are versioned under `/api/v1`. The health endpoint also exists at
unversioned `/health` for process monitoring. JSON field names use `snake_case`.
Timestamps are UTC ISO-8601 strings. Exact money, price, and quantity values are
serialized as decimal strings.

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

## Knowledge and analytics

| Method | Path | Result |
|---|---|---|
| GET | `/knowledge-base` | List or semantic-search entries |
| POST | `/knowledge-base` | Add pasted reference content and source |
| GET | `/analytics/performance` | Sharpe, Sortino, drawdown, and win rate |
| GET | `/analytics/calibration` | Confidence buckets and actual outcomes |
| GET | `/analytics/benchmark` | Agent and Nifty 50 comparison curves |

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

## Schema ownership

Pydantic request/response models are the source of truth. Generated TypeScript
types belong in `frontend/src/types/generated/` and must not be hand-edited.
