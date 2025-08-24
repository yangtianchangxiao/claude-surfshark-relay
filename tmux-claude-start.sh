#!/bin/bash
# 一键启动Claude Relay Service在tmux中

# 设置代理环境变量
export HTTPS_PROXY=${HTTPS_PROXY:-http://127.0.0.1:18443}
export HTTP_PROXY=${HTTP_PROXY:-http://127.0.0.1:18443}

echo "🔧 代理配置: HTTPS_PROXY=$HTTPS_PROXY"

# 检查是否已有会话运行
if tmux has-session -t claude-relay 2>/dev/null; then
    echo "Claude Relay 会话已存在，连接中..."
    tmux attach-session -t claude-relay
else
    echo "创建新的 Claude Relay 会话..."
    tmux new-session -d -s claude-relay
    tmux send-keys -t claude-relay "cd /home/ubuntu/claude-surfshark-relay" Enter
    tmux send-keys -t claude-relay "export HTTPS_PROXY=$HTTPS_PROXY" Enter
    tmux send-keys -t claude-relay "export HTTP_PROXY=$HTTP_PROXY" Enter
    tmux send-keys -t claude-relay "./start-relay.sh" Enter
    echo "Claude Relay 已在tmux会话中启动"
    echo "使用 'tmux attach-session -t claude-relay' 连接到会话"
fi