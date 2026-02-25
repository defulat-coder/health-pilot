# Health Pilot

1v1 减脂健康管理 AI 教练 API，基于 Agno AgentOS。

## 技术栈

- Python 3.13+，uv 管理依赖
- Agno AgentOS（FastAPI）
- LLM 可配置（默认 GLM-4.7，.env 可切换为 qwen3.5-plus 等，通过 OpenAILike 适配，支持多模态）
- SQLAlchemy + SQLite（开发）/ PostgreSQL（生产）
- APScheduler（定时推送）

## 项目结构

```
main.py                    # AgentOS 入口 + 通知 REST API + CORS 中间件
config.py                  # 配置管理（pydantic-settings，从 .env 读取）
agents/coach.py            # Coach Agent 定义（动态 instructions + tools + agentic memory）
tools/
  meal_tracker.py          # 饮食记录 tool
  weight_tracker.py        # 体重记录 tool
  exercise_tracker.py      # 运动记录 tool
  data_analyzer.py         # 数据查询（日/周/月摘要、趋势体重、蛋白质达标）
  user_profile_manager.py  # 用户档案管理 + 推送时间设置
models/database.py         # SQLAlchemy 模型（UserProfile/Meal/Weight/Exercise/Notification）
scheduler/push_scheduler.py # 定时+条件推送调度器（含独立 push_agent 生成推送内容）
```

## 架构要点

- 单 Coach Agent + 多自定义 Tools，对话驱动所有交互
- Coach Agent 的 instructions 动态注入用户档案和当日实时数据（`get_user_instructions`）
- 支持多模态输入（文字+图片），自动识别意图并记录结构化数据
- Agno Agentic Memory（SqliteDb）管理长期用户记忆（偏好、行为模式）
- 推送系统：
  - 定时推送（早/午/晚餐提醒、称重提醒、周报）
  - 条件触发推送（热量接近上限、蛋白质不达标、连续达标鼓励、体重平台期）
  - 独立 `push_agent` 生成推送文案，存入 Notification 表，MVP 阶段不接入推送通道
- 通知 REST API：`GET /api/v1/notifications`（查询）、`POST /api/v1/notifications/{id}/read`（标记已读）
- 热量/营养素由 LLM 估算，不依赖食物数据库
- 端口：7777

## 环境变量（.env）

```
LLM_MODEL=qwen3.5-plus
LLM_API_KEY=<key>
LLM_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
DATABASE_URL=sqlite:///health_pilot.db
OS_SECURITY_KEY=<可选，AgentOS 安全密钥>
```

## 启动

```bash
uv run python main.py
```

## 编码规范

- 所有 Tool 函数必须有完整中文 docstring（含 Args），Agno 依赖它生成 tool definition
- Tool 函数通过 `run_context.user_id` 获取当前用户，不要硬编码
- 数据库操作使用 `SessionLocal()`，用 try/finally 确保关闭
- 配置统一走 `config.settings`，不要散落硬编码值
