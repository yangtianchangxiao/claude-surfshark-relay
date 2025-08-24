# Claude + Surfshark 中转服务完整安装指南

这是一个完整的安装和使用教程，包含两种部署方式：单机版和中转服务版。

## 📑 目录

1. [系统要求](#系统要求)
2. [方式一：单机版（仅本地使用）](#方式一单机版仅本地使用)
3. [方式二：中转服务版（供其他设备使用）](#方式二中转服务版供其他设备使用)
4. [客户端配置](#客户端配置)
5. [故障排除](#故障排除)
6. [管理命令](#管理命令)

---

## 系统要求

- **操作系统**: Ubuntu 20.04+ / Debian 11+
- **内存**: 最低 2GB，推荐 4GB
- **存储**: 至少 10GB 可用空间
- **网络**: 可访问互联网
- **权限**: sudo 权限
- **依赖**: Node.js 18+, Redis, WireGuard

---

## 方式一：单机版（仅本地使用）

### 1.1 下载配置文件

首先需要获取 Surfshark WireGuard 配置文件：

1. 登录 [Surfshark 账户](https://my.surfshark.com/)
2. 进入 **VPN** → **手动设置** → **WireGuard**
3. 选择服务器位置（推荐美国达拉斯）
4. 下载 `.conf` 配置文件
5. 将文件重命名为 `us-dal.conf`

### 1.2 快速安装

```bash
# 1. 创建工作目录
mkdir -p ~/claude-surfshark
cd ~/claude-surfshark

# 2. 上传配置文件
# 将下载的 us-dal.conf 文件上传到当前目录

# 3. 运行安装脚本
curl -fsSL https://raw.githubusercontent.com/your-repo/claude-surfshark-setup.sh | bash
```

### 1.3 手动安装步骤

如果prefer手动安装：

```bash
# 1. 安装依赖
sudo apt update
sudo apt install -y wireguard tinyproxy

# 2. 配置 WireGuard
sudo cp us-dal.conf /etc/wireguard/wg0.conf
sudo chmod 600 /etc/wireguard/wg0.conf

# 3. 创建代理用户
sudo useradd -r -s /bin/false proxyuser

# 4. 配置 Tinyproxy
sudo tee /etc/tinyproxy/tinyproxy.conf > /dev/null << 'EOF'
User proxyuser
Group proxyuser
Port 18443
Listen 127.0.0.1
Timeout 600
DefaultErrorFile "/usr/share/tinyproxy/default.html"
StatFile "/usr/share/tinyproxy/stats.html"
LogFile "/var/log/tinyproxy/tinyproxy.log"
LogLevel Info
PidFile "/run/tinyproxy/tinyproxy.pid"
MaxClients 100
MinSpareServers 5
MaxSpareServers 20
StartServers 10
MaxRequestsPerChild 0
Allow 127.0.0.1
Allow ::1
DisableViaHeader Yes
EOF

# 5. 创建日志目录
sudo mkdir -p /var/log/tinyproxy
sudo chown proxyuser:proxyuser /var/log/tinyproxy

# 6. 启动服务
sudo systemctl enable wg-quick@wg0 tinyproxy
sudo systemctl start wg-quick@wg0 tinyproxy

# 7. 配置环境变量
echo 'export HTTPS_PROXY=http://127.0.0.1:18443' >> ~/.bashrc
echo 'export HTTP_PROXY=$HTTPS_PROXY' >> ~/.bashrc
echo 'export ANTHROPIC_BASE_URL=https://api.anthropic.com' >> ~/.bashrc
source ~/.bashrc
```

### 1.4 验证安装

```bash
# 检查服务状态
systemctl status wg-quick@wg0 tinyproxy

# 检查网络连接
curl --proxy http://127.0.0.1:18443 http://ipinfo.io/ip

# 测试 Claude
claude "Hello"
```

---

## 方式二：中转服务版（供其他设备使用）

### 2.1 基础环境准备

```bash
# 1. 安装基础依赖
sudo apt update
sudo apt install -y curl wget git nodejs npm redis-server wireguard tinyproxy jq

# 2. 确保 Node.js 版本 >= 18
node_version=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [[ $node_version -lt 18 ]]; then
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo bash -
    sudo apt install -y nodejs
fi
```

### 2.2 下载和配置

```bash
# 1. 克隆项目
git clone https://github.com/your-repo/claude-surfshark-relay.git
cd claude-surfshark-relay

# 2. 上传 Surfshark 配置文件
# 将 us-dal.conf 文件放到项目根目录

# 3. 运行集成安装脚本
sudo chmod +x integrated-setup.sh
sudo ./integrated-setup.sh
```

### 2.3 手动配置（高级用户）

如果需要手动配置：

```bash
# 1. 配置 WireGuard
sudo cp us-dal.conf /etc/wireguard/wg0.conf
sudo chmod 600 /etc/wireguard/wg0.conf
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0

# 2. 配置 Tinyproxy（同方式一）

# 3. 安装 Claude Relay Service
cd claude-relay-service
npm install
cp config/config.example.js config/config.js
cp .env.example .env

# 4. 修改配置
nano .env
# 设置：
# PORT=3100
# HTTPS_PROXY=http://127.0.0.1:18443
# HTTP_PROXY=http://127.0.0.1:18443

# 5. 初始化服务
npm run setup

# 6. 启动服务
npm start
```

### 2.4 服务管理

使用提供的管理脚本：

```bash
# 启动服务
./start-relay.sh

# 停止服务
./stop-relay.sh

# 重启服务
./restart-relay.sh

# 查看状态
./status-relay.sh

# 修改管理员密码
./change-password.sh
```

---

## 客户端配置

### 3.1 获取 API Key

1. 访问服务器 Web 界面：`http://服务器IP:3100/admin-next/api-stats`
2. 使用管理员账户登录：
   - 用户名：`lorland`
   - 密码：`5155ch007`
3. 添加 Claude 账户：
   - 选择 **Claude** 平台
   - 选择 **OAuth 授权**
   - 完成授权流程
4. 创建 API Key：
   - 进入 **API Keys** 页面
   - 点击 **创建新 API Key**
   - 复制生成的密钥（格式：`cr_xxx...`）

### 3.2 Windows 客户端配置

#### 方法一：PowerShell 永久设置（推荐 ✅）

```powershell
# 设置用户级环境变量（永久生效）
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "http://服务器IP:3100/api", [System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", "cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1", [System.EnvironmentVariableTarget]::User)

# 设置执行策略（如需要）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 重新打开 PowerShell，然后测试
claude "你好"
```

#### 方法二：PowerShell 临时设置（当前会话）

```powershell
# 设置临时环境变量
$env:ANTHROPIC_BASE_URL = "http://服务器IP:3100/api"
$env:ANTHROPIC_AUTH_TOKEN = "cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"

# 使用 Claude
claude "你好"
```

#### 方法三：系统环境变量设置

1. 按 `Win + R`，输入 `sysdm.cpl`
2. 点击 **环境变量**
3. 在 **用户变量** 中添加：
   - 变量名：`ANTHROPIC_BASE_URL`
   - 变量值：`http://服务器IP:3100`
   - 变量名：`ANTHROPIC_API_KEY`
   - 变量值：`cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1`

### 3.3 macOS 客户端配置

```bash
# 临时设置
export ANTHROPIC_BASE_URL="http://服务器IP:3100"
export ANTHROPIC_API_KEY="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"

# 永久设置（添加到 ~/.zshrc 或 ~/.bash_profile）
echo 'export ANTHROPIC_BASE_URL="http://服务器IP:3100"' >> ~/.zshrc
echo 'export ANTHROPIC_API_KEY="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"' >> ~/.zshrc
source ~/.zshrc
```

### 3.4 Linux 客户端配置

```bash
# 临时设置
export ANTHROPIC_BASE_URL="http://服务器IP:3100"
export ANTHROPIC_API_KEY="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"

# 永久设置
echo 'export ANTHROPIC_BASE_URL="http://服务器IP:3100"' >> ~/.bashrc
echo 'export ANTHROPIC_API_KEY="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"' >> ~/.bashrc
source ~/.bashrc
```

---

## 故障排除

### 4.1 常见问题

#### 服务无法启动

```bash
# 检查端口占用
sudo lsof -i :3100
sudo lsof -i :18443

# 检查服务状态
systemctl status wg-quick@wg0 tinyproxy redis

# 查看日志
journalctl -u wg-quick@wg0 -f
tail -f /var/log/tinyproxy/tinyproxy.log
tail -f claude-relay-service/claude-relay.log
```

#### OAuth 授权失败

```bash
# 检查代理连接
curl -x http://127.0.0.1:18443 https://console.anthropic.com/v1/oauth/token

# 重启代理服务
sudo systemctl restart tinyproxy wg-quick@wg0

# 查看详细日志
tail -f claude-relay-service/logs/claude-relay-$(date +%Y-%m-%d).log
```

#### API 调用失败

```bash
# 测试 API 连接
curl -X POST http://localhost:3100/api/v1/messages \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer 你的API密钥" \
  -d '{"model": "claude-sonnet-4-20250514", "max_tokens": 100, "messages": [{"role": "user", "content": "Hello"}]}'

# 检查账户状态
./status-relay.sh
```

### 4.2 网络诊断

```bash
# 运行网络诊断
./test-oauth-connection.sh

# 检查 VPN 连接
wg show wg0
curl --proxy http://127.0.0.1:18443 http://ipinfo.io/ip
```

---

## 管理命令

### 5.1 服务管理

```bash
# 启动所有服务
./start-relay.sh

# 停止所有服务
./stop-relay.sh

# 重启所有服务
./restart-relay.sh

# 查看服务状态
./status-relay.sh
```

### 5.2 密码管理

```bash
# 修改管理员密码
./change-password.sh

# 显示当前凭据
./change-password.sh show
```

### 5.3 监控和日志

```bash
# 实时查看日志
tail -f claude-relay-service/claude-relay.log

# 查看错误日志
tail -f claude-relay-service/logs/claude-relay-error-$(date +%Y-%m-%d).log

# 查看使用统计
curl -s http://localhost:3100/health | jq .
```

### 5.4 备份和恢复

```bash
# 备份重要配置
tar -czf claude-backup-$(date +%Y%m%d).tar.gz \
  us-dal.conf \
  claude-relay-service/data/ \
  claude-relay-service/.env \
  /etc/wireguard/wg0.conf \
  /etc/tinyproxy/tinyproxy.conf

# 恢复配置（示例）
tar -xzf claude-backup-20250816.tar.gz
# 然后手动复制配置文件到对应位置
```

---

## 🎯 快速参考

### 常用端口

- **SSH**: 22（不受影响）
- **Claude Relay**: 3100
- **Tinyproxy**: 18443
- **Redis**: 6379
- **WireGuard**: 51820

### 重要文件路径

- **WireGuard 配置**: `/etc/wireguard/wg0.conf`
- **Tinyproxy 配置**: `/etc/tinyproxy/tinyproxy.conf`
- **Claude Relay 配置**: `claude-relay-service/.env`
- **管理员凭据**: `claude-relay-service/data/init.json`

### 环境变量模板

```bash
# 服务器端
export HTTPS_PROXY=http://127.0.0.1:18443
export HTTP_PROXY=$HTTPS_PROXY
export ANTHROPIC_BASE_URL=https://api.anthropic.com

# 客户端
export ANTHROPIC_BASE_URL="http://服务器IP:3100"
export ANTHROPIC_API_KEY="cr_你的API密钥"
```

---

## 📞 技术支持

如遇到问题，请：

1. 查看 [故障排除](#故障排除) 部分
2. 运行诊断脚本：`./test-oauth-connection.sh`
3. 检查日志文件
4. 提供错误信息和系统环境

**注意**：请勿在公共平台分享你的 API Key 或配置文件！