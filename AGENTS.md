# Repository Instructions

## Repository boundary

This directory is the only Git repository. `frontend/` and `backend/` must not
be initialized as nested repositories or pushed independently.

## Application boundaries

- Keep browser and UI code in `frontend/`.
- Keep API and business logic in `backend/`.
- The frontend must never contain risk enforcement, portfolio accounting, or
  broker credentials.
- Integrate Groww through its HTTP APIs when that phase begins; do not add the
  Groww Python SDK unless the project decision changes explicitly.

## Development approach

- Prefer official generators and package-manager commands for boilerplate.
- Add dependencies only when the phase that needs them begins.
- Do not introduce Docker configuration.
- Do not commit secrets or populated environment files.
- Preserve paper mode and the human-only live-mode boundary.
- Treat `PROJECT.md` and `docs/` as implementation contracts. Update the
  relevant document when an accepted decision changes a contract.
- Do not fill planned modules with speculative code. Implement them in the
  authoritative phase order.

## Validation

- Frontend: `pnpm lint` and `pnpm build` from `frontend/`.
- Backend: run `uv sync`, import the FastAPI app, and verify `/health` from
  `backend/`.
- API schema changes require matching Pydantic models and an update to
  `docs/api-contract.md`.
- Database schema changes require a forward migration and an update to
  `docs/database-schema.md`.
