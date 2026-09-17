# Article

Article pages render one blog post from the content collection: title, metadata, cover, in-page TOC, and the markdown body.

## Sub-features

- `article-dualpath` serves `/posts/dualpath/` with the DualPath title and TOC.
- `article-mooncake` serves `/posts/mooncake/` with the Mooncake title and TOC.
- `article-chrome` shows breadcrumb `首页`, topic link, reading time, and series.
- `article-toc` lists `h2`/`h3` headings under `aria-label="文章目录"`.

## How to get to it (user POV)

- From home, choose a featured slide or an article-card link.
- From search or tags, choose a post link (`/posts/<slug>/`).
- Open `/posts/dualpath/` or `/posts/mooncake/` directly.

## Driving it with verify.sh

Preconditions:

- Preview is healthy at `http://127.0.0.1:$VERIFY_PORT/`.
- `verify.sh doctor` reports HTTP 200 and `Albert's Tech Blog`.

- **DualPath.** Open `/posts/dualpath/`. Run `.cursor/skills/verify-qiguanping-blog/scripts/verify.sh drive article`. HTTP 200. Saved `dualpath.html` contains `<title>DualPath：重新利用空闲网卡带宽 | Albert's Tech Blog</title>`, `DualPath 深度解读`, `文章目录`, `AI Infra 论文深读`, `38 分钟阅读`, `KV Cache`, and `TL;DR`.
- **Mooncake.** Open `/posts/mooncake/`. Same `drive article` also fetches it. HTTP 200. Saved `mooncake.html` contains `<title>Mooncake：以 KV Cache 为中心的推理架构 | Albert's Tech Blog</title>`, `Mooncake 深度解读`, `文章目录`, and `TL;DR`.
- **Breadcrumb.** Both bodies contain a link to `/` labeled `首页` and a topic link into `/tags/`.
- **Proof.** `evidence/dualpath.html`, `evidence/mooncake.html`, and the matching PASS lines in `evidence/report.txt` remain after cleanup.

## Gotchas

- Slugs are the frontmatter `slug` field (`dualpath`), not the folder name alone. Always use the trailing slash that the templates emit.
- The layout `<title>` uses `shortTitle`; the visible `<h1>` uses `title`. Assert both when the feature names them.
- Other slugs (`zcube`, `ncclx`, `deepseek-v3-hardware`, `aegis`) are in the collection; baseline only requires DualPath and Mooncake. A change that only touches one of those other posts must drive that slug instead of calling DualPath sufficient.
- TOC is empty if a post has no `h2`/`h3`. DualPath and Mooncake both have them.
