## 1. 项目基础设施

- [x] 1.1 添加依赖：agno, sqlalchemy, psycopg2-binary, apscheduler, pydantic
- [x] 1.2 创建项目目录结构：agents/, tools/, models/, scheduler/, config.py
- [x] 1.3 创建配置管理 config.py（数据库URL、LLM API Key、默认推送时间等）

## 2. 数据模型

- [x] 2.1 创建 SQLAlchemy 模型：UserProfile（身高/体重/年龄/性别/活动量/目标/TDEE/push_schedule）
- [x] 2.2 创建 SQLAlchemy 模型：Meal（user_id/meal_type/description/calories/protein/carbs/fat/recorded_at）
- [x] 2.3 创建 SQLAlchemy 模型：Weight（user_id/weight_kg/body_fat_pct/recorded_at）
- [x] 2.4 创建 SQLAlchemy 模型：Exercise（user_id/exercise_type/duration_minutes/calories_burned/recorded_at）
- [x] 2.5 创建 SQLAlchemy 模型：Notification（user_id/trigger_type/trigger_name/content/delivered）
- [x] 2.6 创建数据库初始化和表创建逻辑

## 3. 自定义 Tools

- [x] 3.1 实现 MealTracker Tool：接收食物信息参数，写入 meals 表，返回记录摘要
- [x] 3.2 实现 WeightTracker Tool：接收体重/体脂参数，写入 weights 表，返回记录摘要
- [x] 3.3 实现 ExerciseTracker Tool：接收运动信息参数，写入 exercises 表，返回记录摘要
- [x] 3.4 实现 DataAnalyzer Tool：查询今日摘要（总热量/营养素/运动消耗/热量缺口）
- [x] 3.5 DataAnalyzer 扩展：周/月摘要查询
- [x] 3.6 DataAnalyzer 扩展：趋势体重计算（7日移动平均）和周均减重速率
- [x] 3.7 DataAnalyzer 扩展：营养素达标率计算（蛋白质 vs 体重×1.6g/kg）
- [x] 3.8 实现 UserProfileManager Tool：创建/更新用户档案，TDEE 计算（Mifflin-St Jeor）

## 4. Coach Agent

- [x] 4.1 编写 Coach Agent instructions（减脂教练人设、意图识别引导、安全边界、追问逻辑）
- [x] 4.2 创建 Coach Agent：配置模型(Claude)、Tools、Memory、Storage
- [x] 4.3 配置 Agno Agentic Memory（enable_agentic_memory=True + MemoryManager）
- [x] 4.4 配置对话历史（add_history_to_context + num_history_runs）

## 5. 主动推送系统

- [x] 5.1 实现推送内容生成逻辑：调用 LLM 结合用户数据生成个性化推送
- [x] 5.2 实现定时推送调度器：APScheduler 按用户 push_schedule 触发
- [x] 5.3 实现条件触发检查：每次数据记录后检查条件（热量超标/蛋白不足/未记录/连续达标/平台期）
- [x] 5.4 推送存储：写入 notifications 表
- [x] 5.5 推送查询 API：GET 未读推送列表

## 6. AgentOS 集成

- [x] 6.1 创建 main.py：AgentOS 入口，注册 Coach Agent
- [x] 6.2 集成 APScheduler 到 AgentOS lifespan（启动时初始化调度器）
- [x] 6.3 添加推送相关自定义路由（查询推送、更新推送时间偏好）
