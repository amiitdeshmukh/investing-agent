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
