# OAuth vs Setup Token 对比指南

## 🔐 基本概念

### OAuth（标准授权）
- **完整的OAuth 2.0流程**，包含用户授权和token交换
- **权限范围**：`org:create_api_key user:profile user:inference`
- **适用于**：需要完整功能的场景，包括创建API Key、查看用户信息等

### Setup Token（简化授权）
- **简化的授权流程**，专门为Claude Code设计
- **权限范围**：`user:inference`（仅推理权限）
- **适用于**：只需要使用Claude进行对话推理的场景

## 📊 详细对比

| 特性 | OAuth | Setup Token |
|------|--------|-------------|
| **权限范围** | 完整权限（创建API、用户信息、推理） | 仅推理权限 |
| **Token有效期** | 标准有效期 | 可设置更长有效期（1年） |
| **刷新Token** | ✅ 支持（有refresh_token） | ❌ 不支持（无refresh_token） |
| **用户信息** | ✅ 可获取完整用户信息 | ❌ 无法获取用户信息 |
| **创建API Key** | ✅ 可以创建新的API Key | ❌ 不能创建API Key |
| **使用场景** | 管理型应用、需要完整功能 | 纯对话应用、Claude Code |

## 🎯 优势对比

### OAuth的优势
1. **功能完整**
   - 可以获取用户profile信息
   - 可以动态创建和管理API Key
   - 支持组织级别的操作

2. **Token管理**
   - 有refresh_token，可以自动刷新
   - 更适合长期运行的服务
   - 不会因为token过期而中断服务

3. **灵活性高**
   - 可以实现更复杂的功能
   - 适合构建完整的管理平台
   - 支持多用户、多账户管理

### Setup Token的优势
1. **简单快捷**
   - 授权流程更简单
   - 不需要复杂的权限配置
   - 快速获得推理能力

2. **安全性**
   - 权限最小化原则
   - 只有推理权限，降低安全风险
   - 适合给第三方使用

3. **长有效期**
   - 可以设置更长的有效期（如1年）
   - 减少重新授权的频率
   - 适合个人使用场景

## 🚀 使用建议

### 选择OAuth的场景
- 构建**Claude管理平台**
- 需要**多账户切换**功能
- 需要**查看用户信息**和使用统计
- 构建**企业级应用**
- 需要**自动刷新Token**保持服务稳定

### 选择Setup Token的场景
- 个人使用**Claude Code CLI**
- 只需要**对话功能**
- 构建**简单的聊天应用**
- 给**第三方用户**提供受限访问
- 不需要**用户管理**功能

## 💡 实际应用示例

### OAuth应用示例
```javascript
// 可以获取用户信息
const userInfo = await getUserProfile(oauthToken);
console.log(`用户：${userInfo.email}, 订阅：${userInfo.subscription}`);

// 可以创建新的API Key
const newApiKey = await createApiKey(oauthToken, {
  name: "My App",
  expiresIn: 30 * 24 * 60 * 60 // 30天
});

// Token过期时自动刷新
if (isTokenExpired(accessToken)) {
  accessToken = await refreshToken(refreshToken);
}
```

### Setup Token应用示例
```javascript
// 仅用于对话推理
const response = await claude.complete({
  messages: [{ role: 'user', content: 'Hello!' }],
  headers: { 'Authorization': `Bearer ${setupToken}` }
});

// 无法获取用户信息（会报错）
// const userInfo = await getUserProfile(setupToken); // ❌ 403 Forbidden

// 无法刷新token（需要重新授权）
// 建议设置较长的有效期减少重新授权频率
```

## 🔧 技术实现差异

### 权限检查
在中继服务中，系统会检查账户的权限范围：
- OAuth账户：包含`user:profile`权限，可以执行所有操作
- Setup Token账户：仅`user:inference`权限，只能进行推理

### 账户选择策略
```javascript
// 系统会跳过Setup Token账户的某些操作
if (!account.scopes.includes('user:profile')) {
  // 这是Setup Token账户，跳过profile相关操作
  return { error: 'No user:profile permission (Setup Token account)' };
}
```

## 📝 总结

- **OAuth**：功能强大，适合构建完整应用
- **Setup Token**：简单安全，适合个人使用
- 选择哪种方式取决于你的具体需求
- 两种方式都支持通过代理访问（已修复）