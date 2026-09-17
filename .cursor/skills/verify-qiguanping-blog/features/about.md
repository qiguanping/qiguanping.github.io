# About and RSS

About is the author page. RSS is the machine-readable feed linked from the footer.

## Sub-features

- `about-load` serves `/about/` with heading `关于 Albert` and the GitHub profile link.
- `rss-load` serves `/rss.xml` as RSS 2.0 with the site title and post items.

## How to get to it (user POV)

- Choose `关于` in `主导航`.
- Open `/about/` directly.
- Choose `RSS` in the footer (`aria-label="社交链接"`), or open `/rss.xml` directly.

## Driving it with verify.sh

Preconditions:

- Preview is healthy at `http://127.0.0.1:$VERIFY_PORT/`.
- `verify.sh doctor` reports HTTP 200 and `Albert's Tech Blog`.

- **Load about.** Open `/about/`. Run `.cursor/skills/verify-qiguanping-blog/scripts/verify.sh drive about`. HTTP 200. Saved `about.html` contains `<title>关于 Albert | Albert's Tech Blog</title>`, `<h1>关于 Albert</h1>`, `AI Infra · High-Performance Networking · RDMA`, `https://github.com/qiguanping`, and `联系方式`.
- **Load RSS.** Open `/rss.xml`. Same `drive about` (or the default `drive`) fetches it. HTTP 200. `Content-Type` includes `application/rss+xml`. Saved `rss.xml` contains `<title>Albert's Tech Blog</title>` (or the escaped `Albert&apos;s Tech Blog` form), `<rss version="2.0">`, `/posts/dualpath/`, and `/posts/mooncake/`.
- **Proof.** `evidence/about.html`, `evidence/rss.xml`, and `evidence/report.txt` remain after cleanup.

## Gotchas

- The channel title in RSS is XML-escaped (`Albert&apos;s Tech Blog`). Assert that form or the raw apostrophe, not both as if they were different products.
- About has no posts list. Do not fail about because DualPath is absent on that page.
- The GitHub link is `https://github.com/qiguanping` with `target="_blank"`. Proving the href is enough; do not require the external profile to load.
