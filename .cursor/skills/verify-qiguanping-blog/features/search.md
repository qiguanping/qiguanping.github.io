# Search

Search lists every published post and filters that list in the browser as the reader types.

## Sub-features

- `search-load` serves `/search/` with heading `搜索` and all six posts visible.
- `search-count-default` shows `共 6 篇文章` in `[data-search-count]`.
- `search-filter` narrows results as `[data-search-input]` changes.
- `search-open-result` follows a result link to `/posts/<slug>/`.

## How to get to it (user POV)

- Choose `搜索` in `主导航`.
- Open `/search/` directly.

## Driving it with verify.sh

Preconditions:

- Preview is healthy at `http://127.0.0.1:$VERIFY_PORT/`.
- `verify.sh doctor` reports HTTP 200 and `Albert's Tech Blog`.

- **Load search.** Open `/search/`. Run `.cursor/skills/verify-qiguanping-blog/scripts/verify.sh drive search`. HTTP 200. Saved `search.html` contains `<title>搜索 | Albert's Tech Blog</title>`, `<h1>搜索</h1>`, `data-search-input`, `共 6 篇文章`, `DualPath：重新利用空闲网卡带宽`, `Mooncake：以 KV Cache 为中心的推理架构`, `ZCube：自动搜索出来的 AI 集群拓扑`, `NCCLX：十万卡 RoCE 上的集合通信重构`, `DeepSeek-V3：受限硬件上的系统协同`, and `Aegis：生产 AI 集群的故障诊断演进`.
- **Filter (browser only).** Focus `[data-search-input]` and type `rdma`. `[data-search-count]` becomes `找到 N 篇文章` with `N` matching visible `[data-search-item]` rows; DualPath remains visible. Clear the input: count returns to `共 6 篇文章` and no row is `hidden`. HTTP-only runs cannot prove `search-filter`; report `verified-unreachable` unless a browser was used.
- **Open result.** Choose the DualPath result heading. The next document is `/posts/dualpath/`.
- **Proof.** `evidence/search.html` and `evidence/report.txt` show the load needles. Cleanup must leave those files.

## Gotchas

- Filtering is client-side on `data-search-text` (lowercase title, description, topic, tags). A `curl` body is always the unfiltered page.
- Placeholder text `搜索 AI Infra、RDMA、KV Cache…` is not a result. Assert headings or `data-search-count`.
- There is no dedicated empty-state node; a miss only updates the count to `找到 0 篇文章` and hides every `[data-search-item]`.
