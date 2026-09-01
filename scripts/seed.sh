#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${DATABASE_URL:-}" ]]; then
  echo "DATABASE_URL is required." >&2
  exit 1
fi

if ! command -v psql >/dev/null 2>&1; then
  echo "psql is required to load seed data." >&2
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
seeds_dir="$script_dir/../database/seeds"
found=false

for seed in "$seeds_dir"/*.sql; do
  [[ -e "$seed" ]] || continue
  found=true
  echo "Loading $(basename "$seed")..."
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 --single-transaction -f "$seed"
done

if [[ "$found" == "false" ]]; then
  echo "No seed SQL files found."
fi
