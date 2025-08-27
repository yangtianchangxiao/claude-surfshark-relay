# Claude + Surfshark 中转服务快速开始

## 🚀 5分钟快速配置指南

### 服务器端（已完成 ✅）
- Claude Relay Service 运行在端口 3100
- 通过 Surfshark VPN 代理所有请求
- Web 管理界面：http://localhost:3100/admin-next/api-stats

### 客户端配置

#### Windows（PowerShell）- 一键配置

**运行快速配置脚本：**
```cmd
# 双击运行
windows-quick-setup.bat
```

**或者手动设置：**
```powershell
# 复制粘贴以下三行命令到 PowerShell
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "http://localhost:3100/api", [System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", "cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1", [System.EnvironmentVariableTarget]::User)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**重新打开 PowerShell，测试：**
```powershell
claude "你好"
```

#### macOS/Linux - 一键配置

```bash
# 复制粘贴以下命令
export ANTHROPIC_BASE_URL="http://localhost:3100/api"
export ANTHROPIC_AUTH_TOKEN="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"

# 永久设置
echo 'export ANTHROPIC_BASE_URL="http://localhost:3100/api"' >> ~/.bashrc
echo 'export ANTHROPIC_AUTH_TOKEN="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"' >> ~/.bashrc

# 测试
claude "你好"
```

## ⚠️ 重要提醒

1. **环境变量名称必须正确：**
   - `ANTHROPIC_BASE_URL`（不是 API_URL）
   - `ANTHROPIC_AUTH_TOKEN`（不是 API_KEY）

2. **URL 必须包含 /api 路径：**
   - ✅ `http://localhost:3100/api`
   - ❌ `http://localhost:3100`

3. **Windows 用户：**
   - 设置后必须重新打开 PowerShell
   - 可能需要设置执行策略

## 🧪 验证配置

```powershell
# Windows PowerShell
echo $env:ANTHROPIC_BASE_URL
echo $env:ANTHROPIC_AUTH_TOKEN
```

```bash
# macOS/Linux
echo $ANTHROPIC_BASE_URL
echo $ANTHROPIC_AUTH_TOKEN
```

**预期输出：**
```
http://localhost:3100/api
cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1
```

## 🎯 开始使用

```bash
claude "写一个Python的Hello World程序"
claude "帮我解释一下这段代码的作用"
claude "你好，请用中文回复"
```

## 📁 相关文件

- `CLIENT_SETUP_GUIDE_UPDATED.md` - 详细配置指南
- `windows-quick-setup.bat` - Windows 一键配置脚本
- `examples/macos-setup.sh` - macOS 配置脚本
- `COMPLETE_INSTALLATION_GUIDE.md` - 完整安装文档

---

**🎉 配置完成后，你就可以通过 Surfshark VPN 使用 Claude 了！**