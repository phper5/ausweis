# 小米K70 NFC "workflow_card_removed" 错误修复

## 问题描述

在小米K70等设备上，用户在读取身份证过程中偶尔会遇到 "workflow_card_removed" 错误，即使卡片实际上并未移动。

## 根本原因分析

1. **NFC通信超时处理过于严格**: 原始代码设定3秒超时，没有重试机制
2. **错误分类过于简单**: 所有 `COMMAND_FAILED` 都被归类为卡片移除
3. **小米设备NFC特性**: MIUI系统的激进功耗优化可能影响NFC连接稳定性
4. **Android NFC Reader Mode配置**: 缺少针对特定厂商的优化

## 修复方案

### 1. NFC通信层改进 (NfcCard.cpp)

#### 增加设备检测和配置
- 添加设备特定的NFC配置机制
- 小米设备使用增强的稳定性设置:
  - 重试次数: 3 → 4
  - 基础超时: 5秒 → 6秒
  - 重试延迟: 100ms → 150ms
  - 超时重试延迟: 200ms → 300ms

#### 改进的重试机制
- 渐进式超时: 后续重试使用更长的超时时间
- 智能延迟: 不同类型的失败使用不同的重试延迟
- 详细日志: 记录重试过程以便调试

```cpp
// 设备特定配置示例
if (model.contains("k70", Qt::CaseInsensitive)) {
    config.maxRetries = 4;
    config.baseTimeoutMs = 6000;
    config.retryDelayMs = 150;
}
```

### 2. 错误处理逻辑优化 (StateDidAuthenticateEac2.cpp)

#### 智能错误分类
- 区分真正的卡片移除和通信问题
- 检查卡片连接状态来确定错误类型
- 使用更合适的错误码 `Workflow_Reader_Became_Inaccessible`

```cpp
if (getContext()->getCardConnection() && 
    getContext()->getCardConnection()->getReaderInfo().hasCard()) {
    // 卡片仍在，判断为通信问题
    newStatus = GlobalStatus::Code::Workflow_Reader_Became_Inaccessible;
} else {
    // 卡片确实被移除
    newStatus = GlobalStatus::Code::Workflow_Card_Removed;
}
```

### 3. Android平台特定优化 (MainActivity.java)

#### 增强的NFC Reader Mode配置
- 为小米设备添加特殊的轮询配置
- 改进标签连接检查机制
- 优化NFC重置逻辑

```java
// 小米设备特定配置
if (Build.MANUFACTURER.toLowerCase().contains("xiaomi")) {
    options.putInt(NfcAdapter.EXTRA_READER_PRESENCE_CHECK_DELAY, 1000);
}
```

#### 改进的错误恢复
- NFC重置时添加延迟以确保正确清理
- 增强异常处理和日志记录

## 预期效果

1. **显著减少误报**: 通过重试机制和智能错误分类
2. **提高稳定性**: 设备特定的配置优化
3. **更好的用户体验**: 更准确的错误信息
4. **便于调试**: 详细的日志记录

## 兼容性说明

- 所有修改都向后兼容
- 对非小米设备保持原有行为
- 仅在小米等已知有问题的设备上启用增强配置

## 测试建议

1. 在小米K70上进行多次身份证读取测试
2. 验证正常的卡片移除仍能正确检测
3. 测试其他品牌设备的兼容性
4. 监控日志以验证重试机制工作正常

## 文件修改清单

- `src/card/nfc/NfcCard.cpp`: 核心NFC通信改进
- `src/workflows/base/states/StateDidAuthenticateEac2.cpp`: 错误处理优化  
- `src/android/MainActivity.java`: Android平台特定优化

这些修改将显著改善小米K70等设备上的NFC使用体验，减少误报的"卡片移除"错误。