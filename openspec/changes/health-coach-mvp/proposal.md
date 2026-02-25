## Why

需要构建一个 1v1 减脂健康管理 AI 教练，通过对话驱动（支持文字+图片）自动追踪用户的饮食、体重、运动数据，并提供个性化减脂建议和主动推送提醒，帮助减脂人群持续、科学地管理体重。

## What Changes

- 新建基于 Agno AgentOS 的 API 服务，作为整个系统的技术底座
- 创建 Coach Agent，支持多模态对话（文字+食物照片/外卖截图/体重秤截图/运动App截图）
- 实现自定义 Tools：饮食记录、体重记录、运动记录、数据查询与分析
- 对话中自动识别意图并记录结构化数据（默认记录，告知结果，无需用户确认）
- 基于 Agno Memory 实现长期用户记忆（偏好、行为模式、历史洞察）
- 实现主动推送系统：定时推送（餐食提醒/称重提醒/周报）+ 条件触发推送（未记录/热量超标/蛋白不足/平台期）
- 推送时间支持系统内置默认 + 用户自定义
- MVP 阶段推送只生成内容并存储，不接入具体推送通道
- PostgreSQL 存储所有结构化数据（饮食/体重/运动/用户档案/推送记录）

## Capabilities

### New Capabilities

- `coach-conversation`: 多模态对话核心能力，意图识别、图片理解、自动数据记录、减脂问答与情绪支持
- `diet-tracking`: 饮食追踪，记录每餐食物/热量/三大营养素，支持文字描述和图片识别
- `weight-tracking`: 体重追踪，记录体重/体脂，计算趋势体重(7日均值)和周均减重速率
- `exercise-tracking`: 运动追踪，记录运动类型/时长/消耗卡路里
- `data-analysis`: 数据分析，日/周/月摘要、TDEE计算、热量缺口、营养素达标率、趋势分析
- `proactive-push`: 主动推送，定时+条件触发的个性化推送内容生成与存储
- `user-profile`: 用户档案管理，基础信息采集、目标设定、推送时间偏好

### Modified Capabilities

（无，全新项目）

## Impact

- **新增依赖**: agno, sqlalchemy, psycopg2, apscheduler
- **数据库**: 新建 PostgreSQL 数据库，包含 meals/weights/exercises/user_profiles/notifications 等自定义表 + Agno 内置的 sessions/memories 表
- **API**: AgentOS 提供 50+ 内置端点 + 自定义推送相关端点
- **外部服务**: LLM API（Claude，多模态）
