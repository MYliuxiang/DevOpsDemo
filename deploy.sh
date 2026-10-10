#!/bin/bash
set -e

export PATH="/usr/bin:/usr/sbin:/opt/homebrew/bin:$PATH"

ENV=${1:-dev}
APP_NAME="welcome-liuxiang-${ENV}"
JAR_FILE="target/demo-0.0.1-SNAPSHOT.jar"

case "$ENV" in
    dev)  PORT=9090 ;;
    prod) PORT=8080 ;;
    *)    echo "未知环境: $ENV (可选: dev, prod)"; exit 1 ;;
esac

PID_FILE="/tmp/${APP_NAME}.pid"
LOG_FILE="/tmp/${APP_NAME}.log"

echo "🚀 部署环境: ${ENV}  端口: ${PORT}"

# 停旧进程
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    kill -0 "$OLD_PID" 2>/dev/null && kill "$OLD_PID" && sleep 2
    rm -f "$PID_FILE"
fi

# 按端口清理
PORT_PID=$(/usr/sbin/lsof -ti:$PORT 2>/dev/null || true)
[ -n "$PORT_PID" ] && kill $PORT_PID 2>/dev/null && sleep 3

nohup /usr/bin/java -jar "$JAR_FILE" --spring.profiles.active="$ENV" > "$LOG_FILE" 2>&1 &
NEW_PID=$!
echo "$NEW_PID" > "$PID_FILE"
sleep 5

if kill -0 "$NEW_PID" 2>/dev/null; then
    echo "✅ [${ENV}] 部署成功  PID=$NEW_PID  → http://localhost:${PORT}/"
else
    echo "❌ 启动失败: $LOG_FILE"
    tail -20 "$LOG_FILE"
    exit 1
fi
