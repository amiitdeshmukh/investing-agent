const foundationStatus = [
  ["Frontend", "Next.js ready"],
  ["Backend", "FastAPI ready"],
  ["Trading mode", "Paper only"],
];

export default function Home() {
  return (
    <main className="flex min-h-screen items-center justify-center bg-background px-6 text-foreground">
      <section className="w-full max-w-3xl rounded-2xl border bg-card p-10 shadow-sm">
        <div className="mb-8 flex items-center justify-between gap-4">
          <div>
            <p className="text-sm font-medium text-muted-foreground">
              Foundation environment
            </p>
            <h1 className="mt-1 text-3xl font-semibold tracking-tight">
              Investing Agent
            </h1>
          </div>
          <span className="rounded-full bg-blue-100 px-3 py-1 text-xs font-semibold text-blue-700">
            PAPER TRADING
          </span>
        </div>

        <p className="max-w-2xl text-sm leading-6 text-muted-foreground">
          The Next.js frontend and FastAPI backend are ready. Market ingestion,
          the paper ledger, risk enforcement, and agent workflows will be added
          in the documented phase order.
        </p>

        <dl className="mt-8 grid gap-4 sm:grid-cols-3">
          {foundationStatus.map(([label, value]) => (
            <div key={label} className="rounded-xl border p-4">
              <dt className="text-xs text-muted-foreground">{label}</dt>
              <dd className="mt-1 text-sm font-medium">{value}</dd>
            </div>
          ))}
        </dl>
      </section>
    </main>
  );
}
