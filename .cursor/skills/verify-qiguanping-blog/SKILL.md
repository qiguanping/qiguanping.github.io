---
name: verify-qiguanping-blog
description: Use when proving Albert's Tech Blog (Astro static site, GitHub Pages at qiguanping.github.io) still works after page, content-collection, routing, layout, styling, or build changes — home, posts, search, tags, about, or RSS.
---

# Verify Albert's Tech Blog

Project-local control skill for this Astro blog. Drive the **running site** the way a reader does. Do not treat `pnpm build` alone, unit tests (there are none), or reading source as proof.

Primary surface: static HTML pages at `http://127.0.0.1:$VERIFY_PORT/` (default `43721`). Interactive bits (search filter, home tag filter, carousel, theme toggle) need a browser; HTTP GET still proves the pages exist and render their content.

Read `features/README.md` before a targeted drive. A proof that hits only `/` is incomplete when the map lists other entry points.

## Launch

From the repo root (`git rev-parse --show-toplevel`):

```bash
.cursor/skills/verify-qiguanping-blog/scripts/verify.sh launch
```

What that does:

1. `pnpm install`
2. **Build gate:** `pnpm build` must exit 0 and write `dist/`
3. Start `pnpm exec astro preview --host 127.0.0.1 --port $VERIFY_PORT` in the background
4. Wait until `GET /` returns HTTP 200

Ready signal: preview log contains `localhost:$VERIFY_PORT` **and** `doctor` passes.

Defaults (override with env):

| Var | Default | Purpose |
|---|---|---|
| `VERIFY_PORT` | `43721` | Dedicated preview port (not the human `4321` `pnpm dev` port) |
| `VERIFY_STATE_DIR` | `/tmp/verify-qiguanping-blog` | PID, port, log, evidence |

Do not attach to an existing `pnpm dev` on `4321`. Two verification previews can run if they use different `VERIFY_PORT` and `VERIFY_STATE_DIR` values. Never kill a process by name (`astro`, `node`, `pnpm`); only tear down the PID this run recorded.

For live-reload work, `pnpm dev --host 127.0.0.1 --port $VERIFY_PORT` is allowed **only** after a successful `pnpm build` in the same session, and `doctor` must still pass against that port. Prefer preview: it is what GitHub Pages serves.

## Doctor

```bash
.cursor/skills/verify-qiguanping-blog/scripts/verify.sh doctor
```

Pass only if all of these are true:

- `VERIFY_STATE_DIR/preview.pid` is alive
- something in that process tree is listening on `VERIFY_PORT`
- `GET http://127.0.0.1:$VERIFY_PORT/` is HTTP 200
- the HTML contains `Albert's Tech Blog` and `lang="zh-CN"`

If anything looks off, run doctor before driving. After a failed drive, run doctor again before retrying. Do not drive an instance this run did not start.

## Drive

```bash
.cursor/skills/verify-qiguanping-blog/scripts/verify.sh drive
.cursor/skills/verify-qiguanping-blog/scripts/verify.sh drive home
.cursor/skills/verify-qiguanping-blog/scripts/verify.sh drive article
```

`drive` with no feature runs the HTTP baseline (home + two posts + search + tags + about + RSS). That is the minimum proof for a site-wide change. For a feature-scoped change, run the matching file under `features/` as well.

Harness: `curl` for status + HTML/RSS text. Browser (when available) for client-only behavior. Stable handles from this repo:

| Handle | Where |
|---|---|
| Brand link `aria-label="Albert's Tech Blog 首页"` | header |
| Nav `aria-label="主导航"` with 首页 / 标签 / 搜索 / 关于 | header |
| Featured region `aria-label="精选文章"` | home |
| Filter buttons `[data-filter]`, cards `[data-article]` | home |
| Search box `[data-search-input]`, count `[data-search-count]` | `/search/` |
| Post URLs `/posts/<slug>/` (trailing slash) | content collection `slug` |
| TOC `aria-label="文章目录"` | post |
| Theme button `aria-label` starts with `切换` | header |
| RSS `/rss.xml` | footer |

Do not click by coordinates. Do not assert against `src/data/posts.ts` (not the live collection). Live posts come from `src/content/blog/*/index.md` via `src/content.config.ts`.

Current published slugs: `dualpath`, `mooncake`, `zcube`, `ncclx`, `deepseek-v3-hardware`, `aegis`. Baseline posts: `/posts/dualpath/` and `/posts/mooncake/`.

## Evidence

Proof lives in `$VERIFY_STATE_DIR/evidence/` (default `/tmp/verify-qiguanping-blog/evidence/`). Cleanup must not delete this directory.

Required for a passing run:

- `report.txt` — each check with PASS/FAIL, HTTP status, and the needle that matched
- Saved bodies: `home.html`, `dualpath.html`, `mooncake.html`, plus any extra route driven
- `preview.log` copy or path recorded in the report
- Build: `pnpm build` exit code 0 (logged in the report)

Proof standards:

- Exercise the real reader path (`GET` the public URL, or click the real nav/link). Do not call Astro content APIs or patch fixtures.
- Capture the request (URL) and the resulting body/status, not only "server was up".
- For a mutation (theme toggle, search typing, tag filter), capture before and after. Theme writes `localStorage['albert-theme']`; search updates `[data-search-count]`; filters toggle `[data-article]` `hidden`.
- Cover images under `/images/...` are referenced in markdown but are not in `public/` in this checkout (only `public/favicon.svg`). A 404 cover is **not** a page failure; do not fail HTML checks on those URLs. Do fail if `favicon.svg` 404s.
- Mocks: none. This site has no auth and no backend.

## Cleanup

```bash
.cursor/skills/verify-qiguanping-blog/scripts/verify.sh cleanup
```

Stops only the preview PID recorded in `VERIFY_STATE_DIR/preview.pid` (and its child tree). Leaves `$VERIFY_STATE_DIR/evidence/` in place. After cleanup, confirm `report.txt` still exists at that path.

Full one-shot (launch → doctor → drive baseline → cleanup, evidence kept):

```bash
.cursor/skills/verify-qiguanping-blog/scripts/verify.sh all
```

## Helpers

`scripts/verify.sh` is executable. Subcommands: `launch`, `doctor`, `drive [feature]`, `cleanup`, `all`. Run `--help` for flags. Invoke it from the repo root; the script locates the repo via `git rev-parse`.

Keep the map honest with `/maintain-verification-skill` when routes or visible copy change.
