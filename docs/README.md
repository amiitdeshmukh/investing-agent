# Documentation Guide

These documents are implementation contracts for humans and coding agents.
They describe the target product while distinguishing it from the current
foundation implementation.

## Reading order

1. [`../PROJECT.md`](../PROJECT.md) — product purpose, locked decisions, safety,
   phase order, and current status.
2. [`architecture.md`](architecture.md) — runtime components and flows.
3. Read the contract matching the task:
   - [`api-contract.md`](api-contract.md) for REST/WebSocket and types;
   - [`database-schema.md`](database-schema.md) for tables and migrations;
   - [`agent-design.md`](agent-design.md) for agent context and learning;
   - [`trading-and-risk.md`](trading-and-risk.md) for ledger/risk/reward;
   - [`product-and-ui.md`](product-and-ui.md) for screens/interactions;
   - [`deployment.md`](deployment.md) for configuration/operations.
4. [`decisions.md`](decisions.md) records why locked choices exist.
5. Read the closest subtree `AGENTS.md` before changing files.

## Source-of-truth hierarchy

- User instructions for the current task have highest authority.
- `PROJECT.md` owns scope, safety invariants, and phase order.
- `decisions.md` owns accepted technology and architecture choices.
- The topic document owns detailed behavior for that boundary.
- Pydantic/OpenAPI owns implemented API shapes; TypeScript is generated.
- Applied SQL migrations own implemented database state; the schema document
  must change with them.
- Code and README status statements must accurately say what is implemented.

Target documentation may lead implementation for an unbuilt feature, but it
must be labelled planned. A mismatch for implemented behavior must be resolved,
not silently ignored.

## Documentation update matrix

| Change | Required update |
|---|---|
| API route or payload | `api-contract.md`, generated TypeScript |
| Table, index, or constraint | migration, `database-schema.md` |
| Agent context/output/prompt policy | `agent-design.md`, ADR if architectural |
| Ledger, risk, reward, benchmark | `trading-and-risk.md` |
| Screen, route, state, interaction | `product-and-ui.md` |
| Runtime/config/deployment | `deployment.md`, env examples |
| Technology/boundary decision | `decisions.md`, possibly `PROJECT.md` |
| Phase completion/current state | `PROJECT.md`, root/app README files |

## Writing rules

- Mark behavior as implemented, planned, or deferred.
- Use exact paths, fields, enum values, units, and ownership.
- Document failure/safety behavior, not only happy paths.
- Never include secrets, real credentials, or private account data.
- Link to the authoritative detail instead of maintaining divergent copies.
