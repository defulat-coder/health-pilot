## ADDED Requirements

### Requirement: 记录运动数据
系统 SHALL 存储用户的运动记录，包含：运动类型、时长(分钟)、消耗卡路里、记录时间。

#### Scenario: 文字记录
- **WHEN** 用户说 "跑步30分钟"
- **THEN** 系统存储 exercise_type="跑步", duration_minutes=30, calories_burned=LLM估算值

#### Scenario: 运动App截图
- **WHEN** 用户发送运动App截图显示 "跑步 5.2km 32分钟 消耗320kcal"
- **THEN** 系统提取并存储 exercise_type="跑步", duration_minutes=32, calories_burned=320

### Requirement: 运动消耗估算
系统 SHALL 使用 LLM 根据运动类型、时长和用户体重估算消耗卡路里。

#### Scenario: 估算消耗
- **WHEN** 用户说 "游泳了45分钟" 且用户体重 75kg
- **THEN** LLM 估算消耗卡路里并存储
