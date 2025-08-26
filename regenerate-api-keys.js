#!/usr/bin/env node

/**
 * 重新生成所有API Keys
 * 保持所有配置不变，只重新生成API Key字符串和哈希值
 */

const crypto = require('crypto')
const redis = require('./src/models/redis')
const config = require('./config/config')
const logger = require('./src/utils/logger')
const { table } = require('table')
const chalk = require('chalk')

async function regenerateApiKeys() {
  try {
    await redis.connect()
    logger.info('🔗 已连接到Redis')

    // 获取所有API Keys
    const keys = await redis.client.keys('apikey:*')
    const apiKeyIds = keys.filter(k => k !== 'apikey:hash_map').map(k => k.replace('apikey:', ''))

    logger.info(`📋 找到 ${apiKeyIds.length} 个API Keys`)

    if (apiKeyIds.length === 0) {
      logger.warn('⚠️  没有找到任何API Keys')
      return
    }

    // 清空现有的哈希映射表
    await redis.client.del('apikey:hash_map')
    logger.info('🧹 清空了旧的哈希映射表')

    const regeneratedKeys = []
    const currentEncryptionKey = config.security.encryptionKey

    console.log('\n' + chalk.yellow('🔄 开始重新生成API Keys...') + '\n')

    for (const keyId of apiKeyIds) {
      const keyData = await redis.client.hgetall(`apikey:${keyId}`)
      
      if (!keyData || !keyData.name) {
        logger.warn(`⚠️  跳过无效的API Key: ${keyId}`)
        continue
      }

      // 生成新的API Key字符串
      const newApiKeyString = config.security.apiKeyPrefix + crypto.randomBytes(32).toString('hex')
      
      // 计算新的哈希值
      const newHashedKey = crypto
        .createHash('sha256')
        .update(newApiKeyString + currentEncryptionKey)
        .digest('hex')

      // 更新Redis中的数据
      await redis.client.hset(`apikey:${keyId}`, 'apiKey', newHashedKey)
      await redis.client.hset('apikey:hash_map', newHashedKey, keyId)

      // 记录新生成的API Key信息
      regeneratedKeys.push({
        name: keyData.name,
        description: keyData.description || '',
        apiKey: newApiKeyString,
        permissions: keyData.permissions || 'all',
        isActive: keyData.isActive === 'true' ? '✅ 活跃' : '❌ 禁用',
        tokenLimit: keyData.tokenLimit === '0' ? '无限制' : keyData.tokenLimit,
        createdAt: keyData.createdAt ? new Date(keyData.createdAt).toLocaleDateString() : '未知'
      })

      logger.info(`✅ 已重新生成: ${keyData.name}`)
    }

    // 显示结果表格
    console.log('\n' + chalk.green('🎉 API Keys 重新生成完成！') + '\n')
    
    const tableData = [
      ['名称', '描述', '新的API Key', '权限', '状态', 'Token限制']
    ]

    regeneratedKeys.forEach(key => {
      tableData.push([
        key.name,
        key.description.substring(0, 20) + (key.description.length > 20 ? '...' : ''),
        key.apiKey,
        key.permissions,
        key.isActive,
        key.tokenLimit
      ])
    })

    const output = table(tableData, {
      header: {
        alignment: 'center',
        content: chalk.blue('🔑 新生成的API Keys')
      },
      columnDefault: {
        paddingLeft: 1,
        paddingRight: 1
      },
      columns: {
        2: { width: 30 } // API Key列宽度限制
      }
    })

    console.log(output)

    // 保存到文件
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-')
    const filename = `api-keys-${timestamp}.txt`
    const fileContent = regeneratedKeys.map(key => 
      `名称: ${key.name}\nAPI Key: ${key.apiKey}\n权限: ${key.permissions}\n状态: ${key.isActive}\n描述: ${key.description}\n---\n`
    ).join('\n')
    
    require('fs').writeFileSync(filename, fileContent)
    console.log(chalk.green(`📄 API Keys已保存到文件: ${filename}`))

    logger.success(`🎉 成功重新生成了 ${regeneratedKeys.length} 个API Keys`)
    console.log(chalk.red('\n⚠️  重要提醒: 请立即更新所有客户端配置中的API Keys！'))
    console.log(chalk.yellow('💡 建议: 将上述API Keys保存到安全的地方，这些信息不会再次显示。'))

  } catch (error) {
    logger.error('❌ 重新生成失败:', error)
  } finally {
    await redis.disconnect()
  }
}

if (require.main === module) {
  regenerateApiKeys()
}

module.exports = { regenerateApiKeys }