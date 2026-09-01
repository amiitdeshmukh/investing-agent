# Backend Instructions

- FastAPI and Pydantic own API validation and serialization.
- Keep routes thin; business rules belong in domain services added later.
- Never allow an LLM or external API response to bypass deterministic risk
  checks.
- Use Groww HTTP APIs when integration begins; do not install its SDK.
- Add Python dependencies with `uv add`, never by editing `uv.lock`.
- Keep credentials in ignored environment files and expose none to responses or
  logs.
- `app/api/` translates transport concerns only; keep business rules in domain
  modules.
- Use decimal types for money, price, quantities, and percentages.
- All API schemas are Pydantic models and are the source for generated frontend
  types.
- `uv.lock` is authoritative. Generate `requirements.txt` with
  `uv export --format requirements.txt --no-hashes --output-file requirements.txt`;
  never hand-edit it.
- Unit tests must cover reward and every risk-rule boundary before automated
  paper execution is enabled.
