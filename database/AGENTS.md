# Database Instructions

- PostgreSQL 16 is authoritative; enable TimescaleDB before time-series
  migrations require it.
- Add numbered forward migrations such as `0001_initial.sql` and never edit a
  migration after it has been applied in a shared environment.
- Use `NUMERIC` for money, prices, quantities, percentages, and reward values.
- Use `TIMESTAMPTZ` and store UTC timestamps.
- Add check constraints for closed vocabularies and value ranges.
- Ledger changes must remain transactional and auditable.
- Seed files contain development-only reference data, never credentials,
  private account details, or fabricated trade history presented as real.
- Update `docs/database-schema.md` with every accepted schema change.

## Required workflow

1. Read `../PROJECT.md`, `../docs/database-schema.md`, and the domain contract.
2. Resolve the current applied migration state before choosing the next number.
3. Add one focused forward migration under `migrations/`.
4. Add/adjust repository and integration tests in `../backend/tests/`.
5. Apply on a disposable PostgreSQL 16 + TimescaleDB database.
6. Run the migration command again to prove skip/idempotency behavior.
7. Update schema docs and any affected API/generated types in the same change.

## Schema invariants

- Primary audit entities use UUIDs; price ticks use `(ticker, ts)`.
- Add foreign keys for causal history and indexes for documented query paths.
- Constrain actions, sides, statuses, categories, modes, confidence ranges, and
  nonnegative quantities at the database boundary where practical.
- Never cascade-delete decisions, trades, snapshots, lessons, or versions merely
  because current watchlist metadata is removed.
- Chroma IDs reference a derived index; deleting/rebuilding Chroma must not
  delete authoritative knowledge content.
- Only one active executable agent version should be enforced transactionally.

## Migration safety

The runner records applied filenames in `schema_migrations`. Migration filenames
must match `NNNN_description.sql` and contain no user-controlled text. For a
destructive or long-running production change, document locking, backfill,
compatibility window, and recovery before execution. Never place credentials or
private account data in SQL.
