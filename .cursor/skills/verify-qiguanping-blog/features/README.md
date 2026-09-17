# Albert's Tech Blog verification map

This directory is the maintained source for verifying reader-facing behavior of Albert's Tech Blog. Read this index before driving the app, then use the matching feature file as the recipe.

## Baseline preconditions

- Repo root of `alberts-tech-blog-v2` (Astro + pnpm).
- Node `>=22.12.0`, `pnpm` on `PATH`.
- Launch with `.cursor/skills/verify-qiguanping-blog/scripts/verify.sh launch` so the preview owns `VERIFY_PORT` (default `43721`).
- Run `verify.sh doctor` and require HTTP 200 at `http://127.0.0.1:$VERIFY_PORT/` with `Albert's Tech Blog` in the HTML.
- Never drive an instance that was not started by this verification run (do not use the human `localhost:4321` session).
- Trailing slashes match the in-app links: `/`, `/tags/`, `/search/`, `/about/`, `/posts/<slug>/`.

## Driving conventions

- Start every recipe from a freshly loaded URL unless its preconditions say otherwise.
- Prefer the handles in this map (ARIA names, `data-*`, visible headings) over CSS position.
- Treat every command as literal. Keep quoted needles unchanged.
- HTTP actions: `verify.sh drive <feature>` (or `curl` against the same URLs).
- Browser actions: open the same URL, then use the labeled control. No coordinate clicks.
- Do not delete `$VERIFY_STATE_DIR/evidence/` during cleanup.

## Proof and skip reporting

- Capture the URL (or click) and the resulting HTML/visible state, not only the final screenshot.
- HTTP proof: status, saved body, and the exact needle from the feature file.
- Browser proof: the control used and the DOM/visible change (and a screenshot if a browser is available).
- Record the feature ID with every artifact.
- Report an unreachable path with the URL attempted and the unmet precondition.
- Do not report a skipped entry point as verified through a different path.

## Feature entry contract

Each feature file starts with an H1 title and one paragraph describing the user-visible behavior. It then uses exactly four H2 sections in this order.

1. `Sub-features` lists short IDs with one line for each behavior.
2. `How to get to it (user POV)` lists every user entry point.
3. `Driving it with verify.sh` starts with `Preconditions:` and uses labeled bullets that pair each user action with an exact command and observable result.
4. `Gotchas` lists traps that can waste or invalidate a verification run.

Keep implementation details out of the map. Name only user paths, stable handles, required state, commands, and observable proof.

## Features

- [Home](./home.md) covers the brand, featured carousel, tag filters, and latest-article cards.
- [Article](./article.md) covers post pages, TOC, and breadcrumb/topic links.
- [Search](./search.md) covers the search page, default listing, and client-side filtering.
- [Tags](./tags.md) covers the tag directory grouped by topic.
- [About and RSS](./about.md) covers the about page and the RSS feed.
