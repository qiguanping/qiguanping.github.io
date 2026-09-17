# Tags

Tags is a directory of every topic/tag with the posts that carry it, used from the header and from post metadata.

## Sub-features

- `tags-load` serves `/tags/` with heading `标签` and grouped sections.
- `tags-ai-infra` lists DualPath (and other AI Infra posts) under heading `AI Infra`.
- `tags-rdma` includes DualPath under `RDMA` as well as the `RDMA` topic group.

## How to get to it (user POV)

- Choose `标签` in `主导航`.
- Open `/tags/` directly.
- From a post, choose a topic or tag chip (`/tags/#...`).

## Driving it with verify.sh

Preconditions:

- Preview is healthy at `http://127.0.0.1:$VERIFY_PORT/`.
- `verify.sh doctor` reports HTTP 200 and `Albert's Tech Blog`.

- **Load tags.** Open `/tags/`. Run `.cursor/skills/verify-qiguanping-blog/scripts/verify.sh drive tags`. HTTP 200. Saved `tags.html` contains `<title>标签 | Albert's Tech Blog</title>`, `<h1>标签</h1>`, `TOPICS & TAGS`, `AI Infra`, `RDMA`, `High-Performance Networking`, `/posts/dualpath/`, and `/posts/mooncake/`.
- **Topic groups.** The same body contains `<h2>AI Infra</h2>` and DualPath's short title `DualPath：重新利用空闲网卡带宽`.
- **Proof.** `evidence/tags.html` and `evidence/report.txt` show those needles after cleanup.

## Gotchas

- Hash URLs (`/tags/#AI%20Infra`) are the same document as `/tags/`. HTTP GET `/tags/` is enough to prove the group exists; jumping to the hash is browser-only.
- A post appears in multiple groups (topic plus each tag). DualPath under both `AI Infra` and `RDMA` is expected, not duplication to "fix".
- Group order is by post count then name, not by appearance in the header.
