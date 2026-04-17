#!/usr/bin/env bash
# Demo-show：先与 GitHub 同步，再按需提交推送（仅本目录仓库，不会动 26XQ-list 其他需求）
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

GIT_HTTP=(git -c http.version=HTTP/1.1)

echo ">>> [1/2] 从 origin/main 拉取最新（仅 Demo-show 仓库）"
"${GIT_HTTP[@]}" fetch origin 2>/dev/null || true
if "${GIT_HTTP[@]}" pull --rebase origin main; then
  :
else
  "${GIT_HTTP[@]}" pull origin main
fi

if [[ "${1:-}" == "--push" && -n "${2:-}" ]]; then
  MSG="$2"
  shift 2 || true
  echo ">>> [2/2] 暂存、提交并推送"
  if [[ $# -eq 0 ]]; then
    echo "用法: $0 --push \"提交说明\" <文件或目录> …"
    echo "示例: $0 --push \"更新导航\" index.html"
    echo "示例: $0 --push \"新增车务原型\" 车务中心/某个子目录"
    exit 1
  fi
  git add -- "$@"
  if git diff --cached --quiet; then
    echo "没有可提交的变更（已暂存区为空）。"
    exit 0
  fi
  git commit -m "$MSG"
  "${GIT_HTTP[@]}" push origin main
  echo "已推送到 origin/main。"
else
  echo ">>> [2/2] 仅同步完成。若要发布请执行:"
  echo "    $0 --push \"提交说明\" index.html"
  echo "    $0 --push \"提交说明\" index.html 车务中心 智能识别系统"
  exit 0
fi
