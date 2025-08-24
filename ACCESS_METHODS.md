# Claude Relay Service 访问方式

## 🌐 当前可用的访问方式

### 1. 直接端口访问（推荐 ✅）

**本地访问（在服务器上）:**
```bash
ANTHROPIC_BASE_URL=http://localhost:3100/api
ANTHROPIC_AUTH_TOKEN=cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1
```

**远程访问（从其他设备）:**
```bash
ANTHROPIC_BASE_URL=http://43.133.7.86:3100/api
ANTHROPIC_AUTH_TOKEN=cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1
```

### 2. 域名访问

**HTTP 域名访问:**
```bash
ANTHROPIC_BASE_URL=http://claudecode.polypredict.online/api
ANTHROPIC_AUTH_TOKEN=cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1
```

## 🚀 服务启动和管理

### Tmux 会话管理
```bash
# 一键启动（使用专用脚本）
./tmux-claude-start.sh

# 手动启动
tmux new-session -d -s claude-relay
tmux send-keys -t claude-relay "cd /home/ubuntu/claude-surfshark-relay && ./start-relay.sh" Enter
tmux attach-session -t claude-relay

# 连接到现有会话
tmux attach-session -t claude-relay

# 查看所有会话
tmux list-sessions

# 停止会话
tmux kill-session -t claude-relay
```

### 服务状态检查
```bash
# 检查详细状态
./status-relay.sh

# 检查健康状态
curl http://localhost:3100/health

# 检查运行进程
ps aux | grep node | grep 3100
```

## 🔗 端口配置

- **3100**: Claude Relay Service（直接访问）
- **80**: HTTP域名代理（claudecode.polypredict.online → 3100）
- **22**: SSH（不受影响）
- **其他端口**: 可用于其他web应用

## 🛡️ 网络架构

```
客户端设备
    ↓
[选择访问方式]
    ↓
┌─────────────────┬─────────────────┐
│   直接端口访问   │    域名访问      │
│   :3100         │   :80           │
└─────────────────┴─────────────────┘
    ↓                     ↓
    └─────────┬───────────┘
              ↓
    Claude Relay Service (3100)
              ↓
    Tinyproxy (18443) + WireGuard
              ↓
         Surfshark VPN
              ↓
         Claude API
```

## ⚙️ 配置文件位置

- **Nginx配置**: `/etc/nginx/sites-available/claudecode.conf`
- **Relay Service配置**: `/home/ubuntu/claude-surfshark-relay/claude-relay-service/.env`
- **启动脚本**: `/home/ubuntu/claude-surfshark-relay/start-relay.sh`
- **Tmux脚本**: `/home/ubuntu/claude-surfshark-relay/tmux-claude-start.sh`