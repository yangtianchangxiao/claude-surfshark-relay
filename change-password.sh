#!/bin/bash

# Claude Relay Service 管理员凭据管理脚本

set -e

cd /home/ubuntu/claude-surfshark-relay/claude-relay-service

INIT_FILE="data/init.json"

# 显示当前凭据
show_credentials() {
    echo "🔑 当前登录凭据:"
    if [ -f "$INIT_FILE" ]; then
        USERNAME=$(jq -r '.adminUsername' "$INIT_FILE" 2>/dev/null || echo "无法读取")
        PASSWORD=$(jq -r '.adminPassword' "$INIT_FILE" 2>/dev/null || echo "无法读取")
        echo "   用户名: $USERNAME"
        echo "   密码: $PASSWORD"
    else
        echo "   ❌ 配置文件不存在: $INIT_FILE"
    fi
    echo ""
}

# 修改凭据
change_credentials() {
    echo "🔧 修改管理员凭据"
    echo "================="
    
    # 显示当前凭据
    show_credentials
    
    # 输入新凭据
    read -p "请输入新用户名 (回车保持不变): " NEW_USERNAME
    read -s -p "请输入新密码 (回车保持不变): " NEW_PASSWORD
    echo ""
    
    # 如果都是空的，退出
    if [ -z "$NEW_USERNAME" ] && [ -z "$NEW_PASSWORD" ]; then
        echo "ℹ️  没有修改任何内容"
        exit 0
    fi
    
    # 备份原文件
    cp "$INIT_FILE" "${INIT_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "✅ 已备份原配置文件"
    
    # 读取当前值
    CURRENT_USERNAME=$(jq -r '.adminUsername' "$INIT_FILE")
    CURRENT_PASSWORD=$(jq -r '.adminPassword' "$INIT_FILE")
    
    # 使用新值或保持原值
    FINAL_USERNAME="${NEW_USERNAME:-$CURRENT_USERNAME}"
    FINAL_PASSWORD="${NEW_PASSWORD:-$CURRENT_PASSWORD}"
    
    # 创建新的配置
    cat > "$INIT_FILE" << EOF
{
  "initializedAt": "$(date -Iseconds)",
  "adminUsername": "$FINAL_USERNAME",
  "adminPassword": "$FINAL_PASSWORD",
  "version": "1.0.0"
}
EOF
    
    echo ""
    echo "✅ 凭据已更新!"
    echo ""
    
    # 显示新凭据
    show_credentials
    
    # 询问是否重启服务
    echo "⚠️  需要重启服务以使更改生效"
    read -p "是否现在重启服务? (y/N): " RESTART
    
    if [[ "$RESTART" =~ ^[Yy]$ ]]; then
        echo ""
        echo "🔄 重启服务..."
        cd ..
        ./restart-relay.sh
    else
        echo ""
        echo "ℹ️  请手动运行 ./restart-relay.sh 重启服务"
    fi
}

# 主菜单
main_menu() {
    echo "🔐 Claude Relay Service - 凭据管理"
    echo "================================="
    echo ""
    echo "1) 显示当前凭据"
    echo "2) 修改凭据"
    echo "3) 退出"
    echo ""
    read -p "请选择操作 (1-3): " CHOICE
    
    case $CHOICE in
        1)
            echo ""
            show_credentials
            read -p "按回车继续..."
            main_menu
            ;;
        2)
            echo ""
            change_credentials
            ;;
        3)
            echo "👋 再见!"
            exit 0
            ;;
        *)
            echo "❌ 无效选择"
            sleep 1
            main_menu
            ;;
    esac
}

# 检查 jq 是否安装
if ! command -v jq &> /dev/null; then
    echo "⚠️  需要安装 jq 工具"
    read -p "是否现在安装? (Y/n): " INSTALL_JQ
    if [[ ! "$INSTALL_JQ" =~ ^[Nn]$ ]]; then
        sudo apt update && sudo apt install -y jq
    else
        echo "❌ 需要 jq 工具才能运行此脚本"
        exit 1
    fi
fi

# 检查配置文件
if [ ! -f "$INIT_FILE" ]; then
    echo "❌ 配置文件不存在: $INIT_FILE"
    echo "请先运行服务初始化"
    exit 1
fi

# 如果有参数，直接执行
if [ "$1" = "show" ]; then
    show_credentials
elif [ "$1" = "change" ]; then
    change_credentials
else
    main_menu
fi