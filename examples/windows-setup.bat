@echo off
REM Claude 中转服务 Windows 配置脚本
REM 请根据你的实际情况修改以下配置

title Claude 中转服务配置

echo ================================================
echo Claude + Surfshark 中转服务 - Windows 客户端配置
echo ================================================
echo.

REM 配置参数 - 请修改为你的实际值
set SERVER_IP=192.168.1.100
set SERVER_PORT=3100
set AUTH_TOKEN=cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1

REM 设置正确的环境变量（注意 /api 路径和 AUTH_TOKEN）
set ANTHROPIC_BASE_URL=http://%SERVER_IP%:%SERVER_PORT%/api
set ANTHROPIC_AUTH_TOKEN=%AUTH_TOKEN%

echo ✅ 环境变量已设置
echo 🌐 服务器地址: %ANTHROPIC_BASE_URL%
echo 🔑 Auth Token: %AUTH_TOKEN:~0,20%...
echo.

REM 测试连接
echo 🧪 测试连接...
echo.

REM 检查 Claude CLI 是否可用
where claude >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 未找到 Claude CLI
    echo 请先安装 Claude Code CLI: https://docs.anthropic.com/en/docs/claude-code
    echo.
    pause
    exit /b 1
)

echo ✅ Claude CLI 已安装
echo.

REM 执行测试
echo 📝 执行测试命令...
claude "请用中文简单回复：你好"

echo.
echo ================================================
echo 🎉 配置完成！
echo.
echo 💡 使用提示:
echo   - 此配置仅在当前命令行窗口有效
echo   - 如需永久配置，请设置系统环境变量
echo   - 服务器IP: %SERVER_IP%
echo   - 服务端口: %SERVER_PORT%
echo.
echo 🔧 常用命令:
echo   claude "你的问题"
echo   claude --help
echo.
echo ================================================

pause