#!/bin/bash

echo "🔍 开始验证 Claude CLI 代理配置..."

# 1. 检查 WireGuard 状态
echo "1. 检查 WireGuard 连接..."
sudo wg show

# 2. 检查 tinyproxy 状态
echo "2. 检查 tinyproxy 进程..."
ps aux | grep tinyproxy | grep -v grep

# 3. 检查路由规则
echo "3. 检查策略路由..."
ip rule list | grep "996-996"

# 4. 检查代理 IP
echo "4. 检查代理 IP 地址..."
curl -x http://127.0.0.1:18443 -s https://ifconfig.me
echo

# 5. 检查环境变量
echo "5. 检查环境变量..."
echo "ANTHROPIC_BASE_URL: $ANTHROPIC_BASE_URL"
echo "HTTPS_PROXY: $HTTPS_PROXY"

# 6. 测试 Claude CLI
echo "6. 测试 Claude CLI..."
claude -p "hello" | head -1

echo "✅ 验证完成！" 