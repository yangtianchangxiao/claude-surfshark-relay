#!/bin/bash

echo "🔄 重启 Claude CLI 代理服务..."

# 1. 重启 WireGuard
echo "重启 WireGuard..."
sudo systemctl restart wg-quick@wg0

# 2. 重启 tinyproxy  
echo "重启 tinyproxy..."
sudo systemctl restart tinyproxy

# 3. 重新加载环境变量
echo "重新加载环境变量..."
source ~/.bashrc

# 4. 等待服务启动
echo "等待服务启动..."
sleep 3

# 5. 检查状态
echo "检查服务状态..."
sudo systemctl status wg-quick@wg0 --no-pager -l
sudo systemctl status tinyproxy --no-pager -l

echo "✅ 重启完成！" 