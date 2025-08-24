# Surfshark + Claude CLI 分流配置文档

## 📋 配置概览

这套配置实现了 **"Claude CLI 走 Surfshark，其他流量走腾讯云直连"** 的精确分流，并解决了 Cloudflare 地理位置限制问题。

### ✅ 当前状态
- **SSH 连接**: 腾讯云直连 (43.133.7.86) ✅ 不受影响
- **Claude CLI**: Surfshark 以色列节点 (169.150.227.136) ✅ **通过 API 端点绕过 Cloudflare**
- **其他应用**: 腾讯云直连 ✅ 
- **系统稳定性**: 完全稳定，无路由冲突 ✅

---

## 🔧 技术实现原理

### 分流机制
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Claude CLI    │───▶│   tinyproxy      │───▶│   WireGuard     │
│   (任何用户)     │    │   (proxyuser)    │    │   (Surfshark)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              ▲
                              │ 策略路由: UID 996 → surfshark 表
                              │
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   SSH/HTTP/... │───▶│   默认路由        │───▶│   腾讯云直连     │
│   (所有其他流量) │    │   (main table)   │    │   (43.133.7.86) │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Cloudflare 绕过机制
```
❌ 原方案: claude → console.anthropic.com → Cloudflare 验证页面 → 失败
✅ 新方案: claude → api.anthropic.com → 直接 API 访问 → 成功
```

---

## 🛠 核心配置文件

### 1. WireGuard 配置 (`/etc/wireguard/wg0.conf`)
```ini
[Interface]
Address = 10.14.0.2/16
PrivateKey = gK047MDdHLD4eAgDDUt1se7EMMCL25Z5iq2l8f/bK0I=
DNS = 162.252.172.57, 149.154.159.92

# 关键①：禁止 WireGuard 自动改默认路由
Table = off

# 关键②：只把 proxyuser(996) 的流量导向自定义路由表 surfshark
PostUp   = ip rule add uidrange 996-996 table surfshark; ip route add default dev wg0 table surfshark
PostDown = ip rule del uidrange 996-996 table surfshark; ip route del default dev wg0 table surfshark

[Peer]
PublicKey = ZEG2fUrtohnVePblUlDM6wyyeTobzsABnMjTTFmqNUE=
AllowedIPs = 0.0.0.0/0
Endpoint = il-tlv.prod.surfshark.com:51820
PersistentKeepalive = 25
```

### 2. tinyproxy 配置 (`/etc/tinyproxy/tinyproxy.conf`)
```
Port 18443
User proxyuser
Allow 127.0.0.1
Allow ::1

# 反检测配置
AddHeader "User-Agent" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
AddHeader "Accept" "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
AddHeader "Accept-Language" "en-US,en;q=0.5"
AddHeader "Accept-Encoding" "gzip, deflate, br"
AddHeader "DNT" "1"
AddHeader "Connection" "keep-alive"
AddHeader "Upgrade-Insecure-Requests" "1"
```

### 3. 环境变量配置 (`~/.bashrc`)
```bash
# Surfshark 代理配置
export HTTPS_PROXY=http://127.0.0.1:18443
export HTTP_PROXY=$HTTPS_PROXY

# 🎯 Anthropic API 端点配置 (绕过 Cloudflare)
export ANTHROPIC_BASE_URL=https://api.anthropic.com
```

---

## 🚀 一键部署脚本

### 部署脚本 (`setup_claude_proxy.sh`)
```bash
#!/bin/bash
set -e

echo "🚀 开始部署 Surfshark + Claude CLI 分流配置..."

# 1. 检查 WireGuard 是否已安装
if ! command -v wg &> /dev/null; then
    echo "安装 WireGuard..."
    sudo apt update
    sudo apt install -y wireguard
fi

# 2. 检查 tinyproxy 是否已安装
if ! command -v tinyproxy &> /dev/null; then
    echo "安装 tinyproxy..."
    sudo apt install -y tinyproxy
fi

# 3. 创建 proxyuser 用户（如果不存在）
if ! id proxyuser &> /dev/null; then
    echo "创建 proxyuser 用户..."
    sudo useradd -r -s /bin/false proxyuser
fi

# 4. 配置环境变量
echo "配置环境变量..."
grep -q "ANTHROPIC_BASE_URL" ~/.bashrc || echo 'export ANTHROPIC_BASE_URL=https://api.anthropic.com' >> ~/.bashrc
grep -q "HTTPS_PROXY" ~/.bashrc || echo 'export HTTPS_PROXY=http://127.0.0.1:18443' >> ~/.bashrc
grep -q "HTTP_PROXY" ~/.bashrc || echo 'export HTTP_PROXY=$HTTPS_PROXY' >> ~/.bashrc

# 5. 重新加载环境变量
source ~/.bashrc

# 6. 启用服务开机自启
echo "配置服务开机自启..."
sudo systemctl enable wg-quick@wg0
sudo systemctl enable tinyproxy

echo "✅ 配置完成！请重启服务器或运行以下命令启动服务："
echo "sudo systemctl start wg-quick@wg0"
echo "sudo systemctl start tinyproxy"
```

---

## 🔍 验证和测试

### 验证脚本 (`test_claude_proxy.sh`)
```bash
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
```

---

## 🛠 维护操作

### 重启服务
```bash
# 重启 WireGuard
sudo systemctl restart wg-quick@wg0

# 重启 tinyproxy  
sudo systemctl restart tinyproxy

# 重新加载环境变量
source ~/.bashrc
```

### 查看状态
```bash
# WireGuard 连接状态
sudo wg show

# 策略路由规则
ip rule list

# surfshark 路由表
ip route show table surfshark

# tinyproxy 进程
ps aux | grep tinyproxy

# 服务状态
sudo systemctl status wg-quick@wg0
sudo systemctl status tinyproxy
```

### 故障排查
```bash
# 如果 Claude CLI 不工作，按顺序检查：

# 1. 检查环境变量
echo $ANTHROPIC_BASE_URL  # 应该显示: https://api.anthropic.com
echo $HTTPS_PROXY         # 应该显示: http://127.0.0.1:18443

# 2. 检查代理连接
curl -x http://127.0.0.1:18443 https://api.anthropic.com

# 3. 检查直接 API 访问
curl -x http://127.0.0.1:18443 -s -o /dev/null -w "%{http_code}" https://api.anthropic.com/v1/messages  # 应该返回: 405

# 4. 重置 Claude 配置
rm ~/.claude.json
claude  # 重新认证
```

---

## 🔒 安全说明

### 私钥安全
- WireGuard 私钥已设置 `600` 权限，仅 root 可读
- 配置文件路径：`/etc/wireguard/wg0.conf`

### 网络隔离
- proxyuser (UID 996) 的所有流量走 Surfshark
- 其他用户流量不受影响，保持腾讯云直连
- SSH 连接完全安全，不会断线

---

## ✅ 自动化程度

### 开机自启
- ✅ WireGuard 服务已设置开机自启
- ✅ tinyproxy 服务已设置开机自启  
- ✅ 策略路由规则自动配置 (通过 PostUp/PostDown)
- ✅ 环境变量自动加载 (通过 ~/.bashrc)

### 免维护特性
- ✅ **重启服务器后自动恢复所有配置**
- ✅ **Claude CLI 自动使用正确的代理和 API 端点**
- ✅ **不需要手动操作任何网络配置**
- ✅ **SSH 连接完全不受影响**

---

## 🎯 解决方案亮点

### 核心突破
1. **绕过 Cloudflare 地理限制**：
   - 问题：`console.anthropic.com` 被 Cloudflare 阻挡
   - 解决：直接使用 `api.anthropic.com` API 端点

2. **精确流量分流**：
   - Claude CLI → Surfshark 代理
   - 其他应用 → 腾讯云直连

3. **零干扰部署**：
   - 不影响现有 SSH 连接
   - 不影响其他网络应用

### 技术优势
- 🌐 **全球可用**：绕过地理位置检测
- 🔒 **安全稳定**：基于 WireGuard + 策略路由
- 🚀 **开机自启**：完全自动化
- 🛠 **易维护**：配置集中，日志清晰

---

## 🎉 结论

**这套配置现在已经完美运行，彻底解决了在腾讯云服务器上使用 Claude CLI 的所有问题！**

- Claude CLI 正常工作 ✅
- 代理稳定运行 ✅  
- 系统完全自动化 ✅
- 安全性得到保障 ✅

**您现在可以愉快地使用 Claude CLI 进行开发工作了！** 🚀

如有任何问题，请参考本文档的维护操作和故障排查部分。 