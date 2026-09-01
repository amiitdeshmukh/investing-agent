#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${DATABASE_URL:-}" ]]; then
  echo "DATABASE_URL is required." >&2
  exit 1
fi

if ! command -v psql >/dev/null 2>&1; then
  echo "psql is required to apply migrations." >&2
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
migrations_dir="$script_dir/../database/migrations"

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c \
  "CREATE TABLE IF NOT EXISTS schema_migrations (version TEXT PRIMARY KEY, applied_at TIMESTAMPTZ NOT NULL DEFAULT now());"

found=false
for migration in "$migrations_dir"/[0-9][0-9][0-9][0-9]_*.sql; do
  [[ -e "$migration" ]] || continue
  found=true
  version="$(basename "$migration")"
  applied="$(
    psql "$DATABASE_URL" --set=version="$version" -tAc \
      "SELECT 1 FROM schema_migrations WHERE version = :'version'"
  )"

  if [[ "$applied" == "1" ]]; then
    echo "Skipping $version (already applied)."
    continue
  fi

  echo "Applying $version..."
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 --set=version="$version" \
    --single-transaction \
    -f "$migration" \
    -c "INSERT INTO schema_migrations (version) VALUES (:'version');"
done

if [[ "$found" == "false" ]]; then
  echo "No numbered migrations found."
fi
