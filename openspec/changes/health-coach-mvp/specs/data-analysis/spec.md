## ADDED Requirements

### Requirement: 今日数据快照
系统 SHALL 提供当日的实时数据汇总：已摄入热量、各营养素摄入、已运动消耗、热量缺口。

#### Scenario: 查询今日摘要
- **WHEN** 用户问 "今天吃了多少"
- **THEN** 系统返回今日已记录的总热量、蛋白质/碳水/脂肪、剩余可摄入热量

### Requirement: 周/月摘要
系统 SHALL 提供周度和月度数据汇总，包含平均每日摄入、平均热量缺口、体重变化、运动频率。

#### Scenario: 查询周报
- **WHEN** 用户问 "这周情况怎么样"
- **THEN** 系统返回本周各项指标汇总和趋势

### Requirement: TDEE 计算
系统 SHALL 基于用户档案（身高、体重、年龄、性别、活动量）使用 Mifflin-St Jeor 公式计算 TDEE。

#### Scenario: 计算 TDEE
- **WHEN** 用户完成基础信息录入
- **THEN** 系统计算 TDEE 并存入用户档案

#### Scenario: 体重变化后更新
- **WHEN** 用户体重发生显著变化（趋势体重变化超过 1kg）
- **THEN** 系统自动重新计算 TDEE

### Requirement: 热量缺口计算
系统 SHALL 计算每日热量缺口 = TDEE - 当日摄入热量 + 运动消耗。

#### Scenario: 实时热量缺口
- **WHEN** 用户记录一餐后
- **THEN** 系统在回复中包含当前热量缺口信息

### Requirement: 营养素达标率
系统 SHALL 计算每日蛋白质达标率（基于体重 × 1.6g/kg 目标）。

#### Scenario: 蛋白质达标提醒
- **WHEN** 用户查询今日数据
- **THEN** 系统返回蛋白质已摄入/目标量和达标百分比
