# Health Pilot

1v1 减脂健康管理 AI 教练 API，基于 Agno AgentOS。

## 功能

- 多模态对话（文字 + 图片），自动识别饮食/体重/运动并记录
- 食物照片、外卖截图、体重秤截图、运动App截图识别
- 每日/每周/每月数据摘要，趋势体重，营养素达标率
- 长期用户记忆（饮食偏好、行为模式）
- 主动推送提醒（餐食提醒、称重提醒、周报、条件触发）

## 技术栈

- Python 3.13+ / uv
- Agno AgentOS（FastAPI）
- 阿里云百炼 qwen3.5-plus（多模态，OpenAI 兼容）
- SQLAlchemy + SQLite（开发）/ PostgreSQL（生产）
- APScheduler（定时推送）

## 快速开始

```bash
# 安装依赖
uv sync

# 配置环境变量
cp .env.example .env
# 编辑 .env 填入 API Key

# 启动
uv run python main.py
```

服务启动后运行在 `http://localhost:7777`。

## 环境变量

```
LLM_MODEL=qwen3.5-plus
LLM_API_KEY=<your-api-key>
LLM_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
```

## API

| 端点 | 说明 |
|------|------|
| `POST /agents/health-coach/runs` | 对话（支持文字+图片） |
| `GET /api/v1/notifications?user_id=xxx` | 查询推送通知 |
| `POST /api/v1/notifications/{id}/read` | 标记已读 |
| `GET /health` | 健康检查 |
| `GET /docs` | API 文档 |
