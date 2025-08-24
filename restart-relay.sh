#!/bin/bash

# Claude Relay Service 重启脚本

echo "🔄 重启 Claude Relay Service..."

cd /home/ubuntu/claude-surfshark-relay

# 停止服务
echo "1️⃣ 停止现有服务..."
./stop-relay.sh

# 等待一下
sleep 2

# 启动服务
echo "2️⃣ 启动服务..."
./start-relay.sh