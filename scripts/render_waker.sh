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
declare -a FAILED_ENDPOINTS
declare -i FAILURES=0
RESULTS_FILE="/tmp/waker_results.txt"

# 清空结果文件
> "$RESULTS_FILE"

for i in "${!ENDPOINTS[@]}"; do
  url="${ENDPOINTS[$i]}"
  (
    echo "[INFO] Pinging $url ..."
    if curl --retry 3 --retry-delay 5 --max-time 15 -s -o /dev/null "$url"; then
      echo "SUCCESS:$url" >> "$RESULTS_FILE"
    else
      echo "FAILED:$url" >> "$RESULTS_FILE"
      exit 1
    fi
  ) &
  PIDS+=($!)
done

# 等待所有子进程并检查失败
for i in "${!PIDS[@]}"; do
  pid="${PIDS[$i]}"
  url="${ENDPOINTS[$i]}"
  if ! wait "$pid"; then
    FAILED_ENDPOINTS+=("$url")
    ((FAILURES++))
  fi
done

# 输出详细结果
echo "=== Wake-up Results ==="
while IFS= read -r line; do
  if [[ $line == SUCCESS:* ]]; then
    url="${line#SUCCESS:}"
    echo "✅ $url"
  elif [[ $line == FAILED:* ]]; then
    url="${line#FAILED:}"
    echo "❌ $url"
  fi
done < "$RESULTS_FILE"

# 导出失败的端点供GitHub Actions使用
if (( FAILURES > 0 )); then
  echo "FAILED_ENDPOINTS=${FAILED_ENDPOINTS[*]}" >> "$GITHUB_OUTPUT"
  echo "TOTAL_FAILURES=$FAILURES" >> "$GITHUB_OUTPUT"
  echo "TOTAL_ENDPOINTS=${#ENDPOINTS[@]}" >> "$GITHUB_OUTPUT"
  echo "❌ $FAILURES out of ${#ENDPOINTS[@]} request(s) failed."
  exit 1
else
  echo "✅ All wake-up requests succeeded."
fi
