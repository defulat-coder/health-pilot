# Design: 主动关怀与对话发起机制

## 架构概览
本次改动在现有基于 Agno AgentOS 和 SQLAlchemy 的基础上，重点增强 `agents/coach.py` 的上下文感知能力，并将 `scheduler/push_scheduler.py` 中的静态逻辑转为事件驱动和定时扫描双管齐下的模式。

### 核心组件变更
1. **Coach Agent (`agents/coach.py`)**: 在生成 `instructions` 时，查询最近的未读 `Notification`。
2. **Meal Tracker (`tools/meal_tracker.py`)**: 数据持久化后，触发条件检查。
3. **Weight Tracker (`tools/weight_tracker.py`)**: 同上。
4. **Push Scheduler (`scheduler/push_scheduler.py`)**: 增加每日“沉默用户”扫描任务，生成关怀推送。
5. **REST API (`main.py`)**: 修改获取未读通知的逻辑，可能需要调整结构以支持前端聊天流渲染。

## 详细设计

### 1. 记忆闭环打通
- **目标**: 让 Coach 知道系统最近给用户发了什么主动消息。
- **实现**: 在 `get_user_instructions(user_id)` 中，增加一个数据库查询：
  ```python
  from models.database import Notification
  from datetime import datetime, timedelta

  two_hours_ago = datetime.utcnow() - timedelta(hours=2)
  recent_push = session.query(Notification).filter(
      Notification.user_id == user_id,
      Notification.created_at >= two_hours_ago,
      Notification.delivered == False # 或无论是否已读，只要是最近的
  ).order_by(Notification.created_at.desc()).first()
  ```
- **Prompt 注入**: 如果存在 `recent_push`，在基础 `instructions` 后面追加：
  > "【系统上下文】系统在 {时间} 刚刚向用户发送了主动关怀消息：『{recent_push.content}』。如果用户当前的输入看起来是在回复这句话，请你顺着这个语境继续对话。"

### 2. 实时条件触发 (Event-Driven)
- **目标**: 在记录高热量饮食或体重变化后，立即触发预警或鼓励。
- **实现**: 在 `tools/meal_tracker.py` 的 `record_meal` 函数末尾，数据 `session.commit()` 之后，调用 `scheduler.push_scheduler.check_conditional_triggers(user_id, session)`。
  - **注意**: 为了不阻塞当前的工具响应（用户需要立刻知道记录成功），这部分可以包装在一个 `asyncio.create_task`（如果是异步）或者简单的线程/后台任务中。如果为了简单，直接同步调用也是可以接受的（如果耗时短）。
- **同理**: 在 `weight_tracker.py` 的 `record_weight` 后也调用此函数。

### 3. 沉默唤醒 (Chaser)
- **目标**: 针对连续 24/48 小时未记录任何数据的用户，发送关怀。
- **实现**: 在 `scheduler/push_scheduler.py` 中新增一个定时任务（例如每天 20:00 运行）：
  ```python
  def check_silent_users():
      # 查询过去 24 小时没有 Meal 和 Exercise 记录的用户
      # 对这些用户，生成 trigger_type='conditional', trigger_name='silent_wakeup' 的通知
      # 调用 push_agent 生成：“忙了一天辛苦啦！今天还没见你记录饮食，是太忙了没顾上，还是想给自己放个假呀？不管怎样，记得好好吃饭哦~”
  ```
- 将此任务加入到 `BackgroundScheduler` 中。

### 4. 前端渲染支持 (API 调整)
- **目标**: 确保端侧能把通知当成 AI 教练的话。
- **实现**: 检查 `main.py` 中的 `GET /api/v1/notifications` 接口。确保返回的数据结构能够清晰区分这些是“系统主动发出的对话”。目前的模型已有 `trigger_type` 和 `content`，前端（假设存在）可以轮询此接口。当拉取到新的未读通知时，前端将其展示在聊天界面左侧（AI 的气泡），然后立即调用 `POST /api/v1/notifications/{id}/read` 将其标记为已读。这部分主要是约定，后端只需确保接口正常。

## 数据模型变更
- 本次不需要修改现有的数据库表结构。`Notification` 表已具备足够的字段 (`user_id`, `trigger_type`, `trigger_name`, `content`, `delivered`, `created_at`)。

## 潜在风险与缓解
1. **循环触发**: 实时调用 `check_conditional_triggers` 时，必须确保其内部的防重复逻辑（比如 `calorie_high` 一天只发一次）是健壮的。当前代码已有 `session.query(Notification).filter_by(trigger_name=trigger_name...).first()` 检查，应当足够。
2. **Coach 困惑**: 如果推送内容与用户当前的话题毫不相干，强制注入推送上下文可能会让 Coach 回答生硬。因此，注入的提示词需要明确：**“如果用户当前的输入看起来是在回复这句话，请你顺着这个语境继续对话，否则正常回答。”**
