#!/bin/bash

# 启动 Claude Token 自动同步服务

echo "🚀 启动 Claude Token 自动同步服务..."

# 检查是否已有会话运行
if tmux has-session -t claude-token-sync 2>/dev/null; then
    echo "⚠️  同步服务已在运行"
    tmux attach-session -t claude-token-sync
else
    echo "创建新的同步服务会话..."
    tmux new-session -d -s claude-token-sync
    tmux send-keys -t claude-token-sync "cd /home/ubuntu/claude-surfshark-relay/claude-relay-service" Enter
    tmux send-keys -t claude-token-sync "node auto-sync-token.js" Enter
    echo "✅ Token 同步服务已启动"
    echo ""
    echo "📋 服务信息:"
    echo "  - 同步间隔: 5分钟"
    echo "  - 数据源: ~/.claude/.credentials.json"
    echo "  - 目标账户: imported-fixed-1756108350194"
    echo ""
    echo "使用 'tmux attach-session -t claude-token-sync' 查看日志"
fi