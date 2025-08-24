#!/bin/bash

# Claude Relay Service 状态检查脚本

echo "📊 Claude Relay Service 状态检查"
echo "================================"

cd /home/ubuntu/claude-surfshark-relay/claude-relay-service

# 检查进程状态
echo "🔍 进程状态:"
PIDS=$(pgrep -f "node.*app.js" || true)

if [ -n "$PIDS" ]; then
    echo "✅ 服务正在运行"
    echo "📋 进程信息:"
    ps aux | grep -E "node.*app.js" | grep -v grep | while read line; do
        echo "   $line"
    done
    echo ""
    echo "🆔 进程ID: $PIDS"
    
    # 内存使用情况
    echo ""
    echo "💾 内存使用:"
    for PID in $PIDS; do
        if [ -d "/proc/$PID" ]; then
            RSS=$(cat /proc/$PID/status | grep VmRSS | awk '{print $2, $3}')
            echo "   PID $PID: $RSS"
        fi
    done
else
    echo "❌ 服务未运行"
fi

echo ""

# 检查端口
echo "🌐 端口状态:"
if ss -tlnp | grep -q ":3100"; then
    echo "✅ 端口 3100 正在监听"
    ss -tlnp | grep ":3100"
else
    echo "❌ 端口 3100 未监听"
fi

echo ""

# 检查服务健康状态
echo "🏥 服务健康检查:"
if curl -s --connect-timeout 5 http://localhost:3100/health > /dev/null 2>&1; then
    echo "✅ 服务响应正常"
    echo "📊 健康状态:"
    curl -s http://localhost:3100/health | jq . 2>/dev/null || curl -s http://localhost:3100/health
else
    echo "❌ 服务无响应"
fi

echo ""

# VPN 和代理状态
echo "🔐 VPN & 代理状态:"

# WireGuard
if systemctl is-active --quiet wg-quick@wg0; then
    echo "✅ WireGuard: 运行中"
else
    echo "❌ WireGuard: 未运行"
fi

# Tinyproxy
if systemctl is-active --quiet tinyproxy; then
    echo "✅ Tinyproxy: 运行中 (端口18443)"
else
    echo "❌ Tinyproxy: 未运行"
fi

# Redis
if systemctl is-active --quiet redis; then
    echo "✅ Redis: 运行中"
else
    echo "❌ Redis: 未运行"
fi

echo ""

# 最近的日志
echo "📝 最近日志 (最新10行):"
if [ -f "claude-relay.log" ]; then
    tail -10 claude-relay.log | sed 's/^/   /'
else
    echo "   日志文件不存在"
fi

echo ""
echo "🔗 访问地址:"
echo "   Web界面: http://localhost:3100/admin-next/api-stats"
echo "   API端点: http://localhost:3100/api/v1/messages"
echo "   健康检查: http://localhost:3100/health"

echo ""
echo "🔑 登录信息:"
echo "   用户名: lorland"
echo "   密码: 515ch007"