# Product and UI Specification

**Target-state contract.** Only a project-specific foundation page is currently
implemented. Route directories without `page.tsx` are planned boundaries, not
working screens.

## Global layout

The product is desktop-first and supports viewports down to 1024px. The global
sidebar is 260px wide and collapses to a 64px icon rail, with preference stored
locally. The fixed top bar is 64px high. Content is centered at a maximum width
of 1400px with 24px padding, 16px section gaps, and a 12-column dashboard grid.
Below 1024px the sidebar auto-collapses; v1 has no dedicated mobile layout.

Inter is the UI font. Page titles use `text-2xl font-semibold`, card titles use
`text-lg font-medium`, body/table content uses `text-sm`, and metadata uses
`text-xs text-muted-foreground`. Prices and P&L always use tabular numerals.

## Global navigation

Sidebar groups are Overview (Dashboard), Trading (Watchlist, Positions, Trade
Log), Intelligence (News & Macro, Knowledge Base), Performance (Analytics,
Agent Versions), and Risk & Settings (Risk Console, Agent Config).

The top bar contains the sidebar control, page title/breadcrumb, persistent mode
badge, portfolio value and today's P&L, notification sheet, and command palette.
Paper mode uses a blue `PAPER TRADING` badge. Any future live mode uses a red
`LIVE — REAL MONEY` badge and opens an explicit confirmation dialog.

The top bar order is fixed: sidebar toggle; breadcrumb/page title; flexible
spacer; mode badge/button; portfolio value and today's P&L badge; notification
bell with unread indicator opening a right-side Sheet; and command-palette
trigger. The command palette uses the platform shortcut display (for example
`⌘K`) but remains keyboard/platform accessible.

The sidebar order is logo/app name; labelled nav groups; then pinned collapse,
settings, and help controls. Active navigation uses a subtle background and left
accent. Collapse preference persists in local storage; below 1024px it
auto-collapses.

## Routes and screens

### Dashboard `/`

A full-width portfolio equity curve with 1D/1W/1M/3M/ALL ranges; three summary
cards for today's P&L, open positions/exposure, and risk status; a five-row
recent-decision table with inline reasoning; and an open-position mini-list.

### Watchlist `/watchlist`

Ticker table with name, latest price, change, one-day sparkline, sector, and
confirmed removal. Adding a ticker uses debounced search. A ticker detail route
`/watchlist/[ticker]` shows a candlestick chart, related news, and latest agent
view when available.

### Trades `/trades`

Tabs separate open positions and closed trades. Filters cover date range,
ticker, and side. Open rows show entry/current price, unrealized P&L, stop loss,
and open time. Closed rows add exit, realized P&L, and reward. `/trades/[id]`
shows the complete trade, entry reasoning, annotated price chart, and lesson.

### News `/intelligence/news`

Category, ticker, and date filters sit beside a chronological feed. Upcoming
macro events appear first in a distinct weekly strip. News cards show category,
headline, source, time, sentiment, and related tickers, with expandable body and
source link.

### Knowledge `/intelligence/knowledge`

Semantic search and tabs separate reference documents from learned lessons.
Version 1 accepts pasted content and source metadata. Lessons link to their
originating trade and can sort by date or retrieval count.

### Analytics `/performance/analytics`

Sharpe, maximum drawdown, and win-rate cards; a full-width agent-versus-Nifty-50
equity chart; and a full-width confidence calibration chart with a perfect-
calibration reference line.

### Versions `/performance/versions`

A table shows version, type, creation date, active state, and Sharpe delta.
Activation requires a confirmation dialog and never changes historical trades.

### Risk `/risk`

Status comes before settings. Progress bars show current utilization for each
rule, turning amber over 80% and red at the limit. Editable rules stay inside a
collapsed accordion. A daily halt renders a destructive full-width alert.

### Agent settings `/settings/agent`

Human-confirmed selection of reflection, RL, or comparison mode; plus a
backtest runner with date/ticker scope, asynchronous progress, and results
clearly labelled as backtest rather than paper performance.

## Interaction rules

- One React provider owns the app-wide WebSocket.
- Data cards and tables use shape-matching skeletons, not bare spinners.
- Empty states show an icon and clear one-line explanation.
- Destructive and mode/strategy/version/rule changes always confirm.
- Sonner toasts are for background completions, not visible synchronous results.
- Live-updating open-position rows navigate to detail rather than expanding.
- All controls remain keyboard accessible and expose meaningful labels.

## Data and state rules

- REST owns initial and recovery state. One provider owns `/ws/live` and routes
  consume its typed events.
- After reconnect, refetch affected REST resources instead of assuming events
  were replayed.
- Generated API types are mandatory; display formatting does not change
  authoritative decimal values.
- Filters that should survive navigation belong in URL search parameters.
- Sidebar collapse may live locally; portfolio, risk, mode, and version state
  must come from the backend.
- All timestamps display clearly in the user's configured timezone while
  preserving UTC transport values.

## Visual semantics

- Buy/positive values use green; sell/loss/destructive values use red, but color
  is never the only indicator.
- Action and status badges include text. Confidence uses a labelled progress
  representation.
- Risk progress is normal below 80%, amber from 80% to below the limit, and red
  at/above the limit.
- News categories are macro blue, geopolitical purple, weather cyan, and company
  slate. Sentiment includes dot plus Positive/Neutral/Negative label.
- Charts include titles, units, accessible descriptions/tooltips, range state,
  and honest empty/insufficient-data handling.

## Screen-specific acceptance

- Dashboard decision rows show ticker/action/confidence/time and expand reasoning
  without navigation; the five-row limit and empty message are explicit.
- Watchlist add uses debounced symbol lookup; removal confirms; ticker detail
  shows candles, five related news items, and latest agent view when available.
- Open positions update live but navigate to detail rather than expanding.
- Trade detail ties the execution to entry reasoning, confidence/factors, entry
  annotation, reward, lesson, and later-retrieval count.
- Analytics always renders the Nifty 50 line and gives calibration a full-width
  row with perfect-calibration reference and sample sizes.
- Risk opens as status, not an edit form; rule editing starts collapsed.
- Backtest results say `Backtest Result — not live performance` prominently.

## Screen completion checklist

A route is complete only with the specified layout/content, typed REST data,
single-socket updates where relevant, loading/error/empty/populated states,
confirmations, keyboard/focus behavior, 1024px layout verification, and tests.
Static mock cards or an empty route folder do not satisfy completion.
