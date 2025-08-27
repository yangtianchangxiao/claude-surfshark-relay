#!/bin/bash

echo "🚀 新窗口快速初始化..."

# 1. 设置环境变量
export HTTPS_PROXY=http://127.0.0.1:18443
export HTTP_PROXY=$HTTPS_PROXY
export ANTHROPIC_BASE_URL=https://api.anthropic.com

# 2. 显示当前状态
echo "✅ 环境变量已设置："
echo "  HTTPS_PROXY: $HTTPS_PROXY"
echo "  ANTHROPIC_BASE_URL: $ANTHROPIC_BASE_URL"

# 3. 检查服务状态
echo "🔍 检查关键服务..."
if sudo wg show &>/dev/null; then
    echo "  ✅ WireGuard: 运行中"
else
    echo "  ❌ WireGuard: 未运行"
fi

if pgrep tinyproxy &>/dev/null; then
    echo "  ✅ tinyproxy: 运行中"
else
    echo "  ❌ tinyproxy: 未运行"
fi

# 4. 快速测试 Claude CLI
echo "🧪 测试 Claude CLI..."
if claude -p "测试" 2>/dev/null | head -1 | grep -q "Claude"; then
    echo "  ✅ Claude CLI: 工作正常"
else
    echo "  ❌ Claude CLI: 可能有问题"
fi

echo "🎉 新窗口初始化完成！" 