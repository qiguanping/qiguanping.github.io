# Home

Home is the landing page: brand and primary nav, a featured-article carousel, client-side tag filters, and a grid of every published post.

## Sub-features

- `home-load` serves `/` with the site title, Chinese `lang`, skip link, and primary nav.
- `home-featured` shows up to three featured posts in `aria-label="精选文章"`.
- `home-latest` lists all published posts under `最新文章`.
- `home-filter` filters cards with `[data-filter]` without leaving `/`.
- `home-open-post` follows a card or featured link into `/posts/<slug>/`.

## How to get to it (user POV)

- Open `/` or choose `首页` in `主导航`.
- Choose the brand link `Albert's Tech Blog`.
- Follow the skip link `跳到正文` to `#main-content`.

## Driving it with verify.sh

Preconditions:

- Preview is healthy at `http://127.0.0.1:$VERIFY_PORT/`.
- `verify.sh doctor` reports HTTP 200 and `Albert's Tech Blog`.

- **Load home.** Open `/`. Run `.cursor/skills/verify-qiguanping-blog/scripts/verify.sh drive home`. HTTP 200. Saved `home.html` contains `<title>Albert's Tech Blog</title>`, `lang="zh-CN"`, `Albert's Tech Blog 首页`, `主导航`, `首页`, `标签`, `搜索`, `关于`, `跳到正文`, `精选文章`, `最新文章`, and `© 2026 Albert.`.
- **Featured posts.** In the same body, the featured region contains `DualPath：重新利用空闲网卡带宽`, `Mooncake：以 KV Cache 为中心的推理架构`, and `ZCube：自动搜索出来的 AI 集群拓扑`.
- **Latest grid.** The same body contains those three plus `NCCLX：十万卡 RoCE 上的集合通信重构`, `DeepSeek-V3：受限硬件上的系统协同`, and `Aegis：生产 AI 集群的故障诊断演进`, and includes `/posts/dualpath/` plus `/posts/mooncake/`.
- **Favicon.** `GET /favicon.svg` is HTTP 200.
- **Filter (browser only).** Choose a `[data-filter]` button that is not `全部`. Cards whose `[data-tags]` do not include that label become `hidden`; `全部` shows them again. If every card hides, `[data-empty]` becomes visible with `该标签下暂无文章。`. HTTP-only runs cannot prove this; report `verified-unreachable` for `home-filter` unless a browser was used.
- **Open a post.** Choose `阅读：DualPath 深度解读：当“空闲的另一半网卡”成为破局点` or the DualPath card heading. The next document is `/posts/dualpath/` (see [Article](./article.md)).
- **Proof.** `evidence/home.html` and `evidence/report.txt` show the needles above. Cleanup must leave those files.

## Gotchas

- Featured copy is `shortTitle`, not the long `h1` used on the post page.
- Home `currentPath` highlighting expects pathname `/`. Driving `/index.html` is a different URL.
- Cover images under `/images/...` may 404 in this checkout. That does not fail `home-load`.
- Do not assert titles from `src/data/posts.ts`; several rows there are `status: "next"` and do not match the content collection.
- Carousel auto-advance is visual only (`aria-hidden` on `[data-slide]`). HTTP GET always sees slide 0 as visible.
