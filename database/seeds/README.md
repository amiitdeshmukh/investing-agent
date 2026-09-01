# Development Seeds

Development-only seed SQL lives here. Seed files should be deterministic and
safe to rerun where practical. They may contain initial risk-rule defaults and
sample watchlist metadata, but never secrets or genuine private account data.

Run available seed files with `scripts/seed.sh` from the repository root.

## Seed contract

Seed filenames should describe their contents and use explicit conflict
handling when reruns are expected. Appropriate future seeds include default
risk-rule values, a small development watchlist, and curated public reference
material. Do not seed fake historical trades in a way that could be mistaken
for agent results.

The current directory contains no `.sql` seed because domain defaults have not
yet been accepted in Phase 1. The seed runner safely reports that no files exist.
