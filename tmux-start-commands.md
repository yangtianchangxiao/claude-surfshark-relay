# Tmux 启动命令

## 启动新的tmux会话并运行Claude Relay Service

```bash
# 创建名为 claude-relay 的tmux会话
tmux new-session -d -s claude-relay

# 进入工作目录并启动服务
tmux send-keys -t claude-relay "cd /home/ubuntu/claude-surfshark-relay" Enter
tmux send-keys -t claude-relay "./start-relay.sh" Enter

# 连接到会话查看状态
tmux attach-session -t claude-relay
```

## 其他有用的tmux命令

```bash
# 查看所有tmux会话
tmux list-sessions

# 重新连接到会话
tmux attach-session -t claude-relay

# 分离会话（Ctrl+B, d）
# 在tmux内按 Ctrl+B 然后按 d

# 停止会话
tmux kill-session -t claude-relay

# 查看服务状态（在新窗口）
tmux new-window -t claude-relay -n status
tmux send-keys -t claude-relay:status "./status-relay.sh" Enter
```

## 一键启动脚本

```bash
#!/bin/bash
# 文件：tmux-claude-start.sh

# 检查是否已有会话运行
if tmux has-session -t claude-relay 2>/dev/null; then
    echo "Claude Relay 会话已存在，连接中..."
    tmux attach-session -t claude-relay
else
    echo "创建新的 Claude Relay 会话..."
    tmux new-session -d -s claude-relay
    tmux send-keys -t claude-relay "cd /home/ubuntu/claude-surfshark-relay" Enter
    tmux send-keys -t claude-relay "./start-relay.sh" Enter
    echo "Claude Relay 已在tmux会话中启动"
    echo "使用 'tmux attach-session -t claude-relay' 连接到会话"
fi
```