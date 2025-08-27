#!/bin/bash

echo "🔍 测试 OAuth 连接..."
echo "========================"

# 设置代理
export HTTPS_PROXY=http://127.0.0.1:18443
export HTTP_PROXY=http://127.0.0.1:18443

# 1. 测试直接连接
echo -e "\n1️⃣ 测试直接连接到 Anthropic API:"
curl -I https://api.anthropic.com/oauth/authorize \
  --connect-timeout 10 \
  -H "User-Agent: claude-cli/1.0.56 (external, cli)" 2>&1 | head -10

# 2. 测试通过代理连接
echo -e "\n2️⃣ 测试通过代理连接:"
curl -x http://127.0.0.1:18443 -I https://api.anthropic.com/oauth/authorize \
  --connect-timeout 10 \
  -H "User-Agent: claude-cli/1.0.56 (external, cli)" 2>&1 | head -10

# 3. 测试 token endpoint
echo -e "\n3️⃣ 测试 OAuth token endpoint:"
curl -x http://127.0.0.1:18443 -I https://api.anthropic.com/oauth/token \
  --connect-timeout 10 \
  -H "User-Agent: claude-cli/1.0.56 (external, cli)" 2>&1 | head -10

# 4. 检查代理状态
echo -e "\n4️⃣ 代理服务状态:"
systemctl is-active tinyproxy && echo "✅ Tinyproxy 运行中" || echo "❌ Tinyproxy 未运行"
systemctl is-active wg-quick@wg0 && echo "✅ WireGuard 运行中" || echo "❌ WireGuard 未运行"

# 5. 测试实际的 token 交换请求
echo -e "\n5️⃣ 测试 token 交换请求（模拟）:"
curl -X POST https://api.anthropic.com/oauth/token \
  -x http://127.0.0.1:18443 \
  --connect-timeout 10 \
  -H "Content-Type: application/json" \
  -H "User-Agent: claude-cli/1.0.56 (external, cli)" \
  -H "Accept: application/json" \
  -d '{"grant_type":"authorization_code","code":"test","redirect_uri":"http://localhost:44511/callback","code_verifier":"test"}' \
  -w "\nHTTP状态码: %{http_code}\n连接时间: %{time_connect}s\n总时间: %{time_total}s\n" \
  2>&1