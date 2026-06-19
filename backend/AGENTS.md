# Backend Agent Guide

本文件适用于 `backend/` 目录。

## 项目定位

后端是 Health Pilot 的 1v1 减脂健康管理 AI 教练 API，基于 Agno AgentOS/FastAPI。它负责对话、工具调用、结构化健康记录、用户档案、长期记忆、健康摘要和主动关怀推送。

## 技术栈

- Python 3.13+，依赖管理使用 `uv`。
- Agno AgentOS + FastAPI。
- LLM 通过 `agno.models.openai.OpenAILike` 适配，主模型、视觉模型和 base URL 均从 `.env`/`config.settings` 读取。
- SQLAlchemy + SQLite 开发数据库，生产可切 PostgreSQL。
- APScheduler 负责定时和条件触发推送。

## 目录结构

```text
main.py                     # AgentOS 入口、REST API、CORS、lifespan
config.py                   # pydantic-settings 配置
agents/coach.py             # Coach Agent、动态 instructions、memory、tools 注册
tools/                      # 饮食/体重/运动/分析/档案/视觉/备餐工具
models/database.py          # SQLAlchemy models、SessionLocal、init_db
scheduler/push_scheduler.py # 定时推送、条件触发、push_agent
evaluation/test_cases.md    # 人工评测用例
openspec/                   # 需求/变更规格
AGENT_DESIGN.md             # Agent prompt 与机制说明
```

## 架构约束

- 主对话入口是 `coach_agent`。新增业务能力优先作为 tool 接入，而不是在 REST handler 中绕过 Agent 复制逻辑。
- `get_user_instructions` 会动态注入用户档案、当天摄入/运动数据和最近主动推送上下文；修改 prompt 时要保持新用户引导、健康安全边界和推送闭环。
- Tool 函数必须通过 `run_context.user_id` 获取用户，不要硬编码用户 ID。REST 查询接口可保留显式 `user_id` 参数。
- 所有 Tool 函数必须有完整中文 docstring，并包含 `Args`。Agno 依赖 docstring 生成 tool definition。
- 数据库访问使用 `SessionLocal()`，必须用 `try/finally` 关闭 session；写入后明确 `commit`，失败路径要 `rollback`。
- 配置只能从 `config.settings` 读取，不要在业务代码中散落模型名、base URL、数据库路径或 API key。
- 热量、营养素和运动消耗由 LLM/工具估算时必须表达为估算值，不要伪装成医学或检测结论。
- 不提供医疗诊断、药物建议或极端节食建议；涉及疾病、药物、孕产、进食障碍等高风险场景要建议咨询医生或专业人士。

## API 与运行

默认端口：`7777`。

主要端点：

- `POST /agents/health-coach/runs`：AgentOS 对话入口。
- `GET /api/v1/notifications?user_id=xxx`：查询推送通知。
- `POST /api/v1/notifications/{id}/read`：标记通知已读。
- `GET /api/v1/health-summary?user_id=default`：给客户端使用的今日健康摘要。
- `GET /health`：健康检查。
- `GET /docs`：FastAPI 文档。

启动：

```bash
cd backend
uv sync
uv run python main.py
```

环境变量示例：

```bash
LLM_MODEL=qwen3.5-plus
LLM_API_KEY=<key>
LLM_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
VISION_LLM_MODEL=qwen-vl-plus
VISION_LLM_API_KEY=<key>
VISION_LLM_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
DATABASE_URL=sqlite:///health_pilot.db
OS_SECURITY_KEY=<optional>
```

## 验证

后端当前没有专门测试套件时，至少做语法级验证：

```bash
cd backend
uv run python -m compileall .
```

涉及 API、数据库或 scheduler 改动时，启动服务并验证：

```bash
cd backend
uv run python main.py
curl http://localhost:7777/health
curl 'http://localhost:7777/api/v1/health-summary?user_id=default'
```

如果本地没有可用 LLM key，说明哪些路径无法真实调用，并尽量验证不依赖外部模型的导入、数据库初始化和 REST 查询。

## 生成物与密钥

不要提交 `.env`、`health_pilot.db`、`.venv/`、`__pycache__/`、`*.pyc` 或本机 IDE 文件。新增配置项时同步更新 `.env.example`，但不要写入真实 key。
