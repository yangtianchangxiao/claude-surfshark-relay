#!/bin/bash

# Claude 中转服务 macOS 配置脚本
# 请根据你的实际情况修改以下配置

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置参数 - 请修改为你的实际值
SERVER_IP="192.168.1.100"
SERVER_PORT="3100"
AUTH_TOKEN="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"

echo "================================================"
echo "Claude + Surfshark 中转服务 - macOS 客户端配置"
echo "================================================"
echo ""

# 设置正确的环境变量（注意 /api 路径和 AUTH_TOKEN）
export ANTHROPIC_BASE_URL="http://$SERVER_IP:$SERVER_PORT/api"
export ANTHROPIC_AUTH_TOKEN="$AUTH_TOKEN"

echo -e "${GREEN}✅ 环境变量已设置${NC}"
echo -e "${BLUE}🌐 服务器地址: $ANTHROPIC_BASE_URL${NC}"
echo -e "${BLUE}🔑 Auth Token: ${AUTH_TOKEN:0:20}...${NC}"
echo ""

# 检查 Claude CLI 是否可用
echo -e "${YELLOW}🧪 检查 Claude CLI...${NC}"
if ! command -v claude &> /dev/null; then
    echo -e "${RED}❌ 未找到 Claude CLI${NC}"
    echo "请先安装 Claude Code CLI: https://docs.anthropic.com/en/docs/claude-code"
    echo ""
    echo "安装方法："
    echo "  curl -sSL https://releases.anthropic.com/claude-code/install.sh | bash"
    exit 1
fi

echo -e "${GREEN}✅ Claude CLI 已安装${NC}"
echo ""

# 测试连接
echo -e "${YELLOW}📝 执行测试命令...${NC}"
echo ""

if claude "请用中文简单回复：你好"; then
    echo ""
    echo "================================================"
    echo -e "${GREEN}🎉 配置完成！${NC}"
    echo ""
    echo -e "${BLUE}💡 使用提示:${NC}"
    echo "  - 此配置仅在当前终端会话有效"
    echo "  - 如需永久配置，请运行以下命令："
    echo ""
    echo -e "${YELLOW}    # 对于 zsh (macOS 默认)${NC}"
    echo "    echo 'export ANTHROPIC_BASE_URL=\"$ANTHROPIC_BASE_URL\"' >> ~/.zshrc"
    echo "    echo 'export ANTHROPIC_API_KEY=\"$API_KEY\"' >> ~/.zshrc"
    echo "    source ~/.zshrc"
    echo ""
    echo -e "${YELLOW}    # 对于 bash${NC}"
    echo "    echo 'export ANTHROPIC_BASE_URL=\"$ANTHROPIC_BASE_URL\"' >> ~/.bash_profile"
    echo "    echo 'export ANTHROPIC_API_KEY=\"$API_KEY\"' >> ~/.bash_profile"
    echo "    source ~/.bash_profile"
    echo ""
    echo -e "${BLUE}🔧 常用命令:${NC}"
    echo "  claude \"你的问题\""
    echo "  claude --help"
    echo ""
    echo "================================================"
else
    echo ""
    echo -e "${RED}❌ 连接测试失败${NC}"
    echo ""
    echo -e "${YELLOW}🔍 故障排除:${NC}"
    echo "1. 检查服务器 IP 地址是否正确: $SERVER_IP"
    echo "2. 检查服务器端口是否正确: $SERVER_PORT"
    echo "3. 检查 API Key 是否正确"
    echo "4. 确认服务器服务是否正常运行"
    echo ""
    echo -e "${BLUE}💡 调试命令:${NC}"
    echo "  curl -I http://$SERVER_IP:$SERVER_PORT/health"
    echo "  curl -H \"Authorization: Bearer $API_KEY\" http://$SERVER_IP:$SERVER_PORT/api/v1/me"
    exit 1
fi

# 询问是否永久设置
echo ""
read -p "是否要永久设置这些环境变量？(y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 检测 shell 类型
    if [[ "$SHELL" == *"zsh"* ]]; then
        CONFIG_FILE="$HOME/.zshrc"
        SHELL_NAME="zsh"
    else
        CONFIG_FILE="$HOME/.bash_profile"
        SHELL_NAME="bash"
    fi
    
    echo -e "${YELLOW}📝 添加到 $CONFIG_FILE...${NC}"
    
    # 检查是否已存在配置
    if grep -q "ANTHROPIC_BASE_URL" "$CONFIG_FILE" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  检测到已存在的配置，请手动检查 $CONFIG_FILE${NC}"
    else
        echo "" >> "$CONFIG_FILE"
        echo "# Claude 中转服务配置" >> "$CONFIG_FILE"
        echo "export ANTHROPIC_BASE_URL=\"$ANTHROPIC_BASE_URL\"" >> "$CONFIG_FILE"
        echo "export ANTHROPIC_API_KEY=\"$API_KEY\"" >> "$CONFIG_FILE"
        
        echo -e "${GREEN}✅ 配置已添加到 $CONFIG_FILE${NC}"
        echo -e "${BLUE}💡 重新加载配置: source $CONFIG_FILE${NC}"
    fi
fi

echo ""
echo -e "${GREEN}感谢使用 Claude 中转服务！${NC}"