#!/bin/bash

set -e

# 定义 User-Agent 列表 (模拟常见浏览器)
USER_AGENTS=(
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0"
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15"
  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
)

# 定义端点数组
ENDPOINTS=(
  "https://huskyAI.bitsleep.cn"
  "https://huskyAI.bitsleep.cn/api/health"
  "https://bitsleep.cn"
  "https://bitsleep.cn/sapi/health/keepalive"
  "https://unity-webgl.onrender.com"
  "https://bitsleep-5zg5.onrender.com"
  # "https://thisdoesnotexist.bitsleep.cn"   # 故意失败用
)

# 定义HTTP方法映射 (关联数组/哈希表)
declare -A HTTP_METHODS
# HTTP_METHODS["https://huskyAI.bitsleep.cn"]="HEAD"
# HTTP_METHODS["https://huskyAI.bitsleep.cn/api/health"]="GET"
HTTP_METHODS["https://bitsleep.cn"]="GET"
HTTP_METHODS["https://bitsleep.cn/sapi/health/keepalive"]="GET"
HTTP_METHODS["https://unity-webgl.onrender.com"]="HEAD"
HTTP_METHODS["https://bitsleep-5zg5.onrender.com"]="GET"
# HTTP_METHODS["https://thisdoesnotexist.bitsleep.cn"]="GET"   # 故意失败用

echo "Starting wake-up requests..."

declare -a PIDS
declare -a FAILED_ENDPOINTS
declare -i FAILURES=0
RESULTS_FILE="/tmp/waker_results.txt"

# 清空结果文件
> "$RESULTS_FILE"

for i in "${!ENDPOINTS[@]}"; do
  url="${ENDPOINTS[$i]}"
  method="${HTTP_METHODS[$url]:-GET}"  # 默认使用GET方法
  (
    # 随机延迟 1-10 秒，避免并发特征过于明显
    sleep_time=$(( ( RANDOM % 10 ) + 1 ))
    sleep "$sleep_time"

    # 随机选择 User-Agent
    ua_index=$((RANDOM % ${#USER_AGENTS[@]}))
    user_agent="${USER_AGENTS[$ua_index]}"

    echo "[INFO] Pinging $url using $method method (UA: ...${user_agent: -20})..."
    
    # 获取HTTP状态码，添加拟人化 Header
    status_code=$(curl -X "$method" \
      -A "$user_agent" \
      -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7" \
      -H "Accept-Language: en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7" \
      -H "Cache-Control: no-cache" \
      -H "Pragma: no-cache" \
      -H "Upgrade-Insecure-Requests: 1" \
      -H "Sec-Fetch-Dest: document" \
      -H "Sec-Fetch-Mode: navigate" \
      -H "Sec-Fetch-Site: none" \
      -H "Sec-Fetch-User: ?1" \
      --retry 3 --retry-delay 5 --max-time 15 -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
    
    echo "[INFO] $url returned status code: $status_code"
    
    # 判断状态码是否表示成功
    if [[ "$status_code" =~ ^[123] ]]; then
      # 1xx (信息性), 2xx (成功), 3xx (重定向) 都认为是成功
      echo "SUCCESS:$url:$status_code" >> "$RESULTS_FILE"
    elif [[ "$status_code" == "000" ]]; then
      # 000 表示网络错误或无法连接
      echo "FAILED:$url:NETWORK_ERROR" >> "$RESULTS_FILE"
      exit 1
    else
      # 4xx (客户端错误), 5xx (服务器错误) 认为是失败
      echo "FAILED:$url:$status_code" >> "$RESULTS_FILE"
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
