## ADDED Requirements

### Requirement: 记录体重数据
系统 SHALL 存储用户的体重记录，包含：体重(kg)、体脂率(可选)、记录时间。

#### Scenario: 记录体重
- **WHEN** 用户说 "今天 72.5kg"
- **THEN** 系统存储 weight_kg=72.5, recorded_at=当前时间

#### Scenario: 体重+体脂
- **WHEN** 用户说 "72.5kg 体脂22%"
- **THEN** 系统存储 weight_kg=72.5, body_fat_pct=22.0

#### Scenario: 体重秤截图
- **WHEN** 用户发送体重秤照片显示 72.5
- **THEN** 系统 OCR 提取数字并存储 weight_kg=72.5

### Requirement: 趋势体重计算
系统 SHALL 计算 7 日移动平均体重作为趋势体重，消除日常波动。

#### Scenario: 足够数据
- **WHEN** 用户查询趋势体重且过去 7 天有至少 3 条记录
- **THEN** 系统计算 7 日均值并返回

#### Scenario: 数据不足
- **WHEN** 过去 7 天记录少于 3 条
- **THEN** 系统使用已有数据计算均值并提示 "记录天数较少，建议每天称重"

### Requirement: 周均减重速率
系统 SHALL 计算最近一周的平均减重速率（kg/周）。

#### Scenario: 计算减重速率
- **WHEN** 用户查询减重进度
- **THEN** 系统对比本周趋势体重与上周趋势体重，计算周均变化
