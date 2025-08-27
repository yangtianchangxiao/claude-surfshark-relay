#!/bin/bash

echo "Testing auto-refresh mechanism..."

# 创建API key
echo "Creating API key..."
cd /home/ubuntu/claude-surfshark-relay/claude-relay-service
API_KEY=$(node -e "
const crypto = require('crypto');
const redis = require('./src/models/redis');
async function createKey() {
  await redis.connect();
  const keyId = crypto.randomUUID();
  const apiKey = 'cr_' + crypto.randomBytes(16).toString('hex');
  const keyData = {
    id: keyId,
    name: 'test-refresh',
    key: apiKey,
    createdAt: new Date().toISOString(),
    limit: 1000,
    used: 0,
    isActive: 'true'
  };
  await redis.setApiKey(keyId, keyData);
  await redis.disconnect();
  console.log(apiKey);
}
createKey();
" 2>/dev/null)

echo "API Key: $API_KEY"

# 发送测试请求
echo "Sending test request..."
curl -X POST http://localhost:3100/api/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-3-5-sonnet-20241022",
    "messages": [{"role": "user", "content": "Say hello"}],
    "max_tokens": 50
  }' 2>&1

echo -e "\n\nChecking logs for refresh activity..."
tail -50 /home/ubuntu/claude-surfshark-relay/claude-relay-service/logs/claude-relay-2025-08-25.log | grep -E "(refresh|Token expired|Auto refresh|Found.*accounts)"