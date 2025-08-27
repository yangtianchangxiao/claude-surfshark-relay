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