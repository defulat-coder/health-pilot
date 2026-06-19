## ADDED Requirements

### Requirement: 基础信息采集
系统 SHALL 通过对话引导用户提供基础信息：身高(cm)、体重(kg)、年龄、性别、日常活动量（久坐/轻度活动/中度活动/重度活动）。

#### Scenario: 新用户首次对话
- **WHEN** 新用户发送第一条消息
- **THEN** Agent 引导用户逐步提供基础信息

#### Scenario: 信息不完整
- **WHEN** 用户只提供了身高和体重
- **THEN** Agent 继续询问年龄、性别和活动量

### Requirement: 目标设定
系统 SHALL 支持用户设定目标体重和期望减重速率。

#### Scenario: 设定目标
- **WHEN** 用户说 "我想减到 65kg，一周减 0.5kg"
- **THEN** 系统存储 target_weight_kg=65, target_rate_kg_per_week=0.5

#### Scenario: 默认速率
- **WHEN** 用户只设定目标体重未指定速率
- **THEN** 系统使用默认安全速率 0.5kg/周

### Requirement: TDEE 自动计算
系统 SHALL 在基础信息完整后自动计算 TDEE 并存储。

#### Scenario: 信息完整后计算
- **WHEN** 用户基础信息全部录入
- **THEN** 系统使用 Mifflin-St Jeor 公式计算 TDEE 并告知用户

### Requirement: 推送时间偏好
系统 SHALL 支持用户自定义推送时间，存储在用户档案的 push_schedule 字段中。

#### Scenario: 自定义推送时间
- **WHEN** 用户说 "早餐提醒改到 8 点，午餐提醒改到 12 点"
- **THEN** 系统更新 push_schedule 并应用到调度器
