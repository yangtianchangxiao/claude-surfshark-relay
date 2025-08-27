#!/bin/bash
# 设置自动同步 Claude credentials 的 cron job

SCRIPT_PATH="/home/ubuntu/claude-surfshark-relay/claude-relay-service/auto-sync-credentials.js"
LOG_PATH="/home/ubuntu/claude-surfshark-relay/claude-relay-service/logs/auto-sync.log"

# 创建 cron job (每5分钟运行一次)
(crontab -l 2>/dev/null | grep -v "auto-sync-credentials.js"; echo "*/5 * * * * cd /home/ubuntu/claude-surfshark-relay/claude-relay-service && /usr/bin/node $SCRIPT_PATH >> $LOG_PATH 2>&1") | crontab -

echo "✅ 自动同步已设置，每5分钟同步一次本地 Claude CLI credentials"
echo "📝 日志文件: $LOG_PATH"

# 立即运行一次
echo "🔄 立即执行一次同步..."
cd /home/ubuntu/claude-surfshark-relay/claude-relay-service && node auto-sync-credentials.js