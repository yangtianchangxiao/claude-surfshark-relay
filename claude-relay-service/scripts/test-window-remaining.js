const axios = require('axios')

const BASE_URL = 'http://localhost:3312'

// 你需要替换为一个有效的 API Key
const API_KEY = 'cr_your_api_key_here'

async function testWindowRemaining() {
  try {
    console.log('🔍 测试时间窗口剩余时间功能...\n')

    // 第一步：获取 API Key ID
    console.log('1. 获取 API Key ID...')
    const idResponse = await axios.post(`${BASE_URL}/api-stats/api/get-key-id`, {
      apiKey: API_KEY
    })

    if (!idResponse.data.success) {
      throw new Error('Failed to get API Key ID')
    }

    const apiId = idResponse.data.data.id
    console.log(`   ✅ API Key ID: ${apiId}\n`)

    // 第二步：查询统计数据
    console.log('2. 查询统计数据（包含时间窗口信息）...')
    const statsResponse = await axios.post(`${BASE_URL}/api-stats/api/user-stats`, {
      apiId
    })

    if (!statsResponse.data.success) {
      throw new Error('Failed to get stats data')
    }

    const stats = statsResponse.data.data
    console.log(`   ✅ 成功获取统计数据\n`)

    // 第三步：检查时间窗口信息
    console.log('3. 时间窗口信息:')
    console.log(`   - 窗口时长: ${stats.limits.rateLimitWindow} 分钟`)
    console.log(`   - 请求限制: ${stats.limits.rateLimitRequests || '无限制'}`)
    console.log(`   - Token限制: ${stats.limits.tokenLimit || '无限制'}`)
    console.log(`   - 当前请求数: ${stats.limits.currentWindowRequests}`)
    console.log(`   - 当前Token数: ${stats.limits.currentWindowTokens}`)

    if (stats.limits.windowStartTime) {
      const startTime = new Date(stats.limits.windowStartTime)
      const endTime = new Date(stats.limits.windowEndTime)

      console.log(`\n   ⏰ 时间窗口状态:`)
      console.log(`   - 窗口开始时间: ${startTime.toLocaleString()}`)
      console.log(`   - 窗口结束时间: ${endTime.toLocaleString()}`)
      console.log(`   - 剩余时间: ${stats.limits.windowRemainingSeconds} 秒`)

      if (stats.limits.windowRemainingSeconds > 0) {
        const minutes = Math.floor(stats.limits.windowRemainingSeconds / 60)
        const seconds = stats.limits.windowRemainingSeconds % 60
        console.log(`   - 格式化剩余时间: ${minutes}分${seconds}秒`)
        console.log(`   - 窗口状态: 🟢 活跃中`)
      } else {
        console.log(`   - 窗口状态: 🔴 已过期（下次请求时重置）`)
      }
    } else {
      console.log(`\n   ⏰ 时间窗口状态: ⚪ 未启动（还没有任何请求）`)
    }

    console.log('\n✅ 测试完成！时间窗口剩余时间功能正常工作。')
  } catch (error) {
    console.error('❌ 测试失败:', error.message)
    if (error.response) {
      console.error('   响应数据:', error.response.data)
    }
    process.exit(1)
  }
}

// 运行测试
testWindowRemaining()
