#!/bin/bash

# Claude Relay Service 启动脚本

set -e

echo "🚀 启动 Claude Relay Service..."

cd /home/ubuntu/claude-surfshark-relay/claude-relay-service

# 检查服务是否已经在运行
if pgrep -f "node.*app.js" > /dev/null; then
    echo "⚠️  服务已经在运行中"
    echo "📊 服务状态:"
    ps aux | grep -E "node.*app.js" | grep -v grep
    exit 1
fi

# 设置代理环境变量
export HTTPS_PROXY=http://127.0.0.1:18443
export HTTP_PROXY=http://127.0.0.1:18443
export NO_PROXY=localhost,127.0.0.1

# 启动服务
echo "▶️  启动服务..."
nohup npm start > claude-relay.log 2>&1 &
PID=$!

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 5

# 检查服务是否成功启动
if pgrep -f "node.*app.js" > /dev/null; then
    echo "✅ Claude Relay Service 启动成功！"
    echo ""
    echo "📋 服务信息:"
    echo "  - PID: $(pgrep -f 'node.*app.js')"
    echo "  - 端口: 3100"
    echo "  - Web界面: http://localhost:3100/admin-next/api-stats"
    echo "  - API端点: http://localhost:3100/api/v1/messages"
    echo ""
    echo "🔑 登录信息:"
    echo "  - 用户名: lorland"
    echo "  - 密码: 515ch007"
    echo ""
    echo "📝 查看日志: tail -f claude-relay.log"
else
    echo "❌ 服务启动失败"
    echo "📝 查看错误日志:"
    tail -20 claude-relay.log
    exit 1
fi