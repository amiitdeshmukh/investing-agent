# Migrations

Ordered PostgreSQL migrations live here and use four-digit prefixes:

```text
0001_initial.sql
0002_add_retrieval_usage.sql
```

Phase 1 will add the initial TimescaleDB and paper-ledger migration after the
persistence approach is implemented and tested. Run available migrations with
`scripts/migrate.sh` from the repository root.

## Migration contract

- A migration is forward-only after it reaches a shared environment.
- One file owns one coherent schema change and uses explicit constraints/indexes.
- Use `CREATE EXTENSION IF NOT EXISTS timescaledb` only when the Phase 1
  environment contract is ready.
- TimescaleDB hypertable creation and any uniqueness requirements must be tested
  on the supported extension version.
- Data backfills must be deterministic, bounded, and documented separately from
  destructive cleanup.

Run with:

```bash
export DATABASE_URL='postgresql://...'
./scripts/migrate.sh
```

The current directory contains no numbered migration because persistence has
not been implemented. `0001_initial.sql` is a Phase 1 deliverable, not completed
foundation work.
