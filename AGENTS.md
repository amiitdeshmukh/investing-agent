# Repository Instructions for Coding Agents

This file applies to the entire repository. A nested `AGENTS.md` adds stricter
rules for its subtree; it does not replace this file.

## Mandatory reading order

Before changing code, read the documents relevant to the task in this order:

1. `PROJECT.md` for product scope, locked decisions, safety rules, and phase
   order.
2. `docs/README.md` for the documentation map and source-of-truth rules.
3. `docs/architecture.md` for service ownership and runtime flows.
4. The relevant topic contract under `docs/`.
5. The closest nested `AGENTS.md` for implementation rules.

Do not implement from one document in isolation. If documents conflict, stop,
identify the conflict, and update the accepted decision before coding.

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

## Repository ownership map

- `frontend/`: presentation, user interaction, REST client, and the single
  WebSocket client.
- `backend/`: authentication, external integrations, orchestration, business
  rules, persistence, paper execution, and analytics.
- `database/`: ordered PostgreSQL/TimescaleDB migrations and safe development
  seeds.
- `scripts/`: repeatable generation and database commands only.
- `docs/`: authoritative target-state contracts and accepted decisions.

Code depends inward: API/provider adapters may call domain services; domain
logic must not import FastAPI route objects, browser types, or provider-specific
response objects.

The GitHub repository is `amiitdeshmukh/investing-agent`. Never create nested
Git repositories/remotes. Do not push, publish, change visibility, or create a
release unless the user explicitly requests it.

## Current implementation state

The foundation milestone is complete. The repository currently has a generated
Next.js application with a project-specific landing page; a FastAPI application
with `/health` and `/api/v1/health`; configuration templates; package/module
boundaries; dependency locks; and OpenAPI type generation.

It does **not** yet implement Groww calls, database connectivity, migrations,
authentication, the paper ledger, agents, risk enforcement, market/news jobs,
backtests, or the production dashboard. Never describe planned modules as
implemented. The next product phase is Phase 1: Groww HTTP market-data ingestion
plus a manual paper ledger.

## Locked engineering rules

- Frontend dependencies use pnpm. Keep `pnpm-lock.yaml`; never create
  `package-lock.json`, `yarn.lock`, or another package-manager lock.
- Backend dependencies use uv. Use `uv add`; never hand-edit `uv.lock`.
  Regenerate `requirements.txt` after dependency changes.
- Prefer official generators/CLIs for framework boilerplate and shadcn
  components. Write project-specific domain code explicitly.
- Pydantic/OpenAPI owns API data shapes. Run `scripts/generate-types.sh` after
  schema/route changes; never hand-edit generated TypeScript.
- Use `Decimal` and PostgreSQL `NUMERIC` for financial values. Binary floats are
  forbidden for ledger math.
- Store/transmit timezone-aware UTC timestamps. Use `Asia/Kolkata` only for
  market-session rules and display.
- Treat external data and LLM output as untrusted and validate at the backend
  boundary.
- Do not introduce Docker, GraphQL, gRPC, multi-user infrastructure, or the
  Groww SDK without an explicit accepted decision.

## Safety invariants

- Paper mode is the only default and remains safe after restart.
- No code path automatically changes paper mode to live mode.
- Only authenticated, explicitly confirmed human commands may change mode,
  risk rules, strategy, or the active agent version.
- Agents propose only; they cannot write trades, approve risk, change rules, or
  call real-order endpoints.
- Persist every decision, including holds and rejections, before execution.
- Risk rejection is final for that proposal; confidence cannot override it.
- Daily-loss halts last through the session and cannot be reset by restart or
  agent action.
- Keep the Nifty 50 benchmark visible and preserve the exact asymmetric reward
  formula in `docs/trading-and-risk.md`.

## Required change workflow

1. Confirm the task belongs to the current phase and identify its contracts.
2. Inspect implementation and uncommitted work before editing.
3. Update the contract first when accepted behavior or data shape changes.
4. Implement the smallest complete vertical slice without adjacent speculation.
5. Add tests at domain boundaries and integration tests for changed I/O.
6. Regenerate derived artifacts rather than patching them.
7. Run applicable validations and report what was and was not tested.

## Validation matrix

- Documentation: validate links/paths, consistency, and `git diff --check`.
- Frontend: `pnpm lint` and `pnpm build`; add focused behavior tests when the
  testing stack exists.
- Backend: `uv lock --check`, health/import checks, and relevant tests. Once
  introduced, run `pytest`, `ruff check .`, and `mypy app`.
- Contracts: `scripts/generate-types.sh`, then frontend lint/build.
- Scripts: `bash -n scripts/*.sh` plus safe error/no-op paths.
- Database: apply migrations twice on a disposable database, test repositories,
  and document rollback or forward-fix behavior.

## Definition of done

A change is done only when requested behavior works end to end, safety
invariants hold, tests and generated artifacts pass, documentation matches
reality, no secrets/junk are staged, and `git status` is understood. A folder,
placeholder, or interface without working behavior is not feature completion.
