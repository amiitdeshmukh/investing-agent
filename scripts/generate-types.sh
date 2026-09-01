#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/.." && pwd)"
spec_file="$(mktemp)"

trap 'rm -f "$spec_file"' EXIT

(
  cd "$project_root/backend"
  uv run python -c \
    'import json; from app.main import app; print(json.dumps(app.openapi()))'
) > "$spec_file"

(
  cd "$project_root/frontend"
  pnpm dlx openapi-typescript "$spec_file" \
    --output src/types/generated/api.ts
)

echo "Generated frontend/src/types/generated/api.ts from FastAPI OpenAPI."
