export type PostSummary = {
  title: string;
  shortTitle: string;
  description: string;
  topic: string;
  tags: string[];
  readingMinutes: number;
  slug?: string;
  status: "published" | "next";
};

export const posts: PostSummary[] = [
  {
    title: 'DualPath 深度解读：当“空闲的另一半网卡”成为破局点',
    shortTitle: "DualPath：重新利用空闲网卡带宽",
    description:
      "从双路径 KV-Cache 加载、CNIC 流量管理到自适应调度，理解推理系统如何把闲置网络带宽重新变成有效吞吐。",
    topic: "Inference Infrastructure",
    tags: ["KV Cache", "Multi-NIC", "RDMA"],
    readingMinutes: 38,
    slug: "/posts/dualpath/",
    status: "published",
  },
  {
    title: "Mooncake 深度解读：用存储换算力",
    shortTitle: "Mooncake：以 KV Cache 为中心的推理架构",
    description:
      "把 KV Cache 从推理副产品提升为系统调度中枢，连接分布式存储、传输引擎与 P/D 分离。",
    topic: "Inference Infrastructure",
    tags: ["KV Cache", "RDMA", "Serving"],
    readingMinutes: 44,
    status: "next",
  },
  {
    title: "ZCube 深度解读：当自动化搜索推翻拓扑设计者的直觉",
    shortTitle: "ZCube：自动搜索出来的 AI 集群拓扑",
    description:
      "从 ATOP 搜索空间到低直径递归拓扑，分析性能、网络成本与适用边界之间的真实取舍。",
    topic: "AI Networking",
    tags: ["Topology", "AI Cluster", "Optimization"],
    readingMinutes: 42,
    status: "next",
  },
  {
    title: "NCCLX：把通信从 GPU 里搬出来",
    shortTitle: "NCCLX：十万卡 RoCE 上的集合通信重构",
    description:
      "Meta 如何用 Host-driven、Zero-copy 与端网协同，在大规模 RoCE 网络上重新设计集合通信。",
    topic: "RDMA & Communication",
    tags: ["RoCE", "NCCL", "Collectives"],
    readingMinutes: 31,
    status: "next",
  },
  {
    title: "DeepSeek-V3 硬件架构反思深度解读",
    shortTitle: "DeepSeek-V3：受限硬件上的系统协同",
    description:
      "从 H800、NVLink、MoE 到多平面 Fat-Tree，理解模型、通信库和网络拓扑的协同设计。",
    topic: "AI Cluster Systems",
    tags: ["H800", "NVLink", "MPFT"],
    readingMinutes: 46,
    status: "next",
  },
  {
    title: "Aegis 深度解读：生产 AI 集群的故障诊断演进",
    shortTitle: "Aegis：生产 AI 集群的故障诊断演进",
    description:
      "从日志与网管系统到定制 CCL，分析大规模训练服务如何定位故障、性能退化与交付前风险。",
    topic: "AI Cluster Systems",
    tags: ["Diagnosis", "CCL", "Observability"],
    readingMinutes: 36,
    status: "next",
  },
];
