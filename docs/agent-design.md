# Agent Design

## Purpose and boundary

The agent converts a normalized evidence bundle into a structured market
decision. It proposes; it does not execute. It has no direct access to ledger
writes, mode changes, broker order endpoints, or risk-rule mutation.

## Decision input

Each decision cycle receives only timestamped, attributable context:

- ticker identity and normalized price/volume features;
- current cash, positions, exposure, and existing stop levels;
- recent related news with source and publication time;
- upcoming and recent macro events;
- relevant reference documents and lessons retrieved from the knowledge base;
- active agent-version configuration; and
- current risk limits for awareness, not enforcement.

Missing or stale data is represented explicitly. The agent must not infer that
an absent signal is neutral or fabricate a price, event, or source.

## Structured output

The first agent produces one Pydantic-validated decision containing:

- `ticker`;
- `action`: `buy`, `sell`, or `hold`;
- optional `size_pct` for an actionable proposal;
- `confidence` from 0 through 1;
- concise reasoning tied to supplied evidence; and
- contributing factors such as technical, news, macro, or knowledge.

Validation failures are not converted into trades. The cycle records an
operational failure and may retry according to bounded orchestration policy.

## Reflection agent

Version 1 is a single LLM reflection agent. On trade close, it receives the
entry context, actual path, exit, risk events, costs, and computed reward. It
generates a short lesson that distinguishes process quality from outcome luck.
The lesson is stored in PostgreSQL and indexed in Chroma for future retrieval.

## Multi-agent debate

In a later phase, independent roles may produce bullish, bearish, risk, and
synthesis views. Debate expands evidence coverage but does not change the output
contract or safety boundary. The final proposal still passes the same Pydantic
schema and deterministic risk layer.

## Reinforcement-learning policy

FinRL is introduced only after the paper ledger, reward, backtesting, and data
quality are stable. The RL policy is versioned independently and evaluated on
time-separated data with costs and slippage. It can run in comparison mode with
the reflection agent; only the explicitly active execution strategy can submit
a proposal to risk evaluation.

## Versioning

Every material prompt, model, feature, retrieval, policy, or configuration
change creates an immutable `agent_versions` record. Decisions retain their
producing version. Activation is human-confirmed, past trades are unchanged,
and rollback selects a prior version rather than rewriting history.

## Evaluation

An agent version is judged by risk-adjusted return, maximum drawdown, win rate,
turnover, benchmark delta, reward distribution, and confidence calibration.
Backtest results are always labelled separately from live paper performance.
