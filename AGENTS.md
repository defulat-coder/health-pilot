# Health Pilot

1v1 减脂健康管理 AI 教练 API，基于 Agno AgentOS。

## 技术栈

- Python 3.13+，uv 管理依赖
- Agno AgentOS（FastAPI）
- 阿里云百炼 qwen3.5-plus（通过 OpenAILike 适配，多模态）
- SQLAlchemy + SQLite（开发）/ PostgreSQL（生产）
- APScheduler（定时推送）

## 项目结构

```
main.py                  # AgentOS 入口 + 自定义路由（推送查询）
config.py                # 配置管理，从 .env 读取
agents/coach.py          # Coach Agent 定义（instructions + tools + memory）
tools/
  meal_tracker.py        # 饮食记录 tool
  weight_tracker.py      # 体重记录 tool
  exercise_tracker.py    # 运动记录 tool
  data_analyzer.py       # 数据查询（日/周/月摘要、趋势体重、营养素达标率）
  user_profile_manager.py # 用户档案管理 + 推送时间设置
models/database.py       # SQLAlchemy 模型（UserProfile/Meal/Weight/Exercise/Notification）
scheduler/push_scheduler.py # 定时+条件推送调度器
```

## 架构要点

- 单 Coach Agent + 多自定义 Tools，对话驱动所有交互
- 支持多模态输入（文字+图片），自动识别意图并记录结构化数据
- Agno Agentic Memory 管理长期用户记忆（偏好、行为模式）
- 推送系统：APScheduler 定时推送 + 条件触发推送，MVP 阶段只生成内容存 DB，不接入推送通道
- 热量/营养素由 LLM 估算，不依赖食物数据库

## 环境变量（.env）

```
LLM_MODEL=qwen3.5-plus
LLM_API_KEY=<key>
LLM_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
DATABASE_URL=sqlite:///health_pilot.db
```

## 启动

```bash
uv run python main.py
```

## 编码规范

- 所有 Tool 函数必须有完整 docstring（含 Args），Agno 依赖它生成 tool definition
- Tool 函数通过 `run_context.user_id` 获取当前用户，不要硬编码
- 数据库操作使用 `SessionLocal()`，用 try/finally 确保关闭
- 配置统一走 `config.settings`，不要散落硬编码值
