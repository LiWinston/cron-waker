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

for url in "${ENDPOINTS[@]}"; do
  (
    echo "[INFO] Pinging $url ..."
    curl --retry 3 --retry-delay 5 --max-time 15 -s -o /dev/null -w "[%{http_code}] $url\n" "$url"
  ) &
done

wait

echo "✅ All wake-up requests completed."
