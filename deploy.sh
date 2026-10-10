#!/bin/bash
set -e

APP_NAME="welcome-liuxiang"
JAR_FILE="target/demo-0.0.1-SNAPSHOT.jar"
PORT=9090
PID_FILE="/tmp/${APP_NAME}.pid"
LOG_FILE="/tmp/${APP_NAME}.log"

echo "🚀 开始部署 ${APP_NAME}..."

# 停止旧进程（按 PID 文件 + 按端口双重保险）
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "⏹  停止旧进程 PID=$OLD_PID"
        kill "$OLD_PID"
        sleep 3
    fi
    rm -f "$PID_FILE"
fi

# 按端口清理残留进程
PORT_PID=$(lsof -ti:$PORT 2>/dev/null || true)
if [ -n "$PORT_PID" ]; then
    echo "⏹  清理端口 $PORT 占用 PID=$PORT_PID"
    kill $PORT_PID 2>/dev/null || true
    sleep 3
fi

# 确保端口已释放
for i in 1 2 3 4 5; do
    if ! lsof -ti:$PORT >/dev/null 2>&1; then
        break
    fi
    echo "⏳ 等待端口释放... ($i/5)"
    sleep 2
done

# 启动新进程
echo "▶  启动应用..."
nohup java -jar "$JAR_FILE" --server.port="$PORT" > "$LOG_FILE" 2>&1 &
NEW_PID=$!
echo "$NEW_PID" > "$PID_FILE"

sleep 5

# 验证
if kill -0 "$NEW_PID" 2>/dev/null; then
    echo "✅ 部署成功！PID=$NEW_PID  端口=$PORT"
    echo "🌐 访问 http://localhost:${PORT}/"
else
    echo "❌ 启动失败，查看日志: $LOG_FILE"
    tail -20 "$LOG_FILE"
    exit 1
fi
