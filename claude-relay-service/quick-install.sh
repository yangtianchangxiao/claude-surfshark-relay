#!/bin/bash

# Claude + Surfshark 快速安装脚本
# 支持单机版和中转服务版

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 检查系统要求
check_requirements() {
    log_info "检查系统要求..."
    
    # 检查操作系统
    if [[ ! -f /etc/os-release ]]; then
        log_error "不支持的操作系统"
        exit 1
    fi
    
    source /etc/os-release
    if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
        log_warning "建议使用 Ubuntu 或 Debian 系统"
    fi
    
    # 检查权限
    if [[ $EUID -ne 0 ]]; then
        log_error "需要 root 权限运行，请使用 sudo"
        exit 1
    fi
    
    # 检查网络连接
    if ! ping -c 1 google.com &> /dev/null; then
        log_error "无法连接到互联网"
        exit 1
    fi
    
    log_success "系统要求检查通过"
}

# 安装基础依赖
install_dependencies() {
    log_info "安装基础依赖..."
    
    apt update
    apt install -y curl wget git jq wireguard tinyproxy redis-server
    
    # 安装 Node.js
    if ! command -v node &> /dev/null || [[ $(node --version | cut -d'v' -f2 | cut -d'.' -f1) -lt 18 ]]; then
        log_info "安装 Node.js LTS..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
        apt install -y nodejs
    fi
    
    log_success "依赖安装完成"
}

# 配置 WireGuard
setup_wireguard() {
    log_info "配置 WireGuard..."
    
    if [[ ! -f "us-dal.conf" ]]; then
        log_error "未找到 us-dal.conf 配置文件"
        log_info "请从 Surfshark 下载 WireGuard 配置文件并重命名为 us-dal.conf"
        exit 1
    fi
    
    cp us-dal.conf /etc/wireguard/wg0.conf
    chmod 600 /etc/wireguard/wg0.conf
    
    systemctl enable wg-quick@wg0
    systemctl start wg-quick@wg0
    
    if systemctl is-active --quiet wg-quick@wg0; then
        log_success "WireGuard 配置完成"
    else
        log_error "WireGuard 启动失败"
        exit 1
    fi
}

# 配置 Tinyproxy
setup_tinyproxy() {
    log_info "配置 Tinyproxy..."
    
    # 创建代理用户
    if ! id "proxyuser" &>/dev/null; then
        useradd -r -s /bin/false proxyuser
    fi
    
    # 备份原配置
    cp /etc/tinyproxy/tinyproxy.conf /etc/tinyproxy/tinyproxy.conf.backup
    
    # 写入新配置
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
    
    systemctl enable tinyproxy
    systemctl restart tinyproxy
    
    if systemctl is-active --quiet tinyproxy; then
        log_success "Tinyproxy 配置完成"
    else
        log_error "Tinyproxy 启动失败"
        exit 1
    fi
}

# 单机版安装
install_standalone() {
    log_info "安装单机版（仅本地使用）..."
    
    setup_wireguard
    setup_tinyproxy
    
    # 配置环境变量
    local bashrc_file=""
    if [[ -n "$SUDO_USER" ]]; then
        bashrc_file="/home/$SUDO_USER/.bashrc"
    else
        bashrc_file="$HOME/.bashrc"
    fi
    
    if [[ -f "$bashrc_file" ]]; then
        grep -q "HTTPS_PROXY" "$bashrc_file" || echo 'export HTTPS_PROXY=http://127.0.0.1:18443' >> "$bashrc_file"
        grep -q "HTTP_PROXY" "$bashrc_file" || echo 'export HTTP_PROXY=$HTTPS_PROXY' >> "$bashrc_file"
        grep -q "ANTHROPIC_BASE_URL" "$bashrc_file" || echo 'export ANTHROPIC_BASE_URL=https://api.anthropic.com' >> "$bashrc_file"
    fi
    
    log_success "单机版安装完成！"
    echo ""
    echo "🎯 使用方法："
    echo "  1. 重新加载环境变量: source ~/.bashrc"
    echo "  2. 使用 Claude: claude \"你好\""
    echo ""
    echo "🔍 验证安装:"
    echo "  curl --proxy http://127.0.0.1:18443 http://ipinfo.io/ip"
}

# 中转服务版安装
install_relay_service() {
    log_info "安装中转服务版（供其他设备使用）..."
    
    setup_wireguard
    setup_tinyproxy
    
    # 设置 Claude Relay Service
    if [[ -d "claude-relay-service" ]]; then
        log_info "配置 Claude Relay Service..."
        cd claude-relay-service
        
        # 安装依赖
        npm install
        
        # 复制配置文件
        cp config/config.example.js config/config.js
        cp .env.example .env
        
        # 修改配置
        sed -i 's/PORT=3000/PORT=3100/' .env
        
        # 确保环境变量设置
        if ! grep -q "HTTPS_PROXY" .env; then
            echo "" >> .env
            echo "# 代理配置" >> .env
            echo "HTTPS_PROXY=http://127.0.0.1:18443" >> .env
            echo "HTTP_PROXY=http://127.0.0.1:18443" >> .env
        fi
        
        # 初始化服务
        npm run setup
        
        # 创建 systemd 服务
        cat > /etc/systemd/system/claude-relay.service << EOF
[Unit]
Description=Claude Relay Service with Surfshark VPN
After=network.target redis.service wg-quick@wg0.service tinyproxy.service
Requires=redis.service wg-quick@wg0.service tinyproxy.service

[Service]
Type=simple
User=$([ -n "$SUDO_USER" ] && echo "$SUDO_USER" || echo "ubuntu")
Group=$([ -n "$SUDO_USER" ] && echo "$SUDO_USER" || echo "ubuntu")
WorkingDirectory=$(pwd)
Environment=NODE_ENV=production
Environment=HTTPS_PROXY=http://127.0.0.1:18443
Environment=HTTP_PROXY=http://127.0.0.1:18443
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
        
        systemctl daemon-reload
        systemctl enable claude-relay.service
        
        cd ..
        
        log_success "Claude Relay Service 配置完成"
    else
        log_error "未找到 claude-relay-service 目录"
        log_info "请确保在正确的项目目录中运行此脚本"
        exit 1
    fi
    
    log_success "中转服务版安装完成！"
    echo ""
    echo "🎯 启动服务:"
    echo "  ./start-relay.sh"
    echo ""
    echo "🌐 Web 管理界面:"
    echo "  http://localhost:3100/admin-next/api-stats"
    echo ""
    echo "🔑 默认登录信息:"
    echo "  用户名: lorland"
    echo "  密码: 5155ch007"
}

# 主菜单
main_menu() {
    echo ""
    echo "🚀 Claude + Surfshark 安装向导"
    echo "================================"
    echo ""
    echo "请选择安装类型："
    echo ""
    echo "1) 单机版 - 仅本地使用 Claude"
    echo "2) 中转服务版 - 供其他设备使用"
    echo "3) 退出"
    echo ""
    read -p "请选择 (1-3): " choice
    
    case $choice in
        1)
            install_standalone
            ;;
        2)
            install_relay_service
            ;;
        3)
            log_info "安装已取消"
            exit 0
            ;;
        *)
            log_error "无效选择"
            main_menu
            ;;
    esac
}

# 验证安装
verify_installation() {
    echo ""
    log_info "验证安装..."
    
    # 检查服务状态
    local services=("wg-quick@wg0" "tinyproxy" "redis")
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            log_success "$service 运行正常"
        else
            log_warning "$service 未运行"
        fi
    done
    
    # 检查网络连接
    echo ""
    log_info "测试网络连接..."
    local current_ip=$(curl -s http://ipinfo.io/ip)
    local proxy_ip=$(curl -s --proxy http://127.0.0.1:18443 http://ipinfo.io/ip)
    
    echo "直连 IP: $current_ip"
    echo "代理 IP: $proxy_ip"
    
    if [[ "$current_ip" != "$proxy_ip" ]]; then
        log_success "代理配置正确"
    else
        log_warning "代理可能未生效"
    fi
}

# 主程序
main() {
    echo "🔧 Claude + Surfshark 快速安装脚本"
    echo "==================================="
    
    check_requirements
    install_dependencies
    main_menu
    verify_installation
    
    echo ""
    log_success "安装完成！"
    echo ""
    echo "📚 完整文档: 查看 COMPLETE_INSTALLATION_GUIDE.md"
    echo "🛠️  管理脚本: ./start-relay.sh, ./stop-relay.sh, ./status-relay.sh"
    echo "🔐 密码管理: ./change-password.sh"
}

# 运行主程序
main "$@"