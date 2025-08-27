#!/bin/bash

# 集成的 Claude Relay Service + Surfshark 代理设置脚本
# 目标：通过特定端口路由Claude流量，不影响SSH连接

set -e

echo "🚀 开始设置 Claude Relay Service + Surfshark 集成方案..."

# 检查是否为root用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "❌ 此脚本需要root权限运行"
        echo "请使用: sudo $0"
        exit 1
    fi
}

# 安装基础依赖
install_dependencies() {
    echo "📦 安装基础依赖..."
    apt update
    apt install -y curl wget git nodejs npm redis-server wireguard tinyproxy
    
    # 确保Node.js版本 >= 18
    node_version=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [[ $node_version -lt 18 ]]; then
        echo "⬆️  更新Node.js到最新LTS版本..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
        apt install -y nodejs
    fi
}

# 设置Surfshark WireGuard连接
setup_wireguard() {
    echo "🔐 配置WireGuard连接..."
    
    # 复制WireGuard配置
    if [[ -f "us-dal.conf" ]]; then
        cp us-dal.conf /etc/wireguard/wg0.conf
        chmod 600 /etc/wireguard/wg0.conf
        echo "✅ WireGuard配置已复制"
    else
        echo "❌ 未找到us-dal.conf文件"
        exit 1
    fi
    
    # 启用和启动WireGuard
    systemctl enable wg-quick@wg0
    systemctl start wg-quick@wg0
    
    # 验证连接
    if wg show wg0 > /dev/null 2>&1; then
        echo "✅ WireGuard连接成功"
    else
        echo "❌ WireGuard连接失败"
        exit 1
    fi
}

# 配置tinyproxy
setup_tinyproxy() {
    echo "🔗 配置tinyproxy代理服务..."
    
    # 备份原配置
    cp /etc/tinyproxy/tinyproxy.conf /etc/tinyproxy/tinyproxy.conf.backup
    
    # 创建代理用户
    if ! id "proxyuser" &>/dev/null; then
        useradd -r -s /bin/false proxyuser
    fi
    
    # 写入tinyproxy配置
    cat > /etc/tinyproxy/tinyproxy.conf << 'EOF'
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
    
    # 创建日志目录
    mkdir -p /var/log/tinyproxy
    chown proxyuser:proxyuser /var/log/tinyproxy
    
    # 启用和启动tinyproxy
    systemctl enable tinyproxy
    systemctl restart tinyproxy
    
    echo "✅ Tinyproxy配置完成，监听端口18443"
}

# 设置Claude Relay Service
setup_claude_relay() {
    echo "🤖 配置Claude Relay Service..."
    
    # 进入项目目录
    cd claude-relay-service
    
    # 安装依赖
    npm install
    
    # 复制配置文件
    cp config/config.example.js config/config.js
    cp .env.example .env
    
    # 生成配置文件内容
    cat > .env << EOF
# 服务器配置
PORT=3100
HOST=0.0.0.0
NODE_ENV=production

# 代理配置 - 使用本地tinyproxy
HTTPS_PROXY=http://127.0.0.1:18443
HTTP_PROXY=http://127.0.0.1:18443

# Redis配置
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_PASSWORD=

# 安全配置（生产环境请修改）
JWT_SECRET=$(openssl rand -hex 32)
ENCRYPTION_KEY=$(openssl rand -hex 16)

# Claude API配置
ANTHROPIC_BASE_URL=https://api.anthropic.com
CLAUDE_API_URL=https://api.anthropic.com/v1/messages

# 日志级别
LOG_LEVEL=info

# Web界面配置
WEB_TITLE=Claude Relay Service via Surfshark
WEB_DESCRIPTION=Multi-account Claude API relay service with Surfshark VPN
EOF
    
    # 初始化服务
    npm run setup
    
    echo "✅ Claude Relay Service配置完成"
}

# 创建系统服务
create_systemd_service() {
    echo "⚙️  创建systemd服务..."
    
    cat > /etc/systemd/system/claude-relay.service << EOF
[Unit]
Description=Claude Relay Service with Surfshark VPN
After=network.target redis.service wg-quick@wg0.service tinyproxy.service
Requires=redis.service wg-quick@wg0.service tinyproxy.service

[Service]
Type=simple
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu/claude-surfshark-relay/claude-relay-service
Environment=NODE_ENV=production
Environment=HTTPS_PROXY=http://127.0.0.1:18443
Environment=HTTP_PROXY=http://127.0.0.1:18443
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    # 重新加载systemd并启用服务
    systemctl daemon-reload
    systemctl enable claude-relay.service
    
    echo "✅ Systemd服务已创建"
}

# 创建管理脚本
create_management_scripts() {
    echo "📝 创建管理脚本..."
    
    # 状态检查脚本
    cat > /home/ubuntu/claude-surfshark-relay/check-status.sh << 'EOF'
#!/bin/bash

echo "🔍 检查系统状态..."

echo "=== WireGuard 状态 ==="
if systemctl is-active --quiet wg-quick@wg0; then
    echo "✅ WireGuard: 运行中"
    wg show wg0
else
    echo "❌ WireGuard: 未运行"
fi

echo -e "\n=== Tinyproxy 状态 ==="
if systemctl is-active --quiet tinyproxy; then
    echo "✅ Tinyproxy: 运行中 (端口18443)"
    ss -tlnp | grep :18443
else
    echo "❌ Tinyproxy: 未运行"
fi

echo -e "\n=== Redis 状态 ==="
if systemctl is-active --quiet redis; then
    echo "✅ Redis: 运行中"
else
    echo "❌ Redis: 未运行"
fi

echo -e "\n=== Claude Relay Service 状态 ==="
if systemctl is-active --quiet claude-relay; then
    echo "✅ Claude Relay Service: 运行中 (端口3000)"
    ss -tlnp | grep :3000
else
    echo "❌ Claude Relay Service: 未运行"
fi

echo -e "\n=== 网络测试 ==="
echo "当前公网IP:"
curl -s --connect-timeout 5 http://ipinfo.io/ip 2>/dev/null || echo "无法获取IP"

echo -e "\n通过代理的IP:"
curl -s --proxy http://127.0.0.1:18443 --connect-timeout 5 http://ipinfo.io/ip 2>/dev/null || echo "代理连接失败"
EOF

    # 重启服务脚本
    cat > /home/ubuntu/claude-surfshark-relay/restart-services.sh << 'EOF'
#!/bin/bash

echo "🔄 重启所有服务..."

sudo systemctl restart wg-quick@wg0
sudo systemctl restart tinyproxy
sudo systemctl restart redis
sudo systemctl restart claude-relay

echo "✅ 所有服务已重启"
echo "等待服务启动..."
sleep 5

./check-status.sh
EOF

    # 停止服务脚本
    cat > /home/ubuntu/claude-surfshark-relay/stop-services.sh << 'EOF'
#!/bin/bash

echo "🛑 停止所有服务..."

sudo systemctl stop claude-relay
sudo systemctl stop tinyproxy
sudo systemctl stop wg-quick@wg0

echo "✅ 服务已停止"
EOF

    # 设置执行权限
    chmod +x /home/ubuntu/claude-surfshark-relay/*.sh
    chown ubuntu:ubuntu /home/ubuntu/claude-surfshark-relay/*.sh
}

# 主函数
main() {
    check_root
    install_dependencies
    setup_wireguard
    setup_tinyproxy
    setup_claude_relay
    create_systemd_service
    create_management_scripts
    
    echo "🎉 集成设置完成！"
    echo ""
    echo "📋 服务信息:"
    echo "  - Claude Relay Service: http://localhost:3100"
    echo "  - Web管理界面: http://localhost:3100/web"
    echo "  - API端点: http://localhost:3100/api/v1/messages"
    echo "  - 代理端口: 18443 (仅Claude流量)"
    echo ""
    echo "🔧 管理命令:"
    echo "  - 检查状态: ./check-status.sh"
    echo "  - 重启服务: ./restart-services.sh"
    echo "  - 停止服务: ./stop-services.sh"
    echo ""
    echo "🔐 重要提醒:"
    echo "  - SSH连接不受影响，使用默认路由"
    echo "  - 只有Claude API流量通过Surfshark代理"
    echo "  - 请记住修改.env中的JWT_SECRET和ENCRYPTION_KEY"
    echo ""
    echo "🚀 启动服务: sudo systemctl start claude-relay"
}

# 运行主函数
main "$@"