#!/bin/bash

set -e

ENDPOINTS=(
  "https://huskyAI.bitsleep.cn"
  "https://huskyAI.bitsleep.cn/api/health"
  "https://bitsleep.cn"
  "https://unity-webgl.onrender.com"
  "https://bitsleep-5zg5.onrender.com"
  "https://thisdoesnotexist.bitsleep.cn"   # 故意失败用
)

echo "Starting wake-up requests..."

declare -a PIDS
declare -i FAILURES=0

for url in "${ENDPOINTS[@]}"; do
  (
    echo "[INFO] Pinging $url ..."
    curl --retry 3 --retry-delay 5 --max-time 15 -s -o /dev/null "$url"
  ) &
  PIDS+=($!)
done

# 等待所有子进程并检查失败
for pid in "${PIDS[@]}"; do
  if ! wait "$pid"; then
    ((FAILURES++))
  fi
done

if (( FAILURES > 0 )); then
  echo "❌ $FAILURES request(s) failed."
  exit 1
else
  echo "✅ All wake-up requests succeeded."
fi
