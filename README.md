# Claude Surfshark Relay Service

🚀 **Claude Relay Service with Surfshark VPN Integration + Auto OAuth Refresh**

A complete solution for accessing Claude AI through Surfshark VPN proxy with **automatic token refresh** and **long-term stability**. No more manual re-authentication!

## ✨ Key Features

- 🔐 **Automatic OAuth Token Refresh** - Import from local Claude CLI, auto-refresh before expiry
- 🌐 **Surfshark VPN Integration** - Secure proxy routing for Claude API only
- 🔄 **Long-term Stability** - Use Claude Code indefinitely without re-login
- 📊 **Web Management Interface** - Monitor accounts and usage statistics
- 🚧 **SSH-Safe Routing** - Only Claude traffic goes through VPN, SSH unaffected
- 📱 **Multi-Platform Support** - Windows, Linux, macOS client setup

## 🏗️ Architecture

```
Claude Code Client → Relay Service (3100) → Tinyproxy (18443) → Surfshark VPN → Claude API
```

## 🚀 Quick Start Guide

### 1. Prerequisites
- Surfshark VPN with WireGuard configured (`us-dal.conf`)
- Working local Claude CLI (for OAuth import)
- Node.js 16+ and Redis installed

### 2. Install & Setup
```bash
cd /home/ubuntu/claude-surfshark-relay/claude-relay-service
npm install
npm run setup  # Generate admin credentials
```

### 3. **🔑 Import OAuth from Local Claude CLI** (Key Step!)
If you have a working local Claude CLI with valid credentials:
```bash
# This imports your OAuth data including refresh_token for auto-refresh!
node fix-account.js
```

### 4. Start Service with Proxy
```bash
# Start with Surfshark proxy environment
export HTTPS_PROXY=http://127.0.0.1:18443
export HTTP_PROXY=http://127.0.0.1:18443
npm start

# Or use tmux for background running
tmux new-session -d -s claude-relay 'export HTTPS_PROXY=http://127.0.0.1:18443 && export HTTP_PROXY=http://127.0.0.1:18443 && npm start'
```

### 5. Configure Claude Code
**Windows PowerShell:**
```powershell
[Environment]::SetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", "your-cr-api-key", "User")
[Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "http://localhost:3100/api", "User")
```

**Linux/macOS:**
```bash
export ANTHROPIC_AUTH_TOKEN="your-cr-api-key"
export ANTHROPIC_BASE_URL="http://localhost:3100/api"
```

### 6. Verify Setup
- Web Interface: http://localhost:3100/web
- Check accounts have OAuth data with refresh tokens
- Test Claude Code - should work without authentication errors!

## 🔧 服务端点

- **API 端点**: `http://localhost:3100/api/v1/messages`
- **Web 管理界面**: `http://localhost:3100/web`
- **健康检查**: `http://localhost:3100/health`

## 🛠️ 管理命令

```bash
# 检查所有服务状态
./check-status.sh

# 重启所有服务
./restart-services.sh

# 停止所有服务
./stop-services.sh

# 查看日志
journalctl -u claude-relay -f
```

## 🔐 配置说明

### 环境变量

主要配置文件：`claude-relay-service/.env`

```env
# 服务端口
PORT=3100

# 代理配置 - 只有 Claude 流量使用
HTTPS_PROXY=http://127.0.0.1:18443
HTTP_PROXY=http://127.0.0.1:18443

# 安全配置（生产环境请修改）
JWT_SECRET=your-secure-jwt-secret
ENCRYPTION_KEY=your-32-character-key
```

### 端口分配

- **SSH**: 22 (直连，不使用代理)
- **Claude Relay**: 3100
- **Tinyproxy**: 18443
- **Redis**: 6379
- **WireGuard**: 51820

## 📊 使用方式

### 1. Web 界面管理

访问 `http://localhost:3100/web` 进行：
- 添加 Claude 账户（OAuth 认证）
- 创建和管理 API Keys
- 查看使用统计
- 配置代理设置

### 2. API 调用示例

```bash
curl -X POST http://localhost:3100/api/v1/messages \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer cr_your_api_key" \
  -d '{
    "model": "claude-3-sonnet-20240229",
    "max_tokens": 1000,
    "messages": [
      {"role": "user", "content": "Hello, Claude!"}
    ]
  }'
```

### 3. Claude Code CLI 集成

```bash
# 设置环境变量
export ANTHROPIC_BASE_URL="http://localhost:3100"
export ANTHROPIC_API_KEY="cr_your_api_key"

# 使用 Claude Code
claude-code --model claude-3-sonnet-20240229 "Hello!"
```

## 🔍 故障排除

### 检查服务状态

```bash
# 检查各个服务是否运行
systemctl status wg-quick@wg0
systemctl status tinyproxy  
systemctl status redis
systemctl status claude-relay
```

### 网络连接测试

```bash
# 测试 WireGuard 连接
wg show wg0

# 测试代理连接
curl --proxy http://127.0.0.1:18443 http://ipinfo.io/ip

# 测试 Claude Relay Service
curl http://localhost:3100/health
```

### 日志查看

```bash
# Claude Relay Service 日志
journalctl -u claude-relay -f

# Tinyproxy 日志
tail -f /var/log/tinyproxy/tinyproxy.log

# WireGuard 日志
journalctl -u wg-quick@wg0 -f
```

## 🚨 重要提醒

1. **SSH 不受影响**: SSH 连接使用默认路由，不经过 VPN
2. **代理隔离**: 只有 Claude API 流量通过 Surfshark 代理
3. **安全配置**: 请修改 `.env` 中的 `JWT_SECRET` 和 `ENCRYPTION_KEY`
4. **端口冲突**: 确保端口 3100, 18443 未被占用
5. **服务依赖**: Claude Relay 依赖 Redis, WireGuard, Tinyproxy 服务

## 📁 文件结构

```
claude-surfshark-relay/
├── claude-relay-service/          # Claude API 中转服务
├── us-dal.conf                    # WireGuard Surfshark 配置
├── integrated-setup.sh            # 集成安装脚本
├── check-status.sh               # 状态检查脚本
├── restart-services.sh           # 服务重启脚本
├── stop-services.sh              # 服务停止脚本
└── README.md                     # 本文档
```

## 🔄 升级和维护

```bash
# 更新 Claude Relay Service
cd claude-relay-service
git pull
npm install
sudo systemctl restart claude-relay

# 重新生成配置（如有需要）
sudo ./integrated-setup.sh
```