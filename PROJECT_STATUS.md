# AI Prediction Market MVP - 项目状态更新

**日期:** 2023年11月21日 (请根据实际情况更新)

**文档目的:** 本文档旨在清晰地概述 AI 预测市场 MVP 项目当前的开发状态、已完成的工作、目前可演示的功能、后续步骤、系统架构、交互流程以及存在的关键挑战。

---

## 1. 项目概述与目标 (产品/创业视角)

*   **核心目标:** 构建一个基于 TON 区块链、集成在 Telegram Mini App (TMA) 中的 AI 驱动的预测市场 MVP。
*   **价值主张:** 利用 AI 实现快速、广泛的议题生成；利用 Telegram 生态实现低摩擦的用户入口和社交传播；提供一个基础但完整的预测市场体验（查看市场、下注、查看结果、领取奖励）。
*   **当前阶段目标:** 验证核心用户流程的技术可行性和用户体验，为后续迭代和融资提供基础。

---

## 2. 当前状态与已完成的工作 (技术/产品视角)

我们已经成功搭建了 MVP 应用的基础框架，并完成了核心前端用户流程的开发（目前依赖 Mock 数据）。

**已完成的关键事项:**

*   **项目结构与配置:** 
    *   确定 `/home/ubuntu/web3/prediction-market-mvp` 为项目根目录。
    *   使用 `npm` 初始化项目并管理依赖 (`package.json`)。
    *   建立了标准的前端项目目录结构 (`src`, `public`, `components`, `services`)。
    *   引入了环境变量管理机制 (`.env`, `.env.example`, `dotenv` 库)，用于管理配置（如网络选择、URL、未来合约地址）。
*   **钱包连接 (核心入口):**
    *   `walletService.ts`: 创建了钱包服务，使用 `@tonconnect/ui-react` 初始化 TonConnect UI，处理钱包连接/断开逻辑，并从 `.env` 读取配置。
    *   `tonconnect-manifest.json`: 创建了必要的应用清单文件（存放于 `public/`，**需要您手动配置真实 URL 并托管**）。
    *   `WalletConnect.tsx`: 创建了 React UI 组件，使用 `<TonConnectButton />` 并显示连接状态/地址。
    *   解决了相关的 TypeScript 类型依赖问题 (`@types/node`, `@types/telegram-web-app`)。
*   **预测市场服务层 (`predictionMarketService.ts`):**
    *   **接口设计:** 基于常见的预测市场模式和 MVP 需求，设计了一个基础智能合约接口，包括状态变量、消息操作码 (Op Codes: `OP_PLACE_BET`, `OP_CLAIM_WINNINGS` 等) 和 Get 方法 (`get_market_data`, `get_user_share`)。
    *   **函数框架:** 创建了与链交互的核心函数框架 (`getMarketDetails`, `getUserShare`, `placeBet`, `claimWinnings`)。
    *   **接口对齐:** 更新了这些函数，使其内部逻辑（消息体构建、结果解析）与我们**设计的合约接口**保持一致。
    *   **Mocking 实现 (关键进展):** 
        *   加入了强大的 Mock 逻辑。当 `.env` 中缺少测试网合约地址时，服务层会自动返回模拟数据和交易结果。
        *   Mock 数据现在可以模拟不同场景（市场激活/解决、用户有/无获胜份额、交易成功/失败/用户拒绝）。
        *   提供了 `window.MOCK_CONFIG` 对象，允许在浏览器控制台动态调整 Mock 行为以方便测试。
*   **核心 UI 组件 (`MarketDisplay.tsx`):**
    *   **数据显示:** 可以调用 `getMarketDetails` 获取（目前是 Mock 的）市场数据并展示（问题、选项、资金池、解析状态等）。
    *   **下注交互:** 包含金额输入、下注按钮，调用 `placeBet` 服务，并管理加载、成功、错误状态，提供 UI 反馈。
    *   **领取奖励交互:** 
        *   调用 `getUserShare` 获取（目前是 Mock 的）用户份额。
        *   根据市场状态和用户份额**准确判断**是否显示 "Claim Winnings" 按钮。
        *   包含领取按钮，调用 `claimWinnings` 服务，并管理加载、成功、错误状态，提供 UI 反馈。
*   **问题记录:**
    *   `KNOWN_ISSUES.md`: 创建了文档，记录了在 `predictionMarketService.ts` 中遇到的持续存在的、被暂时忽略的 Linter 错误。
*   **文档记录:**
    *   `PROJECT_STATUS.md`: 创建并维护本文档，同步项目状态。

---

## 3. 当前阶段定义 (创业/产品视角)

项目目前处于 **MVP 开发阶段，已达到可进行内部演示和初步 UX 测试的状态 (Pre-Alpha / Mock-Enabled Demo)**。

*   **已完成:** 核心前端用户流程（查看、连接、下注、领取）的 UI 和交互逻辑已完成，并可通过 Mock 数据进行完整模拟。
*   **待完成:** 与**真实**智能合约的集成和端到端功能验证。

---

## 4. 目前可演示/测试的功能 (产品/Demo 视角)

在当前状态下（无需部署合约，只需运行前端代码），可以演示和测试以下功能：

1.  **钱包连接:** 点击连接按钮，弹出 TonConnect 钱包选择模态框，连接测试网钱包，并在界面上看到连接成功状态和钱包地址。
2.  **市场数据显示:** 查看 `MarketDisplay` 组件显示的（Mock）市场信息。
3.  **模拟下注流程:** 
    *   输入下注金额。
    *   点击对应选项的下注按钮。
    *   观察按钮的加载状态。
    *   看到模拟的成功或失败反馈消息。
    *   （可通过 `window.MOCK_CONFIG.setBetSuccess(false)` 模拟失败场景）。
4.  **模拟市场解决与领取流程:**
    *   （通过 `window.MOCK_CONFIG.setMarketResolved(true, true)` 模拟市场解决且 Yes 获胜）。
    *   观察 `MarketDisplay` 更新为已解决状态。
    *   如果 Mock 配置为用户有获胜份额 (`MOCK_USER_HAS_WINNING_SHARE = true`)，观察到 "Claim Winnings" 按钮出现。
    *   点击 "Claim Winnings" 按钮。
    *   观察按钮的加载状态。
    *   看到模拟的成功或失败反馈消息。
    *   （可通过 `window.MOCK_CONFIG.setUserHasWinningShare(false)` 或 `setClaimSuccess(false)` 模拟不同领取场景）。

**演示价值:** 可以完整地展示应用的核心用户界面和交互流程，验证 UI/UX 设计，收集早期反馈。

---

## 5. 系统架构与交互流程 (技术视角)

### 5.1. 系统组件

当前 MVP 的系统主要由以下几个部分组成：

1.  **前端应用 (Frontend Application):**
    *   **技术栈:** React (TypeScript)
    *   **运行环境:** Telegram Mini App (TMA)
    *   **核心组件:**
        *   `App.tsx` (或主入口): 应用根组件，整合其他组件。
        *   `WalletConnect.tsx`: 处理钱包连接按钮和状态显示。
        *   `MarketDisplay.tsx`: 显示单个预测市场详情、处理下注和领取奖励的交互。
        *   (未来可能有 `MarketList.tsx` 等)
    *   **职责:** 用户界面展示、用户输入处理、状态管理、调用后端服务。
2.  **后端服务层 (Backend Service Layer - Client-Side):**
    *   **技术栈:** TypeScript
    *   **运行环境:** 与前端应用运行在同一环境 (用户浏览器/TMA)。
    *   **核心服务:**
        *   `walletService.ts`: 封装 TonConnect UI 逻辑，提供钱包连接、状态查询、交易发送实例等接口。
        *   `predictionMarketService.ts`: 封装与预测市场智能合约的交互逻辑 (读取数据、发送交易)，**包含 Mock 功能以应对无真实合约的情况**。
    *   **职责:** 隔离前端 UI 与区块链交互的复杂性、管理与 TonConnect 和 TON 节点的连接、构建和发送交易、解析链上数据、处理 Mock 逻辑。
3.  **TON 区块链 (TON Blockchain):**
    *   **核心组件:** 预测市场智能合约 (例如我们设计的 `PredictionMarketV1.tact` 示例)。
    *   **职责:** 存储市场状态 (资金池、份额、结果)、执行业务逻辑 (接收下注、验证、计算、发送奖励)、确保交易的原子性和最终性。
    *   **当前状态:** **尚未部署**，前端和服务层通过 Mock 数据模拟其行为。
4.  **配置与环境 (.env):**
    *   **文件:** `.env` (本地配置，不提交), `.env.example` (模板，提交)
    *   **职责:** 存储环境相关配置，如网络选择 (testnet/mainnet)、API 端点、合约地址、Manifest URL 等，实现应用在不同环境下的灵活性。

### 5.2. 核心交互流程

以下是关键用户操作的交互流程：

1.  **应用加载与钱包连接:**
    *   `App.tsx` 加载，渲染 `<WalletConnect />`。
    *   `WalletConnect.tsx` 初始化，渲染 `<TonConnectButton />`。
    *   用户点击连接按钮。
    *   `<TonConnectButton />` (内部由 `@tonconnect/ui-react` 处理) 调用 `walletService.ts` 中的 `tonConnectUI.openModal()`。
    *   `walletService.ts` 通过 TonConnect 与用户选择的钱包进行握手 (使用 `tonconnect-manifest.json` 进行身份验证)。
    *   连接成功后，`@tonconnect/ui-react` 更新状态。
    *   `WalletConnect.tsx` 通过 `useTonWallet()` Hook 感知到状态变化，调用 `walletService.getConnectedWalletAddress()` 获取并显示用户地址。
2.  **显示市场详情:**
    *   (假设) 用户导航到某个市场，`MarketDisplay.tsx` 被渲染并接收 `marketAddress`。
    *   `MarketDisplay.tsx` 的 `useEffect` Hook 触发。
    *   调用 `predictionMarketService.getMarketDetails(addressObject)`。
    *   `predictionMarketService.ts`:
        *   **Mock 路径:** (如果 `.env` 未配置地址) 返回预设的 Mock 市场数据。
        *   **Real 路径:** (如果 `.env` 已配置) 调用 `TonClient.runMethod()` 向 TON 节点发送请求，调用合约的 `get_market_data` 方法 -> 接收结果 -> **尝试解析**返回的 Tuple 数据 -> 返回 `MarketDetails` 对象。
    *   `MarketDisplay.tsx` 接收到 `MarketDetails` 数据 (或 null/错误)，更新状态并渲染市场信息。
    *   **(Claim Winnings 相关)** 如果市场已解决且钱包已连接，`MarketDisplay.tsx` 接着调用 `predictionMarketService.getUserShare()`。
    *   `predictionMarketService.ts`:
        *   **Mock 路径:** 返回预设的用户份额。
        *   **Real 路径:** 调用 `TonClient.runMethod()` 并传递用户地址参数，调用合约的 `get_user_share` 方法 -> **尝试解析**返回的份额数据 -> 返回 `[yesShare, noShare]`。
    *   `MarketDisplay.tsx` 根据获取的市场状态和用户份额，决定是否渲染 "Claim Winnings" 按钮。
3.  **用户下注 (Place Bet):**
    *   用户在 `MarketDisplay.tsx` 中输入金额，选择结果，点击下注按钮。
    *   `handlePlaceBet` 函数被调用。
    *   函数进行输入验证，检查钱包连接状态 (`useTonWallet()`)。
    *   调用 `predictionMarketService.placeBet({ marketAddress, outcome, amountNano })`。
    *   `predictionMarketService.ts`:
        *   **Mock 路径:** 调用 `mockSendTransaction('bet')`，模拟延迟后返回成功或失败。
        *   **Real 路径:** 
            *   调用 `walletService.getTonConnectInstance()` 获取 `tonConnectUI` 实例。
            *   **构建消息体 (Cell)**，包含我们定义的 `OP_PLACE_BET` 操作码和 `outcome`。
            *   准备 `SendTransactionRequest` 对象。
            *   调用 `tonConnectUI.sendTransaction(request)`。
            *   TonConnect 将请求发送给用户钱包等待签名和发送。
            *   `sendTransaction` 返回 `Promise` (表示已发送给钱包，**不代表**链上成功)。
    *   `MarketDisplay.tsx` 根据 `placeBet` 返回的 Promise 结果 (成功/捕获的错误) 更新 UI，显示加载、成功或错误状态。
4.  **用户领取奖励 (Claim Winnings):**
    *   (假设市场已解决，用户有获胜份额) 用户在 `MarketDisplay.tsx` 中点击 "Claim Winnings" 按钮。
    *   `handleClaimWinnings` 函数被调用。
    *   检查钱包连接状态。
    *   调用 `predictionMarketService.claimWinnings(addressObject)`。
    *   `predictionMarketService.ts`:
        *   **Mock 路径:** 调用 `mockSendTransaction('claim')`。
        *   **Real 路径:** 
            *   获取 `tonConnectUI` 实例。
            *   **构建消息体 (Cell)**，包含 `OP_CLAIM_WINNINGS` 操作码。
            *   准备 `SendTransactionRequest`。
            *   调用 `tonConnectUI.sendTransaction(request)`。
    *   `MarketDisplay.tsx` 根据 `claimWinnings` 返回的结果更新 UI 反馈。

### 5.3. 职责分工 (当前 & 未来)

*   **您 (项目负责人):**
    *   提供最终的产品方向和需求。
    *   **（关键）负责或协调智能合约的最终实现、部署和测试。**
    *   **（关键）负责配置和管理 `.env` 文件中的真实环境变量 (合约地址, Manifest URL, Admin 地址等)。**
    *   **（关键）负责将 `tonconnect-manifest.json` 部署到可公开访问的 URL。**
    *   提供 UI/UX 反馈。
*   **AI (技术伙伴 - 我):**
    *   负责前端 React 组件 (`.tsx`) 和客户端服务层 (`.ts`) 的代码编写和维护。
    *   负责根据需求设计和实现应用架构。
    *   负责实现 Mock 逻辑以支持无后端开发。
    *   根据您提供的合约接口细节，完善服务层与链的交互逻辑（例如，填充 `placeBet` 的消息体构建）。
    *   提供合约设计建议和基础示例 (`PredictionMarketV1.tact`)。
    *   编写和维护项目文档 (`PROJECT_STATUS.md`, `KNOWN_ISSUES.md`)。
*   **智能合约开发者 (可能是您或外部资源):**
    *   负责 Tact/FunC 合约的完整开发、测试、优化和安全审计。
    *   提供准确的合约接口信息（地址、操作码、消息格式、Get 方法签名和返回结构）给前端/服务层。

---

## 6. 后续步骤与优先级 (技术/创业视角)

**P0 - 最高优先级 (阻塞性): 让应用真正运转起来**

1.  **部署合约 & 配置 `.env`:** (负责人: 您/合约开发者)
    *   编译部署 `PredictionMarketV1.tact` 示例或最终合约到 **TON 测试网**。
    *   获取真实测试网合约地址、Admin 地址。
    *   托管 `tonconnect-manifest.json` 并获取 URL。
    *   **完整、正确地配置 `.env` 文件。**

**P1 - 高优先级 (功能完整性):**

2.  **验证/完善服务层解析逻辑:** (负责人: AI + 您/合约开发者)
    *   基于部署后的合约，核对 `getMarketDetails`, `getUserShare` 的解析逻辑。
3.  **核对 Op Codes 和消息体:** (负责人: AI + 您/合约开发者)
    *   基于部署后的合约，确认 `predictionMarketService.ts` 中的 Op Codes 和消息体结构正确。

**P2 - 中优先级 (体验 & 扩展):**

4.  **UI/UX 优化:** (负责人: AI)
    *   改进样式、布局、反馈。
    *   添加赔率显示。
5.  **市场列表功能:** (负责人: AI +/- 合约开发者)
    *   设计获取列表机制。
    *   创建 `MarketList.tsx`。

**P3 - 低优先级 (MVP 后):**

6.  **实现 `resolveMarket` 功能。**
7.  **高级市场机制。**
8.  **交易监控。**
9.  **安全审计。**

---

## 7. 关键挑战与依赖 (风险管理视角)

*   **主要阻塞:** **缺乏已部署的测试网智能合约实例和正确配置的 `.env` 文件。**
*   **次要阻塞/风险:** 
    *   **`tonconnect-manifest.json` 的正确配置和托管。**
    *   **服务层解析逻辑与实际合约的匹配度。**
    *   **合约本身的健壮性和安全性 (当前仅为示例)。**
    *   (已记录) `predictionMarketService.ts` 中的 Linter 错误。

---

请审阅本文档，特别是新增的第 5 节，确保它准确反映了我们的系统和流程。 