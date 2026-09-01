# Migrations

Ordered PostgreSQL migrations live here and use four-digit prefixes:

```text
0001_initial.sql
0002_add_retrieval_usage.sql
```

Phase 1 will add the initial TimescaleDB and paper-ledger migration after the
persistence approach is implemented and tested. Run available migrations with
`scripts/migrate.sh` from the repository root.
