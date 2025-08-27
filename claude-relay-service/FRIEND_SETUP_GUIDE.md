# Claude中转服务使用教程

这是一个完整的Claude Code CLI配置教程，支持Windows和Ubuntu系统。

## 🎯 服务信息

**服务地址：**
- 域名访问：`http://claudecode.polypredict.online/api`
- 直接IP访问：`http://43.133.7.86:3100/api`

**API密钥：** `cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1`

## 📋 前提条件

1. 网络连接正常
2. 需要安装Claude Code CLI（见下方安装步骤）

## 🚀 安装Claude Code CLI

### Windows 安装

**方法1：使用 npm（推荐）**
```powershell
# 安装 Node.js（如果未安装）
# 访问 https://nodejs.org 下载并安装最新版本

# 安装 Claude Code CLI
npm install -g @anthropic-ai/claude-code

# 验证安装
claude --version
```

**方法2：使用官方安装程序**
```powershell
# 使用 PowerShell 下载安装脚本
iwr https://claude.ai/install.ps1 -useb | iex

# 或者访问官网下载：https://claude.ai/code
```

### Ubuntu/Linux 安装

**方法1：使用 npm（推荐）**
```bash
# 安装 Node.js 和 npm（如果未安装）
sudo apt update
sudo apt install -y nodejs npm

# 验证 Node.js 版本（需要 16+ 版本）
node --version
npm --version

# 安装 Claude Code CLI
sudo npm install -g @anthropic-ai/claude-code

# 验证安装
claude --version
```

**方法2：使用官方安装脚本**
```bash
# 下载并运行安装脚本
curl -fsSL https://claude.ai/install.sh | bash

# 重启终端或重新加载 shell 配置
source ~/.bashrc
# 或
source ~/.zshrc
```

**方法3：手动下载二进制文件**
```bash
# 下载最新版本
wget https://github.com/anthropics/claude-code/releases/latest/download/claude-linux-x64

# 设置执行权限
chmod +x claude-linux-x64

# 移动到系统路径
sudo mv claude-linux-x64 /usr/local/bin/claude

# 验证安装
claude --version
```

---

## 🪟 Windows 配置

### 方法1：PowerShell 永久设置（推荐）

打开 **PowerShell**（以管理员身份运行），然后执行：

```powershell
# 设置环境变量（永久生效）
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "http://claudecode.polypredict.online/api", [System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", "cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1", [System.EnvironmentVariableTarget]::User)

# 设置执行策略（如果需要）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 验证设置
[System.Environment]::GetEnvironmentVariable("ANTHROPIC_BASE_URL", [System.EnvironmentVariableTarget]::User)
[System.Environment]::GetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", [System.EnvironmentVariableTarget]::User)
```

### 方法2：临时设置（当前会话）

```powershell
# 临时设置（仅当前PowerShell会话有效）
$env:ANTHROPIC_BASE_URL = "http://claudecode.polypredict.online/api"
$env:ANTHROPIC_AUTH_TOKEN = "cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"

# 验证
echo $env:ANTHROPIC_BASE_URL
echo $env:ANTHROPIC_AUTH_TOKEN
```

### 测试连接

```powershell
# 重新打开PowerShell，然后测试
claude "你好，请介绍一下自己"
```

---

## 🐧 Ubuntu/Linux 配置

### 方法1：永久配置（推荐）

```bash
# 添加到shell配置文件
echo 'export ANTHROPIC_BASE_URL="http://claudecode.polypredict.online/api"' >> ~/.bashrc
echo 'export ANTHROPIC_AUTH_TOKEN="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"' >> ~/.bashrc

# 如果使用zsh
echo 'export ANTHROPIC_BASE_URL="http://claudecode.polypredict.online/api"' >> ~/.zshrc
echo 'export ANTHROPIC_AUTH_TOKEN="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"' >> ~/.zshrc

# 重新加载配置
source ~/.bashrc
# 或
source ~/.zshrc
```

### 方法2：临时配置

```bash
# 临时设置（仅当前会话有效）
export ANTHROPIC_BASE_URL="http://claudecode.polypredict.online/api"
export ANTHROPIC_AUTH_TOKEN="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"

# 验证
echo $ANTHROPIC_BASE_URL
echo $ANTHROPIC_AUTH_TOKEN
```

### 测试连接

```bash
# 测试连接
claude "你好，请介绍一下自己"
```

---

## 🔧 故障排除

### 常见问题1：环境变量冲突

如果看到错误：`Auth conflict: Both a token and an API key are set`

**Windows解决：**
```powershell
# 清理冲突的环境变量
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", $null, [System.EnvironmentVariableTarget]::User)
```

**Ubuntu解决：**
```bash
# 编辑配置文件，删除ANTHROPIC_API_KEY相关行
nano ~/.bashrc
# 或
nano ~/.zshrc
```

### 常见问题2：连接超时

如果遇到连接问题，可以尝试直接IP访问：

**更换为IP地址：**
```powershell
# Windows
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "http://43.133.7.86:3100/api", [System.EnvironmentVariableTarget]::User)
```

```bash
# Ubuntu
export ANTHROPIC_BASE_URL="http://43.133.7.86:3100/api"
```

### 常见问题3：模型不支持

如果遇到模型不支持的错误，请联系服务管理员。

### 验证配置

**检查环境变量是否正确设置：**

Windows:
```powershell
echo $env:ANTHROPIC_BASE_URL
echo $env:ANTHROPIC_AUTH_TOKEN
```

Ubuntu:
```bash
echo $ANTHROPIC_BASE_URL
echo $ANTHROPIC_AUTH_TOKEN
```

**应该显示：**
- `ANTHROPIC_BASE_URL`: `http://claudecode.polypredict.online/api`
- `ANTHROPIC_AUTH_TOKEN`: `cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1`

---

## 📞 技术支持

如果遇到问题，请检查：

1. **网络连接**：确保能访问互联网
2. **环境变量**：使用上面的验证命令检查
3. **Claude Code版本**：确保使用最新版本
4. **防火墙**：确保没有阻止网络连接

## 🎉 使用说明

配置完成后，就可以正常使用Claude Code了：

```bash
# 基础对话
claude "你好"

# 代码分析
claude "请分析这个文件的功能" /path/to/file.py

# 项目开发
claude "帮我创建一个Python web应用"
```

---

**重要提醒：**
- 设置永久环境变量后需要重新打开终端/PowerShell
- 如果仍有问题，请尝试重启计算机
- 请勿分享API密钥给其他人