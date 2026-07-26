import { getCollection } from "astro:content";
export async function GET({ site }: { site: URL | undefined }) {
  const base = site ?? new URL("https://qiguanping.github.io");
  const posts = (await getCollection("blog")).sort((a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf());
  const escape = (value: string) => value.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");
  const items = posts.map((post) => `<item><title>${escape(post.data.title)}</title><link>${new URL(`/posts/${post.data.slug}/`, base)}</link><description>${escape(post.data.description)}</description><pubDate>${post.data.pubDate.toUTCString()}</pubDate><guid>${new URL(`/posts/${post.data.slug}/`, base)}</guid></item>`).join("");
  const xml = `<?xml version="1.0" encoding="UTF-8"?><rss version="2.0"><channel><title>Albert&apos;s Tech Blog</title><link>${base}</link><description>AI Infra · High-Performance Networking · RDMA</description>${items}</channel></rss>`;
  return new Response(xml, { headers: { "Content-Type": "application/rss+xml; charset=utf-8" } });
}