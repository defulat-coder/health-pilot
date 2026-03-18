# Health Pilot - Agent 设计与实现细节

本文档详细记录了 Health Pilot 系统中各个 Agent 的职责、核心机制以及提示词（Prompt）设计。

## 1. Coach Agent (主对话教练)

**文件路径**：`agents/coach.py`

### 职责
Coach Agent 是系统的核心，负责处理用户的所有输入（文字、图片），识别用户意图，调用相应的工具（Tools）来记录数据或查询信息，并给出专业的减脂建议。

### 核心机制
- **多模态支持**：借助底层的 LLM（如 qwen3.5-plus），直接处理图片输入，无需额外的 OCR 模块。
- **Agentic Memory**：启用长期记忆（`enable_agentic_memory=True`），能够跨会话记住用户的偏好。
- **动态 Prompt 注入**：这是保证回复精准度的关键。每次运行前，`get_user_instructions` 函数会从数据库拉取用户的静态档案（身高、体重、TDEE）和动态数据（今日已摄入热量、营养素进度），拼接到基础指令中。
- **系统上下文闭环**：在动态 Prompt 中，还会查询最近 2 小时内发送且未读的“主动推送”记录，让 Coach 能够接续推送话题进行对话。

### 提示词设计 (Prompt)

**基础指令 (Base Instructions)**:
> 你是一位专业、温暖的1v1减脂健康教练。你的职责是帮助用户科学减脂。
> 
> ## 核心行为
> 1. **意图识别**：自动识别用户消息意图...
> 2. **图片理解**：用户发送图片时识别食物、提取数字...
> 3. **自动记录**：识别到记录意图后直接记录，无需确认。
> 4. **热量估算**：基于营养学知识估算食物热量和三大营养素...
> 
> ## 新用户引导 / 回复风格 / 安全边界 / 追问逻辑
> （详细设定回复需简洁温暖，不提供医疗建议，信息不足时主动追问）

**动态注入部分 (Dynamic Context)**:
> ## 当前用户档案
> - 身高：175cm | 体重：70kg | 年龄：28岁 | 性别：男
> - 活动量：中等 | TDEE：2400kcal
> - 目标体重：65kg | 目标速率：0.5kg/周
> 
> ## 今日实时数据
> - 已摄入：1200kcal / 2400kcal（剩余 1200kcal）
> - 蛋白质：60g / 112g（54%）
> - 运动消耗：300kcal
> 
> 回复时参考以上数据，给出针对性建议。

**主动推送上下文注入 (Push Context)**:
> ## 【系统上下文】主动关怀记录
> 系统在刚才（19:00）向用户发送了主动关怀消息：『今天热量还剩不多啦，晚上打算吃点啥？』。
> 如果用户当前的输入看起来是在回复这句话，请你顺着这个语境继续对话。否则正常回答。

---

## 2. Push Agent (推送内容生成器)

**文件路径**：`scheduler/push_scheduler.py`

### 职责
Push Agent 是一个轻量级的、非交互式的 Agent。它被调度器（APScheduler）或事件触发器调用，负责根据传入的简单上下文，生成一句带有温度和人情味的推送文案。

### 核心机制
- **单向生成**：只根据提示词输出文本，不处理用户的直接回复（用户的回复由 Coach Agent 接管）。
- **场景化调用**：在定时任务（如早餐提醒）或条件触发（如热量超标预警）时，构建特定场景的 Prompt 传给 Push Agent。

### 提示词设计 (Prompt)

**基础指令 (Base Instructions)**:
> 你是减脂教练的推送内容生成器。根据用户数据生成简短、温暖、个性化的推送消息。消息要简洁（1-2句话），包含具体数据和建议。使用用户的饮食偏好来推荐食物。

**场景化触发词 (Scenario Prompts 示例)**:

- **热量超标预警 (`calorie_high`)**:
  > 用户今天已摄入2200kcal，目标2400kcal，只剩200kcal。生成友善提醒。
  
- **蛋白质不足 (`protein_low`)**:
  > 用户蛋白质还差50g，目标112g。推荐高蛋白食物。

- **连续达标鼓励 (`streak`)**:
  > 用户连续3天热量达标！生成鼓励推送。

- **沉默唤醒 (`silent_wakeup`)**:
  > 用户已经超过一天没有记录饮食或运动了。生成一条温暖的沉默唤醒推送，比如问问是不是太忙了，提醒好好吃饭。

---

## 3. 工具 (Tools) 配合

Agents 的能力边界由 Tools 扩展。所有工具函数都必须包含清晰的 Docstring，因为 Agno AgentOS 会解析这些 Docstring 生成 OpenAI 格式的 Tool Definition。

例如 `record_meal` 工具：
```python
def record_meal(
    run_context: RunContext,
    description: str,
    calories_kcal: float,
    protein_g: float,
    carbs_g: float,
    fat_g: float,
    meal_type: str = "",
) -> str:
    """记录用户饮食。当用户上报吃了什么、发送食物照片或外卖订单截图时调用。

    Args:
        description (str): 食物描述，如 "黄焖鸡米饭 + 一个鸡蛋"
        calories_kcal (float): 估算总热量，单位千卡
        ...
    """
```
**关键配合**：在执行完数据插入数据库的操作后，工具会启动后台线程 `threading.Thread(target=check_conditional_triggers, args=(user_id,)).start()` 异步唤醒 Push Agent 进行条件检查，实现低延迟的实时预警。
