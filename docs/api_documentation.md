# Sui Agars Marketplace 前端接口文档

## 合约信息

**合约地址（Package ID）**：`0xb0747bb990f7350bb16863567d0539ad373d51aa6afc951afee7ea6f89a488ec`

**包含模块**：
- `agar` - Agar NFT 主模块
- `agarsmarket` - 市场交易功能模块
- `agarsrules` - 交易规则模块
- `agarstransferpolicy` - 转移政策模块

## 1. Agar 相关接口

### 1.1 创建 Agar

```
function mintAgar(author: string, title: string, category: string, story: string)
```

**描述**：创建一个新的 Agar NFT

**参数**：
- `author`: 作者名称
- `title`: Agar 标题
- `category`: 分类
- `story`: 故事背景

**事件**：创建成功后会触发 `AgarCreated` 事件

## 2. 市场相关接口

### 2.1 创建市场

```
function createAgarMarketplace()
```

**描述**：创建一个新的 Agar 市场，用户将获得一个 KioskOwnerCap

### 2.2 上架 Agar

```
function placeAgar(kiosk: Kiosk, cap: KioskOwnerCap, agar: Agar)
```

**描述**：将 Agar 放入市场

### 2.3 设置 Agar 价格

```
function listAgar(kiosk: Kiosk, cap: KioskOwnerCap, agarId: string, price: number)
```

**描述**：设置 Agar 的销售价格

### 2.4 下架 Agar

```
function delistAgar(kiosk: Kiosk, cap: KioskOwnerCap, agarId: string)
```

**描述**：取消 Agar 的销售状态

### 2.5 取回 Agar

```
function unplaceAgar(kiosk: Kiosk, cap: KioskOwnerCap, agarId: string)
```

**描述**：从市场中取回未售出的 Agar

### 2.6 锁定 Agar

```
function lockAgar(kiosk: Kiosk, cap: KioskOwnerCap, policy: TransferPolicy, agar: Agar)
```

**描述**：将 Agar 锁定在市场中，防止被取出

### 2.7 提取销售收益

```
function withdrawProfits(kiosk: Kiosk, cap: KioskOwnerCap, amount?: number)
```

**描述**：提取市场销售的 SUI 收益
**参数**：
- `amount`: 可选，指定提取的金额，不指定则提取全部

## 3. 购买相关接口

### 3.1 购买 Agar

```
function purchaseAgar(kiosk: Kiosk, agarId: string, payment: Coin<SUI>)
```

**描述**：购买一个 Agar
**返回**：Agar 对象和 TransferRequest

## 4. 转移政策相关接口

### 4.1 创建转移政策

```
function newPolicy(publisher: Publisher)
```

**描述**：为 Agar 创建新的转移政策

### 4.2 添加转移规则

```
function addAgarRule(policy: TransferPolicy, cap: TransferPolicyCap, amountBp: number)
```

**描述**：添加 Agar 转移规则，设置交易费用百分比
**参数**：
- `amountBp`: 基点表示的费率（10000 = 100%）

### 4.3 支付转移费用

```
function pay(policy: TransferPolicy, request: TransferRequest, payment: Coin<SUI>)
```

**描述**：支付 Agar 转移所需的费用

## 注意事项

1. 所有接口操作需通过 Sui 钱包签名
2. 交易费用以基点表示，10000 基点 = 100%
3. 使用前需确保用户拥有足够的 SUI 代币支付交易费用
4. 创建市场后需妥善保管 KioskOwnerCap，这是管理市场的唯一凭证 