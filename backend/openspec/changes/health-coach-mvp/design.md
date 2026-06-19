## Context

全新项目，基于 Agno AgentOS 构建减脂 AI 教练 API。Agno 提供 Agent 运行时、Session/Memory 管理、FastAPI 服务框架，我们在此基础上实现业务逻辑。

技术栈：Python + Agno AgentOS + PostgreSQL + Claude (多模态) + APScheduler + uv

## Goals / Non-Goals

**Goals:**

- 通过单一对话接口完成所有交互（记录、查询、问答）
- 支持图片输入（食物照片、外卖截图、体重秤截图、运动App截图）
- 自动提取结构化数据并持久化
- 个性化长期记忆
- 定时+条件触发的主动推送内容生成

**Non-Goals:**

- 不做前端 UI（纯 API）
- 不接入推送通道（MVP 只生成+存储）
- 不做多用户权限体系（MVP 用 user_id 区分即可）
- 不做食物数据库精确查询（依赖 LLM 估算）
- 不做设备接入（手环/体脂秤蓝牙等）
- 不提供医疗建议

## Decisions

### 1. 单 Agent + 多 Tools（而非多 Agent Team）

单个 Coach Agent 配备多个自定义 Tool，通过 instructions 引导 Agent 根据意图调用对应 Tool。

理由：MVP 阶段对话场景单一（减脂），单 Agent 的 prompt 不会过于膨胀。多 Agent 增加延迟和调试复杂度，后续如需拆分可平滑迁移到 Agno Team。

### 2. 记忆策略：Agno Agentic Memory

使用 `enable_agentic_memory=True`，让 Agent 自主决定哪些信息值得记忆。

理由：相比 `update_memory_on_run=True`（每次都跑 MemoryManager），agentic 模式更高效，减少不必要的 LLM 调用。用户的饮食偏好、行为模式等由 Agent 判断后自动存入 Memory。

### 3. 饮食记录：LLM 估算，非数据库查询

用户描述或发送图片后，由 LLM 直接估算热量和营养素，不维护食物数据库。

理由：降低 MVP 复杂度。LLM 对常见食物的热量估算精度足够用于减脂场景（允许 ±15% 误差）。后续可增加食物数据库作为 Tool 辅助校准。

### 4. 数据模型设计

```
user_profiles
├── id (PK)
├── user_id (unique)
├── height_cm, age, gender
├── activity_level
├── target_weight_kg
├── target_rate_kg_per_week
├── tdee_kcal (计算值)
├── push_schedule (JSON: 自定义推送时间)
├── created_at, updated_at

meals
├── id (PK)
├── user_id
├── meal_type (breakfast/lunch/dinner/snack)
├── description (原始描述/图片识别结果)
├── calories_kcal
├── protein_g, carbs_g, fat_g
├── recorded_at
├── created_at

weights
├── id (PK)
├── user_id
├── weight_kg
├── body_fat_pct (nullable)
├── recorded_at
├── created_at

exercises
├── id (PK)
├── user_id
├── exercise_type
├── duration_minutes
├── calories_burned
├── recorded_at
├── created_at

notifications
├── id (PK)
├── user_id
├── trigger_type (scheduled/conditional)
├── trigger_name (lunch_reminder/protein_low/...)
├── content (LLM 生成的推送内容)
├── delivered (boolean, 预留给推送通道)
├── created_at
```

Agno 内置表（sessions, memories）由框架自动管理。

### 5. 主动推送架构

使用 APScheduler 运行定时任务，每个用户的推送时间独立配置。

流程：
1. Scheduler 到达触发时间 → 查询用户今日数据
2. 调用 LLM 生成个性化推送内容（结合用户档案+今日摄入+历史偏好）
3. 存入 notifications 表
4. 条件触发：在每次数据记录后检查条件（热量超标、蛋白不足等），满足则触发

### 6. 项目结构

```
health-pilot/
├── main.py                    # AgentOS 入口
├── agents/
│   └── coach.py               # Coach Agent 定义
├── tools/
│   ├── meal_tracker.py        # 饮食记录 Tool
│   ├── weight_tracker.py      # 体重记录 Tool
│   ├── exercise_tracker.py    # 运动记录 Tool
│   └── data_analyzer.py       # 数据查询与分析 Tool
├── models/
│   └── database.py            # SQLAlchemy 模型
├── scheduler/
│   └── push_scheduler.py      # 推送调度器
├── config.py                  # 配置管理
└── pyproject.toml
```

## Risks / Trade-offs

- **LLM 热量估算不准** → 可接受，减脂场景追求趋势而非绝对精确，后续可加食物数据库校准
- **图片识别失败** → Agent 应主动追问 "没看清，能描述一下吗？"，通过 instructions 引导
- **推送内容生成成本** → 每次推送需调用 LLM，用户量大时成本上升 → 可缓存相似推送模板
- **单 Agent prompt 膨胀** → 当前场景可控，后续可拆分为 Agno Team
- **APScheduler 单进程** → MVP 够用，生产环境可换分布式调度（Celery/Temporal）
