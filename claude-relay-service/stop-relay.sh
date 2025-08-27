#!/bin/bash

# Claude Relay Service 停止脚本

echo "🛑 停止 Claude Relay Service..."

cd /home/ubuntu/claude-surfshark-relay/claude-relay-service

# 查找并停止进程
PIDS=$(pgrep -f "node.*app.js" || true)

if [ -z "$PIDS" ]; then
    echo "ℹ️  服务未在运行"
    exit 0
fi

echo "🔍 找到进程: $PIDS"

# 优雅停止
echo "📤 发送 SIGTERM 信号..."
for PID in $PIDS; do
    kill -TERM $PID 2>/dev/null || true
done

# 等待进程结束
echo "⏳ 等待进程结束..."
sleep 3

# 检查是否还在运行
REMAINING=$(pgrep -f "node.*app.js" || true)

if [ -n "$REMAINING" ]; then
    echo "💀 强制结束进程..."
    for PID in $REMAINING; do
        kill -9 $PID 2>/dev/null || true
    done
    sleep 1
fi

# 最终检查
if pgrep -f "node.*app.js" > /dev/null; then
    echo "❌ 停止失败，仍有进程在运行"
    ps aux | grep -E "node.*app.js" | grep -v grep
    exit 1
else
    echo "✅ Claude Relay Service 已停止"
fi