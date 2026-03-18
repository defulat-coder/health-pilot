# Tasks: 主动关怀与对话发起机制

## 阶段 1: 记忆闭环打通
- [x] 1. 在 `agents/coach.py` 中导入 `Notification` 模型和 `datetime`、`timedelta`。
- [x] 2. 修改 `get_user_instructions(user_id)` 函数，在组装 `instructions` 的末尾添加逻辑：查询该用户过去 2 小时内的最新一条未读 (`delivered == False`) 通知。
- [x] 3. 如果找到最新通知，将其内容作为【系统上下文】追加到 `instructions` 字符串中，指导 Coach 顺着该推送语境回复。

## 阶段 2: 实时条件触发
- [x] 4. 在 `tools/meal_tracker.py` 中，导入 `scheduler.push_scheduler` 中的 `check_conditional_triggers` 函数（或者在需要时局部导入避免循环依赖）。
- [x] 5. 修改 `record_meal` 函数，在成功保存并计算营养素之后（通常是在 `session.commit()` 后或组装完返回字符串前），异步/后台调用 `check_conditional_triggers(user_id, session)`。由于当前是基于工具的同步函数，可以通过线程或者仅仅直接调用（如果耗时短且允许稍微延迟工具响应）来实现。
- [x] 6. 在 `tools/weight_tracker.py` 的 `record_weight` 函数中重复第 5 步逻辑，以便触发 `plateau` 等体重相关的条件推送。
- [x] 7. （可选/根据需要）在 `tools/exercise_tracker.py` 中添加类似的触发检查。

## 阶段 3: 沉默用户唤醒
- [x] 8. 在 `scheduler/push_scheduler.py` 中编写 `check_silent_users` 函数。
- [x] 9. 在 `check_silent_users` 内部逻辑：
  - 查询 `UserProfile` 中的所有用户。
  - 对于每个用户，查询过去 24/48 小时内的 `Meal` 和 `Exercise` 记录。
  - 若无任何记录，且当日尚未触发过 `silent_wakeup` 通知，则使用 `push_agent` 生成一条关怀推送。
- [x] 10. 将 `check_silent_users` 任务添加到 `init_scheduler` 的定时任务列表中，设定每日固定时间（例如 20:00）运行。

## 阶段 4: API 调整与测试
- [x] 11. 检查并确认 `main.py` 中的 `/api/v1/notifications` 接口和标记已读接口是否稳定，确保前端可以通过轮询获取到由上述阶段产生的 `trigger_type='conditional'` 的推送，并显示在聊天流中。
- [x] 12. 进行全流程测试：手动记录高热量饮食，查看是否立即生成超标预警；回复“我只是吃一点点”，查看 Coach 是否能够理解你在回复刚刚的预警。
