#!/bin/bash
# 远程服务器上执行的部署脚本
# 由 Jenkins 通过 SSH 调用：ssh user@host "bash -s" < deploy-remote.sh

set -e

ENV=${1:-dev}
APP_NAME="welcome-liuxiang-${ENV}"
JAR_FILE="/opt/app/${APP_NAME}/app.jar"
LOG_DIR="/opt/app/${APP_NAME}/logs"

case "$ENV" in
    dev)  PORT=9090 ;;
    prod) PORT=8081 ;;
    *)    echo "未知环境: $ENV"; exit 1 ;;
esac

mkdir -p "$LOG_DIR"
PID_FILE="/tmp/${APP_NAME}.pid"
LOG_FILE="${LOG_DIR}/app.log"

echo "🚀 远程部署: ${ENV}  端口: ${PORT}"

# 停旧进程
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    kill -0 "$OLD_PID" 2>/dev/null && kill "$OLD_PID" && sleep 2
    rm -f "$PID_FILE"
fi

# 按端口清理残留
PORT_PID=$(lsof -ti:$PORT 2>/dev/null || fuser ${PORT}/tcp 2>/dev/null | awk '{print $1}')
[ -n "$PORT_PID" ] && kill $PORT_PID 2>/dev/null && sleep 3

nohup java -jar "$JAR_FILE" --spring.profiles.active="$ENV" > "$LOG_FILE" 2>&1 &
NEW_PID=$!
echo "$NEW_PID" > "$PID_FILE"
sleep 5

if kill -0 "$NEW_PID" 2>/dev/null; then
    echo "✅ [${ENV}] 远程部署成功  PID=$NEW_PID  → http://<服务器IP>:${PORT}/"
else
    echo "❌ 启动失败: $LOG_FILE"
    tail -20 "$LOG_FILE"
    exit 1
fi
