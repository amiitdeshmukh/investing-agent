# Backend Instructions

- FastAPI and Pydantic own API validation and serialization.
- Keep routes thin; business rules belong in domain services added later.
- Never allow an LLM or external API response to bypass deterministic risk
  checks.
- Use Groww HTTP APIs when integration begins; do not install its SDK.
- Add Python dependencies with `uv add`, never by editing `uv.lock`.
- Keep credentials in ignored environment files and expose none to responses or
  logs.
- `app/api/` translates transport concerns only; keep business rules in domain
  modules.
- Use decimal types for money, price, quantities, and percentages.
- All API schemas are Pydantic models and are the source for generated frontend
  types.
- `uv.lock` is authoritative. Generate `requirements.txt` with
  `uv export --format requirements.txt --no-hashes --output-file requirements.txt`;
  never hand-edit it.
- Unit tests must cover reward and every risk-rule boundary before automated
  paper execution is enabled.

## Required context

Before backend work, read `../PROJECT.md`, `../docs/architecture.md`, the topic
contract for the task, and `../docs/api-contract.md`. Database work also requires
`../database/AGENTS.md` and `../docs/database-schema.md`.

## Dependency direction

- `app/api/` maps HTTP/WebSocket inputs to typed domain calls and maps results
  back to schemas. Routes contain no ledger, risk, reward, or provider logic.
- `app/schemas/` owns Pydantic boundary models and stable enums.
- `app/ingestion/` owns provider authentication, HTTP/streaming calls, rate
  handling, retries, and normalization. Provider payloads do not escape it.
- `app/database/repositories/` owns persistence access; domain services should
  not issue scattered SQL.
- `app/trading/`, `app/risk/`, and `app/reward/` are deterministic domains and
  must not depend on agent orchestration.
- `app/agents/` consumes validated domain context and emits proposals only.
- `app/intelligence/` owns knowledge metadata, retrieval, and lesson lifecycle.
- `app/backtesting/` reuses production domain behavior where possible and never
  mutates the paper portfolio.
- `app/analytics/` computes labelled paper/backtest/version metrics.

## API rules

- All product endpoints live under `/api/v1`; `/health` remains unversioned for
  process monitoring. `/ws/live` is the only streaming endpoint.
- Use dependency injection for sessions/auth/services; do not create provider
  clients or database engines per route call.
- Return the stable error envelope documented in `api-contract.md`.
- Exact financial values serialize as decimal strings; timestamps are UTC
  ISO-8601.
- List endpoints implement consistent page/page_size/items/total/has_next.
- State-changing safety endpoints require an authenticated human and
  `confirm: true`; confirmation never substitutes for authorization.

## Trading and persistence invariants

- Persist the decision before risk evaluation or execution.
- Holds and rejections are successful audited outcomes, not discarded events.
- Ledger mutations are atomic and idempotency-aware.
- Only a risk approval tied to the current proposal may reach execution.
- Stale/missing prices, unavailable audit persistence, and an active daily halt
  fail closed.
- Chroma is derived; PostgreSQL knowledge content remains rebuildable truth.
- Backtests use time-separated data and realistic costs/slippage and are never
  presented as paper performance.

## Error, retry, and logging rules

- Retry only transient provider failures with bounded exponential backoff and
  respect published limits. Never blindly retry order-like mutations.
- Use stable machine error codes and preserve root causes internally.
- Structured logs include correlation identifiers but redact credentials,
  cookies, authorization headers, private prompts, and account data.
- Never let an LLM response select code paths through unvalidated free text.

## Backend completion checks

For foundation changes run `uv lock --check` plus health/import checks. As the
tooling lands, run `pytest`, `ruff check .`, and `mypy app`. New domain behavior
requires unit tests; routes/repositories/providers require integration tests.
Regenerate requirements and OpenAPI TypeScript after dependency/schema changes.
