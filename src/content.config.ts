import { defineCollection } from "astro:content";
import { glob } from "astro/loaders";
import { z } from "astro/zod";

const blog = defineCollection({
  loader: glob({ pattern: "**/*.{md,mdx}", base: "./src/content/blog" }),
  schema: z.object({
    title: z.string(),
    shortTitle: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    updatedDate: z.coerce.date(),
    topic: z.string(),
    tags: z.array(z.string()),
    series: z.string(),
    readingMinutes: z.number(),
    cover: z.string(),
    coverAlt: z.string(),
    coverCaption: z.string(),
    featured: z.boolean().default(false),
    order: z.number(),
    slug: z.string(),
  }),
});

export const collections = { blog };