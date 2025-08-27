# 客户端配置指南

本指南介绍如何在不同设备上配置 Claude Code CLI 使用中转服务。

## 📋 前提条件

1. 中转服务已正常运行
2. 已获取 API Key（格式：`cr_xxxxx...`）
3. 已安装 Claude Code CLI

---

## 🔑 获取 API Key

### 步骤 1：访问管理界面

打开浏览器访问：`http://服务器IP:3100/admin-next/api-stats`

### 步骤 2：登录管理员账户

- **用户名**: `lorland`
- **密码**: `5155ch007`

### 步骤 3：添加 Claude 账户

1. 点击 **账户管理**
2. 选择 **添加账户** → **Claude** → **OAuth 授权**
3. 点击 **生成授权链接**
4. 在新窗口完成 Claude.ai 登录授权
5. 复制授权码并粘贴回界面

### 步骤 4：创建 API Key

1. 进入 **API Keys** 页面
2. 点击 **创建新 API Key**
3. 填写描述信息（如："我的电脑"）
4. 选择账户类型：**共享账户**
5. 点击 **创建**
6. 复制生成的 API Key

---

## 💻 Windows 配置

### 方法一：PowerShell 临时设置

适合临时使用，关闭窗口后失效：

```powershell
# 设置环境变量（替换为你的服务器IP和API Key）
$env:ANTHROPIC_BASE_URL = "http://192.168.1.100:3100"
$env:ANTHROPIC_API_KEY = "cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"

# 测试连接
claude "你好"
```

### 方法二：PowerShell 永久设置

适合长期使用：

```powershell
# 设置用户环境变量（替换为你的实际值）
[Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "http://192.168.1.100:3100", "User")
[Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", "cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1", "User")

# 重启 PowerShell 或重新加载环境变量
$env:ANTHROPIC_BASE_URL = [Environment]::GetEnvironmentVariable("ANTHROPIC_BASE_URL", "User")
$env:ANTHROPIC_API_KEY = [Environment]::GetEnvironmentVariable("ANTHROPIC_API_KEY", "User")

# 测试连接
claude "你好"
```

### 方法三：系统环境变量

通过系统设置永久配置：

1. 按 `Win + R`，输入 `sysdm.cpl`
2. 点击 **高级** 标签页
3. 点击 **环境变量**
4. 在 **用户变量** 区域点击 **新建**
5. 添加以下两个变量：

   **变量 1:**
   - 变量名：`ANTHROPIC_BASE_URL`
   - 变量值：`http://192.168.1.100:3100`

   **变量 2:**
   - 变量名：`ANTHROPIC_API_KEY`
   - 变量值：`cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1`

6. 点击 **确定** 保存
7. 重启命令行工具

### 方法四：批处理脚本

创建 `claude-setup.bat` 文件：

```batch
@echo off
REM Claude 中转服务配置脚本

REM 设置环境变量（请修改为你的实际值）
set ANTHROPIC_BASE_URL=http://192.168.1.100:3100
set ANTHROPIC_API_KEY=cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1

echo ✅ Claude 环境已配置
echo 🌐 服务器: %ANTHROPIC_BASE_URL%
echo 🔑 API Key: %ANTHROPIC_API_KEY:~0,20%...

REM 测试连接
echo.
echo 🧪 测试连接...
claude "Hello"

pause
```

使用方法：双击运行 `claude-setup.bat`

---

## 🍎 macOS 配置

### 方法一：Terminal 临时设置

```bash
# 设置环境变量（替换为你的实际值）
export ANTHROPIC_BASE_URL="http://192.168.1.100:3100"
export ANTHROPIC_API_KEY="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"

# 测试连接
claude "你好"
```

### 方法二：永久设置（推荐）

```bash
# 检查使用的 shell
echo $SHELL

# 对于 zsh（macOS 默认）
echo 'export ANTHROPIC_BASE_URL="http://192.168.1.100:3100"' >> ~/.zshrc
echo 'export ANTHROPIC_API_KEY="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"' >> ~/.zshrc
source ~/.zshrc

# 对于 bash
echo 'export ANTHROPIC_BASE_URL="http://192.168.1.100:3100"' >> ~/.bash_profile
echo 'export ANTHROPIC_API_KEY="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"' >> ~/.bash_profile
source ~/.bash_profile

# 测试连接
claude "你好"
```

### 方法三：创建配置脚本

创建 `claude-setup.sh` 文件：

```bash
#!/bin/bash

# Claude 中转服务配置脚本

# 配置参数（请修改为你的实际值）
CLAUDE_SERVER="http://192.168.1.100:3100"
CLAUDE_API_KEY="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"

# 设置环境变量
export ANTHROPIC_BASE_URL="$CLAUDE_SERVER"
export ANTHROPIC_API_KEY="$CLAUDE_API_KEY"

echo "✅ Claude 环境已配置"
echo "🌐 服务器: $ANTHROPIC_BASE_URL"
echo "🔑 API Key: ${ANTHROPIC_API_KEY:0:20}..."

# 测试连接
echo ""
echo "🧪 测试连接..."
claude "Hello"
```

使用方法：
```bash
chmod +x claude-setup.sh
./claude-setup.sh
```

---

## 🐧 Linux 配置

### 方法一：临时设置

```bash
# 设置环境变量
export ANTHROPIC_BASE_URL="http://192.168.1.100:3100"
export ANTHROPIC_API_KEY="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"

# 测试连接
claude "你好"
```

### 方法二：永久设置

```bash
# 添加到 ~/.bashrc
echo 'export ANTHROPIC_BASE_URL="http://192.168.1.100:3100"' >> ~/.bashrc
echo 'export ANTHROPIC_API_KEY="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"' >> ~/.bashrc
source ~/.bashrc

# 测试连接
claude "你好"
```

### 方法三：系统级配置

```bash
# 为所有用户设置（需要 sudo 权限）
sudo tee /etc/environment << EOF
ANTHROPIC_BASE_URL="http://192.168.1.100:3100"
ANTHROPIC_API_KEY="cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1"
EOF

# 重新登录生效
```

---

## 🧪 测试和验证

### 基本连接测试

```bash
# 简单测试
claude "Hello"

# 中文测试
claude "你好，请用中文回复"

# 代码生成测试
claude "写一个 Python 函数计算斐波那契数列"
```

### 详细测试

```bash
# 测试 API 连接（Windows PowerShell / macOS / Linux）

# PowerShell
$response = Invoke-RestMethod -Uri "$env:ANTHROPIC_BASE_URL/health" -Method Get
$response

# Bash
curl -H "Authorization: Bearer $ANTHROPIC_API_KEY" \
     "$ANTHROPIC_BASE_URL/api/v1/me"
```

### 性能测试

```bash
# 测试响应时间
time claude "简单回复：你好"

# 测试长对话
claude "请写一个关于人工智能的500字短文"
```

---

## 🛠️ 故障排除

### 常见错误

#### 1. 连接被拒绝

```
Error: connect ECONNREFUSED
```

**解决方案:**
- 检查服务器 IP 地址是否正确
- 确认服务器端口 3100 是否开放
- 检查防火墙设置

#### 2. 认证失败

```
Error: 401 Unauthorized
```

**解决方案:**
- 检查 API Key 是否正确
- 确认 API Key 是否已启用
- 重新生成 API Key

#### 3. 模型不支持

```
Error: model not found
```

**解决方案:**
- 确认 Claude 账户已正确添加
- 检查账户订阅状态
- 查看服务器日志

### 调试命令

```bash
# 检查环境变量
echo $ANTHROPIC_BASE_URL
echo $ANTHROPIC_API_KEY

# 测试服务器连接
curl -I http://服务器IP:3100/health

# 查看详细错误
claude --debug "test"
```

---

## 📚 高级配置

### 配置文件方式

创建 `~/.claude/config.json`:

```json
{
  "apiUrl": "http://192.168.1.100:3100",
  "apiKey": "cr_887eb667fa081a174995795b026674307bf99f25913babb22cca7d57c7563bc1",
  "defaultModel": "claude-sonnet-4-20250514",
  "timeout": 30000
}
```

### 多环境配置

```bash
# 开发环境
export ANTHROPIC_BASE_URL="http://dev-server:3100"
export ANTHROPIC_API_KEY="cr_dev_key..."

# 生产环境
export ANTHROPIC_BASE_URL="http://prod-server:3100"
export ANTHROPIC_API_KEY="cr_prod_key..."
```

### 批量部署

对于企业环境，可以创建部署脚本：

```bash
#!/bin/bash
# 批量配置脚本

SERVERS=(
    "192.168.1.100"
    "192.168.1.101"
    "192.168.1.102"
)

API_KEYS=(
    "cr_key1..."
    "cr_key2..."
    "cr_key3..."
)

for i in "${!SERVERS[@]}"; do
    echo "配置服务器 ${SERVERS[$i]}..."
    export ANTHROPIC_BASE_URL="http://${SERVERS[$i]}:3100"
    export ANTHROPIC_API_KEY="${API_KEYS[$i]}"
    
    # 测试连接
    claude "test" > /dev/null && echo "✅ 成功" || echo "❌ 失败"
done
```

---

## 📞 技术支持

如遇问题：

1. 检查网络连接
2. 验证服务器状态
3. 查看错误日志
4. 联系管理员

**重要提醒**: 请勿在公共场所或不安全的网络环境下输入 API Key！