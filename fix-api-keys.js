#!/usr/bin/env node

/**
 * 修复API Keys哈希值问题
 * 当ENCRYPTION_KEY改变时，需要重新计算所有API Keys的哈希值
 */

const crypto = require('crypto')
const redis = require('./src/models/redis')
const config = require('./config/config')
const logger = require('./src/utils/logger')

async function fixApiKeyHashes() {
  try {
    await redis.connect()
    logger.info('🔗 已连接到Redis')

    // 获取所有API Keys
    const keys = await redis.client.keys('apikey:*')
    const apiKeyIds = keys.filter(k => k !== 'apikey:hash_map').map(k => k.replace('apikey:', ''))

    logger.info(`📋 找到 ${apiKeyIds.length} 个API Keys`)

    // 清空现有的哈希映射表
    await redis.client.del('apikey:hash_map')
    logger.info('🧹 清空了旧的哈希映射表')

    let fixedCount = 0
    const currentEncryptionKey = config.security.encryptionKey

    for (const keyId of apiKeyIds) {
      const keyData = await redis.client.hgetall(`apikey:${keyId}`)
      
      if (!keyData || !keyData.apiKey) {
        logger.warn(`⚠️  跳过无效的API Key: ${keyId}`)
        continue
      }

      // 这里假设keyData.apiKey是旧的哈希值
      // 我们需要重新生成一个新的API Key字符串，然后计算新的哈希值
      
      // 生成新的API Key字符串（保持原来的格式）
      const newApiKeyString = config.security.apiKeyPrefix + crypto.randomBytes(32).toString('hex')
      
      // 计算新的哈希值
      const newHashedKey = crypto
        .createHash('sha256')
        .update(newApiKeyString + currentEncryptionKey)
        .digest('hex')

      // 更新Redis中的数据
      await redis.client.hset(`apikey:${keyId}`, 'apiKey', newHashedKey)
      await redis.client.hset('apikey:hash_map', newHashedKey, keyId)

      logger.info(`✅ 已修复API Key: ${keyData.name} (${keyId})`)
      logger.info(`   新的API Key: ${newApiKeyString}`)
      
      fixedCount++
    }

    logger.success(`🎉 成功修复了 ${fixedCount} 个API Keys`)
    logger.warn('⚠️  重要提醒：所有API Keys都已重新生成，请更新客户端配置！')

  } catch (error) {
    logger.error('❌ 修复失败:', error)
  } finally {
    await redis.disconnect()
  }
}

if (require.main === module) {
  fixApiKeyHashes()
}

module.exports = { fixApiKeyHashes }