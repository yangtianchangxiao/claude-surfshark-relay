@echo off
REM Claude 中转服务 Windows 快速配置脚本（PowerShell 版本）
REM 本脚本将自动设置永久环境变量

title Claude 中转服务快速配置

echo ================================================
echo Claude + Surfshark 中转服务 - Windows 快速配置
echo ================================================
echo.

REM 配置参数 - 请根据实际情况修改
REM 方式1：直接端口访问（推荐）
set "SERVER_IP=43.133.7.86"
set "SERVER_PORT=3100"
set "AUTH_TOKEN=cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"

REM 方式2：域名访问（取消注释以下三行使用）
REM set "SERVER_IP=claudecode.polypredict.online"
REM set "SERVER_PORT=80"
REM set "AUTH_TOKEN=cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"

echo 📋 配置信息：
echo   服务器: %SERVER_IP%:%SERVER_PORT%
echo   Token: %AUTH_TOKEN:~0,25%...
echo.

echo 🔧 开始设置永久环境变量...
echo.

REM 使用 PowerShell 设置永久环境变量
powershell -Command "[System.Environment]::SetEnvironmentVariable('ANTHROPIC_BASE_URL', 'http://%SERVER_IP%:%SERVER_PORT%/api', [System.EnvironmentVariableTarget]::User)"
powershell -Command "[System.Environment]::SetEnvironmentVariable('ANTHROPIC_AUTH_TOKEN', '%AUTH_TOKEN%', [System.EnvironmentVariableTarget]::User)"

echo ✅ 环境变量设置完成
echo.

echo 🔐 设置 PowerShell 执行策略...
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"

echo ✅ 执行策略设置完成
echo.

echo 🧪 验证配置...
powershell -Command "Write-Host 'ANTHROPIC_BASE_URL: ' -NoNewline; [System.Environment]::GetEnvironmentVariable('ANTHROPIC_BASE_URL', [System.EnvironmentVariableTarget]::User)"
powershell -Command "Write-Host 'ANTHROPIC_AUTH_TOKEN: ' -NoNewline; ([System.Environment]::GetEnvironmentVariable('ANTHROPIC_AUTH_TOKEN', [System.EnvironmentVariableTarget]::User)).Substring(0,25) + '...'"

echo.
echo ================================================
echo 🎉 配置完成！
echo.
echo 💡 重要提醒:
echo   1. 请关闭所有 PowerShell 窗口
echo   2. 重新打开 PowerShell
echo   3. 运行测试命令: claude "你好"
echo.
echo 🔧 如果遇到问题，请运行以下验证命令:
echo   echo $env:ANTHROPIC_BASE_URL
echo   echo $env:ANTHROPIC_AUTH_TOKEN
echo.
echo 📚 完整文档: CLIENT_SETUP_GUIDE_UPDATED.md
echo ================================================

pause