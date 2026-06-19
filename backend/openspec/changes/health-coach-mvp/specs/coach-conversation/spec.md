## ADDED Requirements

### Requirement: 多模态消息输入
系统 SHALL 接受用户的文字消息和图片消息（支持同时发送），通过单一对话接口处理所有交互。

#### Scenario: 纯文字消息
- **WHEN** 用户发送文字消息 "中午吃了一碗牛肉面"
- **THEN** 系统识别为饮食记录意图，提取食物信息并调用饮食记录 Tool

#### Scenario: 图片+文字消息
- **WHEN** 用户发送一张食物照片并附文字 "这是我的午餐"
- **THEN** 系统通过多模态 LLM 识别图片中的食物，提取结构化数据并记录

#### Scenario: 纯图片消息
- **WHEN** 用户只发送一张外卖订单截图
- **THEN** 系统 OCR 识别截图中的菜品和份数，估算热量并记录

### Requirement: 意图自动识别
系统 SHALL 自动识别用户消息的意图类型：饮食记录、体重记录、运动记录、数据查询、减脂问答、闲聊/情绪支持。

#### Scenario: 饮食记录意图
- **WHEN** 用户发送 "早上吃了两个鸡蛋一杯牛奶"
- **THEN** 系统识别为饮食记录，调用 meal_tracker Tool

#### Scenario: 体重记录意图
- **WHEN** 用户发送 "今天 72.5kg"
- **THEN** 系统识别为体重记录，调用 weight_tracker Tool

#### Scenario: 运动记录意图
- **WHEN** 用户发送 "跑了5公里 用了30分钟"
- **THEN** 系统识别为运动记录，调用 exercise_tracker Tool

#### Scenario: 数据查询意图
- **WHEN** 用户发送 "今天吃了多少卡路里"
- **THEN** 系统调用 data_analyzer Tool 查询今日摄入数据并回复

#### Scenario: 减脂问答
- **WHEN** 用户发送 "平台期怎么办"
- **THEN** 系统基于用户历史数据和减脂知识给出个性化建议

### Requirement: 默认记录并告知
系统 SHALL 在识别到记录意图后直接记录数据并告知用户结果，无需用户确认。

#### Scenario: 自动记录饮食
- **WHEN** 系统从用户消息中提取到食物信息
- **THEN** 系统直接存储记录，并回复 "已记录：牛肉面 约650kcal（蛋白质28g 碳水80g 脂肪18g）"

### Requirement: 图片类型识别
系统 SHALL 支持识别以下类型的图片：食物实拍、外卖订单截图、体重秤照片、运动App截图、体脂秤App截图、营养标签。

#### Scenario: 体重秤截图
- **WHEN** 用户发送体重秤显示屏照片
- **THEN** 系统 OCR 提取体重数字并调用 weight_tracker 记录

#### Scenario: 运动App截图
- **WHEN** 用户发送运动App的运动记录截图
- **THEN** 系统提取运动类型、时长、消耗卡路里并调用 exercise_tracker 记录

### Requirement: 信息不足时追问
当 LLM 无法从消息中提取足够信息时，系统 SHALL 主动追问缺失信息。

#### Scenario: 图片模糊
- **WHEN** 用户发送的食物照片模糊无法识别
- **THEN** 系统回复 "照片不太清楚，能描述一下吃了什么吗？"

#### Scenario: 份量不明确
- **WHEN** 用户说 "吃了点米饭" 但未说明量
- **THEN** 系统回复 "大概吃了多少米饭？一小碗还是一大碗？"

### Requirement: 安全边界
系统 MUST NOT 提供医疗诊断、开药处方、鼓励极端节食行为。

#### Scenario: 用户询问医疗建议
- **WHEN** 用户问 "我血糖偏高该吃什么药"
- **THEN** 系统回复建议咨询医生，不提供药物建议
