# Trading, Portfolio, Reward, and Risk

**Target-state contract.** These modules are not implemented. Manual paper
trading begins in Phase 1; automated execution waits for Phase 4 risk controls.

## Paper ledger

The ledger simulates executions using exact decimal arithmetic. It records the
observed reference price, configured slippage, fees, final simulated execution
price, quantity, and timestamps. Portfolio mutations occur in a database
transaction so cash, positions, trades, and snapshots cannot diverge.

The initial implementation supports manual paper trades before agent-driven
execution. This allows accounting and risk logic to be tested independently of
LLM behavior.

## Position lifecycle

Opening or increasing a position creates or updates position state and an open
trade record. Closing calculates the exit value, costs, realized P&L, reward,
and closed timestamp. Unrealized P&L is derived from the latest valid price and
is never treated as realized cash.

Side is stored explicitly. Long return is `(exit - entry) / entry`; short return
multiplies that expression by `-1`.

## Risk layer

Risk enforcement is deterministic backend code, not a prompt. Every actionable
decision must be evaluated against the same active rules immediately before
execution. The initial checks cover:

1. daily-loss halt state;
2. valid and fresh market price;
3. requested position size;
4. resulting ticker exposure;
5. resulting sector exposure;
6. available cash or permitted inventory;
7. configured stop-loss; and
8. operating mode and human authorization where applicable.

Evaluation produces `approved` or `rejected` plus a stable reason. A rejection
is stored on the decision and cannot be overridden by confidence, agent type,
or a retry with identical inputs.

## Daily halt

When realized and policy-defined intraday losses reach the daily limit, new
trading is halted for the remainder of that market session. The backend emits a
`daily_loss_halt` event. The halt resets only at the next configured session,
not on process restart or at an agent's request.

## Reward function

On trade close:

```text
raw_return_pct = (exit_price - entry_price) / entry_price
                 * (1 if side == "buy" else -1)

risk_adjusted = raw_return_pct / max(position_volatility, epsilon)

drawdown_penalty = -2.0 * max(0, max_unrealized_loss_during_trade_pct)
overtrade_penalty = -0.1 * max(0, trades_today_for_ticker - 1)
oversize_penalty  = -1.5 * max(0, position_size_pct - max_position_pct)

reward_score = risk_adjusted
               + drawdown_penalty
               + overtrade_penalty
               + oversize_penalty
```

The `-2.0` drawdown coefficient is intentional. It represents risk-of-ruin
asymmetry and must not be made symmetric or replaced with raw P&L. The stored
reward feeds both reflection and later RL training.

## Benchmarking

Evaluation compares the agent portfolio with a Nifty 50 buy-and-hold curve over
the same dates and starting capital. Costs, missing sessions, and cash flows
must be treated consistently. Underperformance is never hidden.

## Ledger invariants

Commands carry idempotency/correlation keys. Cash and inventory cannot become
negative unless a future accepted short/margin model explicitly permits it.
Until then, sells cannot exceed owned inventory. Additions, partial closes, and
weighted-average entry behavior must be specified/tested. Every mutation writes
a portfolio snapshot in the same transaction.

## Risk evaluation details

Checks evaluate the post-trade portfolio, not only requested size. Applicable
global/ticker/sector rules are resolved deterministically and the exact values
used are auditable. Missing price, stale price, unavailable persistence,
uncertain exposure/rules, or an active halt fails closed. Confidence never
changes rule outcomes.

The daily halt covers opening/increasing manual and agent actions. An explicitly
defined risk-reducing close may be allowed but requires tests. Session reset uses
the configured Indian exchange calendar/timezone, never server-local midnight.

## Reward reproducibility

`position_volatility`, epsilon, maximum unrealized loss, position size, and
per-ticker daily trade count have one canonical implementation shared by paper
close, backtest, analytics, and RL data. Percentage units are decimal fractions.
Persist every input required to reproduce a reward.

## Fees and slippage

Costs are explicit versioned assumptions. Record observed reference price and
simulated execution effects without double-counting. Paper and backtest use
comparable assumptions. A temporary zero-cost setting is visibly labelled and
cannot support promotion claims.

## Required tests

- Buy/sell signs, full/partial closes, fees/slippage, and cash invariants.
- Position/sector boundaries immediately below, equal to, and above limits.
- Daily halt persistence and next-session reset.
- Stale/missing price and database failure closed behavior.
- Exact reward terms, epsilon, asymmetric penalty, and units.
- Duplicate idempotency keys and transactional rollback.
- Benchmark date/start-capital/missing-session alignment.
