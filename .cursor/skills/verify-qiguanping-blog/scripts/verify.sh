#!/usr/bin/env bash
# HTTP verification harness for Albert's Tech Blog.
# Launch a dedicated astro preview, assert reader-visible pages, keep evidence.
set -euo pipefail

ROOT="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${ROOT}" ]]; then
  echo "error: not inside the blog git repo" >&2
  exit 1
fi

VERIFY_PORT="${VERIFY_PORT:-43721}"
VERIFY_STATE_DIR="${VERIFY_STATE_DIR:-/tmp/verify-qiguanping-blog}"
HOST="127.0.0.1"
BASE="http://${HOST}:${VERIFY_PORT}"
PID_FILE="${VERIFY_STATE_DIR}/preview.pid"
PORT_FILE="${VERIFY_STATE_DIR}/port"
LOG_FILE="${VERIFY_STATE_DIR}/preview.log"
EVIDENCE_DIR="${VERIFY_STATE_DIR}/evidence"
REPORT="${EVIDENCE_DIR}/report.txt"
FAILS=0

usage() {
  cat <<'EOF'
Usage: verify.sh <launch|doctor|drive [feature]|cleanup|all|--help>

  launch            pnpm install, pnpm build, start astro preview
  doctor            check that this run's preview is healthy
  drive [feature]   HTTP-assert routes (default: baseline)
                    features: home, article, search, tags, about, baseline
  cleanup           stop the preview PID this run started (keeps evidence)
  all               launch, doctor, drive baseline, cleanup

Env: VERIFY_PORT (default 43721), VERIFY_STATE_DIR (default /tmp/verify-qiguanping-blog)
     VERIFY_SKIP_INSTALL=1, VERIFY_SKIP_BUILD=1
EOF
}

log() { printf '%s\n' "$*"; }
fail() { printf 'FAIL %s\n' "$*" >&2; FAILS=$((FAILS + 1)); }
pass() { printf 'PASS %s\n' "$*"; }

mkdir -p "${VERIFY_STATE_DIR}" "${EVIDENCE_DIR}"

listening_pid() {
  local port="$1"
  if command -v lsof >/dev/null 2>&1; then
    lsof -tiTCP:"${port}" -sTCP:LISTEN 2>/dev/null | head -n1 || true
    return
  fi
  if command -v ss >/dev/null 2>&1; then
    ss -ltnp 2>/dev/null | awk -v p=":${port}" 'index($4, p) { print; }' | sed -n 's/.*pid=\([0-9]\+\).*/\1/p' | head -n1 || true
  fi
}

pid_alive() {
  local pid="${1:-}"
  [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null
}

parent_of() {
  ps -o ppid= -p "$1" 2>/dev/null | tr -d ' '
}

in_tree() {
  local root="$1" candidate="$2"
  local cur="${candidate}"
  local guard=0
  while [[ -n "${cur}" && "${cur}" != "0" && "${cur}" != "1" ]]; do
    if [[ "${cur}" == "${root}" ]]; then
      return 0
    fi
    cur="$(parent_of "${cur}")"
    guard=$((guard + 1))
    if [[ "${guard}" -gt 32 ]]; then
      break
    fi
  done
  return 1
}

cmd_launch() {
  cd "${ROOT}"
  if [[ "${VERIFY_SKIP_INSTALL:-0}" != "1" ]]; then
    log "install: pnpm install"
    pnpm install
  fi
  if [[ "${VERIFY_SKIP_BUILD:-0}" != "1" ]]; then
    log "build: pnpm build"
    pnpm build
    if [[ ! -d "${ROOT}/dist" ]]; then
      echo "error: pnpm build did not write dist/" >&2
      exit 1
    fi
    echo "build: ok (dist/ present)" | tee "${EVIDENCE_DIR}/build.txt"
  else
    echo "build: skipped (VERIFY_SKIP_BUILD=1)" | tee "${EVIDENCE_DIR}/build.txt"
    if [[ ! -d "${ROOT}/dist" ]]; then
      echo "error: VERIFY_SKIP_BUILD=1 but dist/ is missing" >&2
      exit 1
    fi
  fi

  if [[ -f "${PID_FILE}" ]] && pid_alive "$(cat "${PID_FILE}")"; then
    log "preview already running as pid $(cat "${PID_FILE}")"
    cmd_doctor
    return
  fi

  local existing
  existing="$(listening_pid "${VERIFY_PORT}" || true)"
  if [[ -n "${existing}" ]]; then
    echo "error: port ${VERIFY_PORT} is already in use by pid ${existing}; set VERIFY_PORT" >&2
    exit 1
  fi

  : > "${LOG_FILE}"
  log "preview: pnpm exec astro preview --host ${HOST} --port ${VERIFY_PORT}"
  (
    cd "${ROOT}"
    exec pnpm exec astro preview --host "${HOST}" --port "${VERIFY_PORT}"
  ) >"${LOG_FILE}" 2>&1 &
  echo $! > "${PID_FILE}"
  echo "${VERIFY_PORT}" > "${PORT_FILE}"

  local i
  for i in $(seq 1 80); do
    if curl -fsS -o /dev/null "${BASE}/" 2>/dev/null; then
      log "ready: ${BASE}/"
      cp "${LOG_FILE}" "${EVIDENCE_DIR}/preview.log"
      return
    fi
    sleep 0.25
  done
  echo "error: preview did not become ready on ${BASE}/" >&2
  echo "----- preview.log -----" >&2
  cat "${LOG_FILE}" >&2 || true
  cmd_cleanup || true
  exit 1
}

cmd_doctor() {
  local pid="" listener=""
  if [[ -f "${PID_FILE}" ]]; then
    pid="$(cat "${PID_FILE}")"
  fi
  if ! pid_alive "${pid}"; then
    echo "doctor: preview pid ${pid:-missing} is not alive" >&2
    exit 1
  fi
  listener="$(listening_pid "${VERIFY_PORT}" || true)"
  if [[ -z "${listener}" ]]; then
    echo "doctor: nothing listening on ${VERIFY_PORT}" >&2
    exit 1
  fi
  if ! in_tree "${pid}" "${listener}" && ! in_tree "${listener}" "${pid}"; then
    echo "doctor: listener pid ${listener} is not in the tree of ${pid}" >&2
    exit 1
  fi
  local tmp="${EVIDENCE_DIR}/doctor-home.html"
  local code
  code="$(curl -sS -o "${tmp}" -w "%{http_code}" "${BASE}/" || true)"
  if [[ "${code}" != "200" ]]; then
    echo "doctor: GET / returned ${code}" >&2
    exit 1
  fi
  if ! grep -Fq "Albert's Tech Blog" "${tmp}"; then
    echo "doctor: home HTML missing Albert's Tech Blog" >&2
    exit 1
  fi
  if ! grep -Fq 'lang="zh-CN"' "${tmp}"; then
    echo "doctor: home HTML missing lang=\"zh-CN\"" >&2
    exit 1
  fi
  {
    echo "doctor: ok"
    echo "url: ${BASE}/"
    echo "preview_pid: ${pid}"
    echo "listener_pid: ${listener}"
    echo "port: ${VERIFY_PORT}"
  } | tee "${EVIDENCE_DIR}/doctor.txt"
}

fetch() {
  local name="$1" path="$2"
  local out="${EVIDENCE_DIR}/${name}"
  local hdr="${EVIDENCE_DIR}/${name}.headers"
  local code
  code="$(curl -sS -D "${hdr}" -o "${out}" -w "%{http_code}" "${BASE}${path}" || true)"
  if [[ "${code}" != "200" ]]; then
    fail "${name}: GET ${path} -> ${code} (want 200)"
    echo "FAIL ${name}: GET ${path} -> ${code}" >> "${REPORT}"
    return 1
  fi
  pass "${name}: GET ${path} -> 200"
  echo "PASS ${name}: GET ${path} -> 200" >> "${REPORT}"
}

contains() {
  local name="$1" needle="$2"
  local file="${EVIDENCE_DIR}/${name}"
  if [[ ! -f "${file}" ]]; then
    fail "${name}: missing file while looking for ${needle}"
    echo "FAIL ${name}: missing file for needle ${needle}" >> "${REPORT}"
    return 1
  fi
  if grep -Fq "${needle}" "${file}"; then
    pass "${name}: contains ${needle}"
    echo "PASS ${name}: contains ${needle}" >> "${REPORT}"
  else
    fail "${name}: missing ${needle}"
    echo "FAIL ${name}: missing ${needle}" >> "${REPORT}"
  fi
}

header_contains() {
  local name="$1" needle="$2"
  local file="${EVIDENCE_DIR}/${name}.headers"
  if [[ ! -f "${file}" ]]; then
    fail "${name}: missing headers while looking for ${needle}"
    echo "FAIL ${name}: missing headers for ${needle}" >> "${REPORT}"
    return 1
  fi
  if grep -Fiq "${needle}" "${file}"; then
    pass "${name}: header ${needle}"
    echo "PASS ${name}: header ${needle}" >> "${REPORT}"
  else
    fail "${name}: missing header ${needle}"
    echo "FAIL ${name}: missing header ${needle}" >> "${REPORT}"
  fi
}

drive_home() {
  fetch home.html /
  contains home.html "<title>Albert's Tech Blog</title>"
  contains home.html 'lang="zh-CN"'
  contains home.html "Albert's Tech Blog 首页"
  contains home.html "主导航"
  contains home.html "首页"
  contains home.html "标签"
  contains home.html "搜索"
  contains home.html "关于"
  contains home.html "跳到正文"
  contains home.html "精选文章"
  contains home.html "最新文章"
  contains home.html "© 2026 Albert."
  contains home.html "DualPath：重新利用空闲网卡带宽"
  contains home.html "Mooncake：以 KV Cache 为中心的推理架构"
  contains home.html "ZCube：自动搜索出来的 AI 集群拓扑"
  contains home.html "NCCLX：十万卡 RoCE 上的集合通信重构"
  contains home.html "DeepSeek-V3：受限硬件上的系统协同"
  contains home.html "Aegis：生产 AI 集群的故障诊断演进"
  contains home.html "/posts/dualpath/"
  contains home.html "/posts/mooncake/"
  fetch favicon.svg /favicon.svg
}

drive_article() {
  fetch dualpath.html /posts/dualpath/
  contains dualpath.html "<title>DualPath：重新利用空闲网卡带宽 | Albert's Tech Blog</title>"
  contains dualpath.html "DualPath 深度解读"
  contains dualpath.html "文章目录"
  contains dualpath.html "AI Infra 论文深读"
  contains dualpath.html "38 分钟阅读"
  contains dualpath.html "KV Cache"
  contains dualpath.html "TL;DR"
  fetch mooncake.html /posts/mooncake/
  contains mooncake.html "<title>Mooncake：以 KV Cache 为中心的推理架构 | Albert's Tech Blog</title>"
  contains mooncake.html "Mooncake 深度解读"
  contains mooncake.html "文章目录"
  contains mooncake.html "TL;DR"
}

drive_search() {
  fetch search.html /search/
  contains search.html "<title>搜索 | Albert's Tech Blog</title>"
  contains search.html "<h1>搜索</h1>"
  contains search.html "data-search-input"
  contains search.html "共 6 篇文章"
  contains search.html "DualPath：重新利用空闲网卡带宽"
  contains search.html "Mooncake：以 KV Cache 为中心的推理架构"
  contains search.html "ZCube：自动搜索出来的 AI 集群拓扑"
  contains search.html "NCCLX：十万卡 RoCE 上的集合通信重构"
  contains search.html "DeepSeek-V3：受限硬件上的系统协同"
  contains search.html "Aegis：生产 AI 集群的故障诊断演进"
}

drive_tags() {
  fetch tags.html /tags/
  contains tags.html "<title>标签 | Albert's Tech Blog</title>"
  contains tags.html "<h1>标签</h1>"
  contains tags.html "TOPICS & TAGS"
  contains tags.html "AI Infra"
  contains tags.html "RDMA"
  contains tags.html "High-Performance Networking"
  contains tags.html "/posts/dualpath/"
  contains tags.html "/posts/mooncake/"
  contains tags.html "<h2>AI Infra</h2>"
  contains tags.html "DualPath：重新利用空闲网卡带宽"
}

drive_about() {
  fetch about.html /about/
  contains about.html "<title>关于 Albert | Albert's Tech Blog</title>"
  contains about.html "<h1>关于 Albert</h1>"
  contains about.html "AI Infra · High-Performance Networking · RDMA"
  contains about.html "https://github.com/qiguanping"
  contains about.html "联系方式"
  fetch rss.xml /rss.xml
  header_contains rss.xml "application/rss+xml"
  contains rss.xml '<rss version="2.0">'
  contains rss.xml "/posts/dualpath/"
  contains rss.xml "/posts/mooncake/"
  if grep -Fq "Albert's Tech Blog" "${EVIDENCE_DIR}/rss.xml" || grep -Fq "Albert&apos;s Tech Blog" "${EVIDENCE_DIR}/rss.xml"; then
    pass "rss.xml: contains Albert's Tech Blog (plain or escaped)"
    echo "PASS rss.xml: contains Albert's Tech Blog (plain or escaped)" >> "${REPORT}"
  else
    fail "rss.xml: missing Albert's Tech Blog"
    echo "FAIL rss.xml: missing Albert's Tech Blog" >> "${REPORT}"
  fi
}

cmd_drive() {
  local feature="${1:-baseline}"
  : > "${REPORT}"
  echo "drive: ${feature}" >> "${REPORT}"
  echo "base: ${BASE}" >> "${REPORT}"
  echo "started: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "${REPORT}"
  case "${feature}" in
    home) drive_home ;;
    article) drive_article ;;
    search) drive_search ;;
    tags) drive_tags ;;
    about) drive_about ;;
    baseline|"")
      drive_home
      drive_article
      drive_search
      drive_tags
      drive_about
      ;;
    *)
      echo "error: unknown feature '${feature}'" >&2
      usage >&2
      exit 1
      ;;
  esac
  echo "finished: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "${REPORT}"
  echo "fails: ${FAILS}" >> "${REPORT}"
  if [[ "${FAILS}" -ne 0 ]]; then
    echo "drive failed: ${FAILS} check(s)" >&2
    exit 1
  fi
  log "drive ok: evidence in ${EVIDENCE_DIR}"
}

kill_tree() {
  local pid="$1"
  if ! pid_alive "${pid}"; then
    return 0
  fi
  local child
  for child in $(ps -o pid= --ppid "${pid}" 2>/dev/null || true); do
    kill_tree "${child}"
  done
  kill "${pid}" 2>/dev/null || true
}

cmd_cleanup() {
  local pid=""
  if [[ -f "${PID_FILE}" ]]; then
    pid="$(cat "${PID_FILE}")"
  fi
  if [[ -n "${pid}" ]]; then
    log "cleanup: stopping pid ${pid}"
    kill_tree "${pid}"
    local i
    for i in $(seq 1 20); do
      if ! pid_alive "${pid}"; then
        break
      fi
      sleep 0.1
    done
    if pid_alive "${pid}"; then
      kill -9 "${pid}" 2>/dev/null || true
    fi
  else
    log "cleanup: no preview.pid (nothing started by this run)"
  fi
  rm -f "${PID_FILE}" "${PORT_FILE}"
  if [[ -f "${REPORT}" ]]; then
    log "cleanup: evidence kept at ${REPORT}"
  fi
}

cmd_all() {
  cmd_launch
  cmd_doctor
  cmd_drive baseline
  cmd_cleanup
  if [[ ! -f "${REPORT}" ]]; then
    echo "error: cleanup removed evidence at ${REPORT}" >&2
    exit 1
  fi
  log "all ok: ${REPORT}"
}

cmd="${1:-}"
shift || true
case "${cmd}" in
  launch) cmd_launch ;;
  doctor) cmd_doctor ;;
  drive) cmd_drive "${1:-baseline}" ;;
  cleanup) cmd_cleanup ;;
  all) cmd_all ;;
  -h|--help|help|"") usage ;;
  *)
    echo "error: unknown command '${cmd}'" >&2
    usage >&2
    exit 1
    ;;
esac
