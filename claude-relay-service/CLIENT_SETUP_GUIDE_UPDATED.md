# 客户端配置指南（更新版）

本指南介绍如何在不同设备上正确配置 Claude Code CLI 使用中转服务。

## 🔑 重要提醒

经过测试确认，Claude CLI 需要使用以下**正确的环境变量**：
- `ANTHROPIC_BASE_URL`: API 基础地址（需要包含 `/api` 路径）
- `ANTHROPIC_AUTH_TOKEN`: API 密钥（不是 `ANTHROPIC_API_KEY`）

---

## 💻 Windows 配置（PowerShell - 推荐）

### 方法一：PowerShell 永久设置（推荐 ✅）

**第一步：设置环境变量**

```powershell
# 方式1：直接端口访问（推荐）
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "http://43.133.7.86:3100/api", [System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", "cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1", [System.EnvironmentVariableTarget]::User)

# 方式2：域名访问
# [System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "http://claudecode.polypredict.online/api", [System.EnvironmentVariableTarget]::User)
# [System.Environment]::SetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", "cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1", [System.EnvironmentVariableTarget]::User)
```

**第二步：验证设置**

```powershell
# 查看已设置的环境变量
[System.Environment]::GetEnvironmentVariable("ANTHROPIC_BASE_URL", [System.EnvironmentVariableTarget]::User)
[System.Environment]::GetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", [System.EnvironmentVariableTarget]::User)
```

**第三步：设置执行策略（如果需要）**

```powershell
# 设置执行策略允许运行脚本
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**第四步：重新打开 PowerShell 并测试**

```powershell
# 验证环境变量生效
echo $env:ANTHROPIC_BASE_URL
echo $env:ANTHROPIC_AUTH_TOKEN

# 测试 Claude CLI
claude "你好，请用中文回复"
```

### 方法二：PowerShell 临时设置

```powershell
# 设置临时环境变量（当前会话）
$env:ANTHROPIC_BASE_URL = "http://localhost:3100/api"
$env:ANTHROPIC_AUTH_TOKEN = "cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"

# 测试
claude "你好"
```

### 方法三：批处理脚本

创建 `claude-setup.bat` 文件：

```batch
@echo off
REM Claude 中转服务配置脚本（更新版）

REM 设置正确的环境变量
set ANTHROPIC_BASE_URL=http://localhost:3100/api
set ANTHROPIC_AUTH_TOKEN=cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1

echo ✅ Claude 环境已配置
echo 🌐 服务器: %ANTHROPIC_BASE_URL%
echo 🔑 Auth Token: %ANTHROPIC_AUTH_TOKEN:~0,20%...

REM 测试连接
echo.
echo 🧪 测试连接...
claude "Hello, 请用中文回复"

pause
```

---

## 🍎 macOS 配置

### 方法一：永久设置（推荐）

```bash
# 检查使用的 shell
echo $SHELL

# 对于 zsh（macOS 默认）
echo 'export ANTHROPIC_BASE_URL="http://localhost:3100/api"' >> ~/.zshrc
echo 'export ANTHROPIC_AUTH_TOKEN="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"' >> ~/.zshrc
source ~/.zshrc

# 对于 bash
echo 'export ANTHROPIC_BASE_URL="http://localhost:3100/api"' >> ~/.bash_profile
echo 'export ANTHROPIC_AUTH_TOKEN="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"' >> ~/.bash_profile
source ~/.bash_profile

# 测试连接
claude "你好"
```

### 方法二：临时设置

```bash
# 设置环境变量（当前会话）
export ANTHROPIC_BASE_URL="http://localhost:3100/api"
export ANTHROPIC_AUTH_TOKEN="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"

# 测试连接
claude "你好"
```

---

## 🐧 Linux 配置

### 永久设置

```bash
# 添加到 ~/.bashrc
echo 'export ANTHROPIC_BASE_URL="http://localhost:3100/api"' >> ~/.bashrc
echo 'export ANTHROPIC_AUTH_TOKEN="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"' >> ~/.bashrc
source ~/.bashrc

# 测试连接
claude "你好"
```

---

## 🌐 远程服务器访问

如果你想从其他电脑访问服务器上的中转服务：

### Windows PowerShell

```powershell
# 替换为你的服务器IP
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "http://你的服务器IP:3100/api", [System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", "cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1", [System.EnvironmentVariableTarget]::User)
```

### macOS/Linux

```bash
export ANTHROPIC_BASE_URL="http://你的服务器IP:3100/api"
export ANTHROPIC_AUTH_TOKEN="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"
```

---

## 🧪 测试和验证

### 验证环境变量

**Windows PowerShell:**
```powershell
echo $env:ANTHROPIC_BASE_URL
echo $env:ANTHROPIC_AUTH_TOKEN
```

**macOS/Linux:**
```bash
echo $ANTHROPIC_BASE_URL
echo $ANTHROPIC_AUTH_TOKEN
```

### 测试连接

```bash
# 基本测试
claude "Hello"

# 中文测试
claude "你好，请用中文回复"

# 代码测试
claude "写一个Python的Hello World程序"
```

### 预期输出

**环境变量应该显示:**
```
http://localhost:3100/api
cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1
```

**Claude 响应应该正常显示而不是错误信息。**

---

## 🛠️ 故障排除

### 常见错误

#### 1. 404 Route not found
```
API Error: 404 Route /v1/messages?beta=true not found
```

**解决方案:** 确保 `ANTHROPIC_BASE_URL` 包含 `/api` 路径：
```powershell
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "http://localhost:3100/api", [System.EnvironmentVariableTarget]::User)
```

#### 2. 401 Unauthorized
```
API Error: 401 Unauthorized
```

**解决方案:** 检查 `ANTHROPIC_AUTH_TOKEN` 是否正确设置：
```powershell
echo $env:ANTHROPIC_AUTH_TOKEN
```

#### 3. Connection refused
```
Error: connect ECONNREFUSED
```

**解决方案:** 
- 检查服务器是否运行：`curl http://localhost:3100/health`
- 检查防火墙设置
- 确认端口号正确

#### 4. PowerShell 执行策略错误
```
因为在此系统上禁止运行脚本
```

**解决方案:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 调试命令

```powershell
# 检查服务器状态
curl http://localhost:3100/health

# 直接测试API
curl -H "Authorization: Bearer cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1" http://localhost:3100/api/v1/me
```

---

## 📝 重要提醒

1. **环境变量名称**: 必须使用 `ANTHROPIC_AUTH_TOKEN`，不是 `ANTHROPIC_API_KEY`
2. **URL 路径**: 必须包含 `/api`，即 `http://localhost:3100/api`
3. **PowerShell 重启**: 设置永久环境变量后必须重新打开 PowerShell
4. **执行策略**: Windows 可能需要设置 PowerShell 执行策略
5. **API Key 格式**: 确保使用正确的 `cr_` 开头的密钥

---

## 📚 快速参考

### Windows PowerShell 一键设置

```powershell
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "http://localhost:3100/api", [System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", "cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1", [System.EnvironmentVariableTarget]::User)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### macOS/Linux 一键设置

```bash
echo 'export ANTHROPIC_BASE_URL="http://localhost:3100/api"' >> ~/.bashrc
echo 'export ANTHROPIC_AUTH_TOKEN="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"' >> ~/.bashrc
source ~/.bashrc
```

---

**🎉 配置完成后，你就可以在任何地方使用 `claude "你的问题"` 命令了！**