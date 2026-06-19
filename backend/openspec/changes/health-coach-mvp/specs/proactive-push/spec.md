## ADDED Requirements

### Requirement: 定时推送
系统 SHALL 按照预设时间为每个用户生成推送内容，默认时间：早餐提醒(7:30)、午餐提醒(11:30)、晚餐提醒(17:30)、称重提醒(8:00)、周报(周日 20:00)。

#### Scenario: 午餐提醒
- **WHEN** 到达用户的午餐提醒时间
- **THEN** 系统生成个性化推送 "午饭时间到了，今天已摄入 Xkcal，还剩 Ykcal，建议吃 xxx"

#### Scenario: 周报推送
- **WHEN** 到达周日 20:00
- **THEN** 系统生成本周数据摘要推送

### Requirement: 条件触发推送
系统 SHALL 在满足特定条件时生成推送内容。

#### Scenario: 长时间未记录
- **WHEN** 用户当天超过一个用餐时段未记录饮食
- **THEN** 系统生成提醒 "今天还没记录午餐，吃了什么呀？"

#### Scenario: 热量接近上限
- **WHEN** 用户当日摄入热量达到目标的 90%
- **THEN** 系统生成提醒 "今天已摄入 Xkcal，距离上限还剩 Ykcal，晚餐注意控量哦"

#### Scenario: 蛋白质不达标
- **WHEN** 到达晚餐时段且蛋白质摄入低于目标的 50%
- **THEN** 系统生成建议 "蛋白质还差 Xg，晚上可以加个鸡胸肉/鸡蛋"

#### Scenario: 连续达标鼓励
- **WHEN** 用户连续 3 天热量缺口在合理范围
- **THEN** 系统生成鼓励 "连续3天完美达标，继续保持！"

#### Scenario: 体重平台期
- **WHEN** 趋势体重连续 7 天变化小于 0.1kg
- **THEN** 系统生成建议 "体重似乎进入平台期了，要不要聊聊调整方案？"

### Requirement: 推送内容个性化生成
系统 SHALL 使用 LLM 结合用户档案、今日数据、长期记忆生成推送内容，而非使用固定模板。

#### Scenario: 个性化饮食推荐
- **WHEN** 生成午餐提醒
- **THEN** 推送内容基于用户饮食偏好（如不吃辣、偏好鸡肉）推荐具体菜品

### Requirement: 推送时间可自定义
用户 SHALL 能够自定义各类推送的触发时间，覆盖系统默认值。

#### Scenario: 修改午餐提醒时间
- **WHEN** 用户说 "把午餐提醒改到12点"
- **THEN** 系统更新该用户的午餐提醒时间为 12:00

### Requirement: 推送存储
MVP 阶段系统 SHALL 将生成的推送内容存入 notifications 表，标记 delivered=false，不接入实际推送通道。

#### Scenario: 存储推送
- **WHEN** 系统生成一条推送内容
- **THEN** 存入 notifications 表，包含 user_id、trigger_type、trigger_name、content、delivered=false
