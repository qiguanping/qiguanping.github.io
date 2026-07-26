$ErrorActionPreference = "Stop"

$sourceRoot = "D:\WorkSpace\WorkBuddy\PaperReport"
$projectRoot = (Get-Location).Path
$utf8 = New-Object System.Text.UTF8Encoding($false)

$articles = @(
  @{
    Slug = "dualpath"
    Md = "DualPath_深度解读.md"
    Figures = "DualPath_figures"
    Front = @(
      'title: "DualPath 深度解读：当“空闲的另一半网卡”成为破局点"'
      "shortTitle: 'DualPath：重新利用空闲网卡带宽'"
      "description: '从双路径 KV-Cache 加载、CNIC 流量管理到自适应调度，理解推理系统如何把闲置网络带宽重新变成有效吞吐。'"
      "pubDate: 2026-07-26"
      "updatedDate: 2026-07-26"
      "topic: 'AI Infra'"
      "tags: ['KV Cache', 'Multi-NIC', 'RDMA']"
      "series: 'AI Infra 论文深读'"
      "readingMinutes: 38"
      "cover: '/images/covers/dualpath-cover.png'"
      "coverAlt: 'DualPath 双路径数据流概念封面'"
      "coverCaption: 'AI 概念封面；论文原图完整保留在正文中。'"
      "featured: true"
      "order: 1"
      "slug: 'dualpath'"
    )
  }
  @{
    Slug = "mooncake"
    Md = "Mooncake_深度解读.md"
    Figures = "Mooncake_figures"
    Front = @(
      "title: 'Mooncake 深度解读：用存储换算力——KVCache 中心化解耦架构的工程哲学'"
      "shortTitle: 'Mooncake：以 KV Cache 为中心的推理架构'"
      "description: '把 KV Cache 从推理副产品提升为系统调度中枢，连接分布式存储、传输引擎与 P/D 分离。'"
      "pubDate: 2026-07-25"
      "updatedDate: 2026-07-26"
      "topic: 'AI Infra'"
      "tags: ['KV Cache', 'RDMA', 'Serving']"
      "series: 'AI Infra 论文深读'"
      "readingMinutes: 44"
      "cover: '/images/posts/mooncake/figures/fig02.png'"
      "coverAlt: 'Mooncake 系统架构图'"
      "coverCaption: '暂用论文原图展示，AI 封面将在后续阶段制作。'"
      "featured: true"
      "order: 2"
      "slug: 'mooncake'"
    )
  }
  @{
    Slug = "zcube"
    Md = "ZCube_深度解读.md"
    Figures = "ZCube_figures"
    Front = @(
      "title: 'ZCube 深度解读：当自动化搜索推翻拓扑设计者的直觉'"
      "shortTitle: 'ZCube：自动搜索出来的 AI 集群拓扑'"
      "description: '从 ATOP 搜索空间到低直径递归拓扑，分析性能、网络成本与适用边界之间的真实取舍。'"
      "pubDate: 2026-07-24"
      "updatedDate: 2026-07-26"
      "topic: 'High-Performance Networking'"
      "tags: ['Topology', 'AI Cluster', 'Optimization']"
      "series: 'AI Infra 论文深读'"
      "readingMinutes: 42"
      "cover: '/images/posts/zcube/figures/fig8_zcube_construct.png'"
      "coverAlt: 'ZCube 递归网络拓扑构造图'"
      "coverCaption: '暂用论文原图展示，AI 封面将在后续阶段制作。'"
      "featured: true"
      "order: 3"
      "slug: 'zcube'"
    )
  }
  @{
    Slug = "ncclx"
    Md = "NCCLX_深度解读.md"
    Figures = "NCCLX_figures"
    Front = @(
      'title: "NCCLX：把通信从 GPU 里“搬”出来"'
      "shortTitle: 'NCCLX：十万卡 RoCE 上的集合通信重构'"
      "description: 'Meta 如何用 Host-driven、Zero-copy 与端网协同，在大规模 RoCE 网络上重新设计集合通信。'"
      "pubDate: 2026-07-23"
      "updatedDate: 2026-07-26"
      "topic: 'RDMA'"
      "tags: ['RoCE', 'NCCL', 'Collectives']"
      "series: 'AI Infra 论文深读'"
      "readingMinutes: 31"
      "cover: '/images/posts/ncclx/figures/fig01.png'"
      "coverAlt: 'NCCLX 多楼宇 RoCE 网络架构图'"
      "coverCaption: '暂用论文原图展示，AI 封面将在后续阶段制作。'"
      "featured: false"
      "order: 4"
      "slug: 'ncclx'"
    )
  }
  @{
    Slug = "deepseek-v3-hardware"
    Md = "DeepSeekV3_HW_深度解读.md"
    Figures = "DeepSeekV3_HW_figures"
    Front = @(
      "title: 'DeepSeek-V3 硬件架构反思深度解读：在受管制硬件上榨取一流效率'"
      "shortTitle: 'DeepSeek-V3：受限硬件上的系统协同'"
      "description: '从 H800、NVLink、MoE 到多平面 Fat-Tree，理解模型、通信库和网络拓扑的协同设计。'"
      "pubDate: 2026-07-22"
      "updatedDate: 2026-07-26"
      "topic: 'AI Infra'"
      "tags: ['H800', 'NVLink', 'MPFT']"
      "series: 'AI Infra 论文深读'"
      "readingMinutes: 46"
      "cover: '/images/posts/deepseek-v3-hardware/figures/fig1_arch.png'"
      "coverAlt: 'DeepSeek-V3 基础架构图'"
      "coverCaption: '暂用论文原图展示，AI 封面将在后续阶段制作。'"
      "featured: false"
      "order: 5"
      "slug: 'deepseek-v3-hardware'"
    )
  }
  @{
    Slug = "aegis"
    Md = "Aegis_深度解读.md"
    Figures = "Aegis_figures"
    Front = @(
      'title: "Aegis 深度解读：当“不能碰客户代码”成为诊断系统的第一性原理"'
      "shortTitle: 'Aegis：生产 AI 集群的故障诊断演进'"
      "description: '从日志与网管系统到定制 CCL，分析大规模训练服务如何定位故障、性能退化与交付前风险。'"
      "pubDate: 2026-07-21"
      "updatedDate: 2026-07-26"
      "topic: 'AI Infra'"
      "tags: ['Diagnosis', 'CCL', 'Observability']"
      "series: 'AI Infra 论文深读'"
      "readingMinutes: 36"
      "cover: '/images/posts/aegis/figures/fig06_aegis_overview.png'"
      "coverAlt: 'Aegis 故障诊断系统总览图'"
      "coverCaption: '暂用论文原图展示，AI 封面将在后续阶段制作。'"
      "featured: false"
      "order: 6"
      "slug: 'aegis'"
    )
  }
)

foreach ($article in $articles) {
  $contentDir = Join-Path $projectRoot "src\content\blog\$($article.Slug)"
  $imageDir = Join-Path $projectRoot "public\images\posts\$($article.Slug)\figures"
  New-Item -ItemType Directory -Force -Path $contentDir, $imageDir | Out-Null

  Get-ChildItem -LiteralPath (Join-Path $sourceRoot $article.Figures) -File |
    Copy-Item -Destination $imageDir -Force

  $body = [IO.File]::ReadAllText((Join-Path $sourceRoot $article.Md))
  $body = [regex]::Replace($body, "^\uFEFF?# .+?\r?\n\r?\n", "", 1)
  $body = $body.Replace(
    "$($article.Figures)/",
    "/images/posts/$($article.Slug)/figures/"
  )

  $frontmatter = "---`n" + ($article.Front -join "`n") + "`n---`n"
  [IO.File]::WriteAllText(
    (Join-Path $contentDir "index.md"),
    $frontmatter + $body,
    $utf8
  )
}

Write-Output "Imported six articles and copied all original figures without transformation."
