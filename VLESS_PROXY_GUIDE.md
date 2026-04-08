# 代理设置指南 - VLESS 链接导入

## 🌐 功能概述

在 **"网络代理"** 标签页中，我们添加了两种设置代理的方式：

### 1️⃣ 直接填写代理地址（基础代理设置）
- **支持格式**: `http://127.0.0.1:7897` 或 `https://proxy.example.com:443`
- **用途**: 为所有网络请求配置统一的代理

### 2️⃣ 从 VLESS 链接导入（新增功能）
- **支持格式**: 标准的 VLESS 链接
- **示例**: `vless://user@example.com:443?security=tls&sni=example.com#My-Proxy`

## 📋 VLESS 链接格式说明

标准 VLESS 链接格式：
```
vless://[user-id]@[host]:[port]?[parameters]#[remarks]
```

### 参数说明
| 参数 | 说明 | 示例 |
|------|------|------|
| `user-id` | 用户标识（可选） | `user123` |
| `host` | 服务器地址 | `example.com` |
| `port` | 端口号 | `443` |
| `security` | 安全方式 | `tls` 或 `none` |
| `sni` | SNI 标识 | `example.com` |
| `remarks` | 节点备注 | `My-Proxy` |

### 常见 VLESS 链接示例

#### 示例 1: 带 TLS 的 VLESS
```
vless://user@proxy.example.com:443?security=tls&sni=proxy.example.com#Example-TLS
```

#### 示例 2: 不带 TLS 的 VLESS
```
vless://user@127.0.0.1:8080?security=none#Local-Proxy
```

#### 示例 3: 完整的 VLESS（带 TLS Fingerprint）
```
vless://uuid@domain.com:443?security=tls&sni=domain.com&fp=chrome#My-Proxy
```

## 🚀 使用步骤

1. **进入代理配置页面**
   - 点击左侧菜单 "🌐 网络代理"

2. **选择配置方式**

   **方案 A: 直接填写（简单）**
   - 在 "全局默认代理" 字段填入代理地址
   - 例如: `http://127.0.0.1:7897`

   **方案 B: VLESS 链接导入（推荐）**
   - 复制你的 VLESS 链接
   - 粘贴到 "VLESS 链接 (可选)" 文本框
   - 点击 "🔍 解析 VLESS" 按钮
   - 查看解析结果（主机、端口、协议）
   - 点击 "✅ 应用此代理" 按钮

3. **保存配置**
   - 配置完成后，点击页面底部 "💾 保存并热重载配置" 按钮
   - 系统将自动应用新的代理设置

## 🔍 解析流程示意

```
粘贴 VLESS 链接
       ↓
点击 "解析 VLESS"
       ↓
系统解析链接参数
       ↓
显示解析结果（主机、端口、协议）
       ↓
点击 "应用此代理"
       ↓
自动填入"全局默认代理"字段
       ↓
保存配置
       ↓
生效
```

## 📝 解析规则

系统将按以下规则解析 VLESS 链接：

1. **协议判断**:
   - 如果 `security=tls` 或 端口为 443，则使用 `https://`
   - 否则使用 `http://`

2. **URL 构建**:
   ```
   最终代理地址 = [协议]://[主机]:[端口]
   ```

3. **示例转换**:
   ```
   输入:  vless://user@example.com:443?security=tls#Pro
   输出:  https://example.com:443
   
   输入:  vless://user@127.0.0.1:8080?security=none#Local
   输出:  http://127.0.0.1:8080
   ```

## ⚠️ 注意事项

- VLESS 链接中的 `user-id` 字段主要用于标识，生成代理URL时不需要用户信息
- 系统会自动判断是否使用 TLS 协议
- 如果需要自定义代理地址，可以直接在 "全局默认代理" 字段修改
- 点击 "清空" 按钮可以清除 VLESS 输入框和解析结果

## 🔧 常见问题

**Q: VLESS 链接格式有误会怎样？**
A: 系统会弹出错误提示，请检查链接格式是否符合标准

**Q: 解析后可以修改代理地址吗？**
A: 可以。点击应用后，可以在 "全局默认代理" 字段直接修改

**Q: Clash 代理池和 VLESS 导入可以同时使用吗？**
A: 可以。全局默认代理是基础设置，Clash 代理池是高级功能，两者可以配合使用

## 💡 最佳实践

- 优先使用 VLESS 链接导入，系统会自动验证格式
- 定期检查代理连接状态
- 如果代理失效，及时更新链接
- 保存配置后可在日志中查看代理是否已生效

---

**更新时间**: 2026 年 4 月 8 日
