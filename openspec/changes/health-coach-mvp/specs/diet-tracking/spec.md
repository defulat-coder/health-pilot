## ADDED Requirements

### Requirement: 记录饮食数据
系统 SHALL 将每次饮食记录存储为结构化数据，包含：餐次类型（早餐/午餐/晚餐/加餐）、食物描述、热量(kcal)、蛋白质(g)、碳水化合物(g)、脂肪(g)、记录时间。

#### Scenario: 完整记录
- **WHEN** 用户说 "午饭吃了一碗黄焖鸡米饭"
- **THEN** 系统存储 meal_type=lunch, description="黄焖鸡米饭", calories=650, protein=25, carbs=75, fat=20, recorded_at=当前时间

#### Scenario: 多个食物一次记录
- **WHEN** 用户说 "早上吃了两个鸡蛋、一杯牛奶、一片全麦面包"
- **THEN** 系统将所有食物合并为一条饮食记录，热量和营养素为总和

### Requirement: 餐次自动推断
系统 SHALL 根据记录时间自动推断餐次类型，用户也可以显式指定。

#### Scenario: 按时间推断
- **WHEN** 用户在 12:30 记录饮食且未指定餐次
- **THEN** 系统自动标记为 lunch

#### Scenario: 用户显式指定
- **WHEN** 用户说 "下午加餐吃了一根香蕉"
- **THEN** 系统标记为 snack

### Requirement: LLM 估算热量和营养素
系统 SHALL 使用 LLM 对用户描述或图片中的食物进行热量和三大营养素估算。

#### Scenario: 文字描述估算
- **WHEN** 用户描述 "一碗番茄鸡蛋面"
- **THEN** LLM 估算热量和营养素并存储

#### Scenario: 图片识别估算
- **WHEN** 用户发送食物照片
- **THEN** LLM 识别食物并估算热量和营养素
