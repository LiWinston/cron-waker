#!/bin/bash

set -e

ENDPOINTS=(
  "https://huskyAI.bitsleep.cn"
  "https://huskyAI.bitsleep.cn/api/health"
  "https://bitsleep.cn"
  "https://unity-webgl.onrender.com"
  "https://bitsleep-5zg5.onrender.com"
)

echo "Starting wake-up requests..."

declare -a FAILED_URLS=()
declare -a PIDS=()
declare -i FAILURES=0

for url in "${ENDPOINTS[@]}"; do
  (
    echo "[INFO] Pinging $url ..."
    if ! curl --retry 3 --retry-delay 5 --max-time 15 -s -o /dev/null "$url"; then
      echo "$url" >> failed_urls.txt
    fi
  ) &
  PIDS+=($!)
done

# 等待所有子进程
for pid in "${PIDS[@]}"; do
  wait "$pid" || true
done

# 汇总失败 URL
if [[ -f failed_urls.txt ]]; then
  mapfile -t FAILED_URLS < failed_urls.txt
  FAILURES=${#FAILED_URLS[@]}
fi

# 生成邮件正文（可供外部读取）
if (( FAILURES > 0 )); then
  {
    echo "GitHub Actions Render Wake-up Job failed."
    echo ""
    echo "❌ Failed endpoints:"
    echo ""
    for url in "${FAILED_URLS[@]}"; do
      echo "- $url"
      echo "  👉 Manual Wakeup: $url"
      echo ""
    done
    echo "📋 Full logs: $GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
  } > mail_body.txt
  exit 1
else
  echo "✅ All wake-up requests succeeded."
fi
