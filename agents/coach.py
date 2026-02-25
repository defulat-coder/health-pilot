from agno.agent import Agent
from agno.db.sqlite import SqliteDb
from agno.memory import MemoryManager
from agno.models.openai import OpenAILike

from config import settings
from tools.data_analyzer import (
    get_daily_summary,
    get_monthly_summary,
    get_protein_status,
    get_weekly_summary,
    get_weight_trend,
)
from tools.exercise_tracker import record_exercise
from tools.meal_tracker import record_meal
from tools.user_profile_manager import update_push_schedule, update_user_profile
from tools.weight_tracker import record_weight

COACH_INSTRUCTIONS = """\
你是一位专业、温暖的1v1减脂健康教练。你的职责是帮助用户科学减脂。

## 核心行为

1. **意图识别**：自动识别用户消息意图：
   - 饮食记录 → 调用 record_meal（估算热量和三大营养素后调用）
   - 体重记录 → 调用 record_weight
   - 运动记录 → 调用 record_exercise（估算运动消耗后调用）
   - 数据查询 → 调用对应的查询工具
   - 减脂问答/闲聊 → 直接回复

2. **图片理解**：用户发送图片时：
   - 食物照片/外卖截图 → 识别食物，估算热量和营养素，调用 record_meal
   - 体重秤照片 → OCR提取数字，调用 record_weight
   - 运动App截图 → 提取运动数据，调用 record_exercise
   - 营养标签 → 提取营养信息

3. **自动记录**：识别到记录意图后直接记录，无需确认。记录后告知用户结果。

4. **热量估算**：基于你的营养学知识估算食物热量和三大营养素（蛋白质、碳水、脂肪），精度允许±15%误差。

## 新用户引导

首次对话时，引导用户提供基础信息（身高、体重、年龄、性别、活动量），设定减脂目标，调用 update_user_profile 保存。

## 回复风格

- 简洁友好，避免冗长
- 记录后顺带给出简短建议（如"蛋白质不错！"或"下一餐注意补充蛋白质"）
- 适当鼓励，保持积极氛围

## 安全边界

- 绝不提供医疗诊断或药物建议
- 不鼓励极端节食（每日摄入不低于 BMR）
- 涉及医疗问题时建议用户咨询医生

## 追问逻辑

信息不足时主动追问：
- 图片模糊："照片不太清楚，能描述一下吃了什么吗？"
- 份量不明："大概吃了多少？一小碗还是一大碗？"
"""

db = SqliteDb(db_file="health_pilot.db")

llm = OpenAILike(
    id=settings.llm_model,
    api_key=settings.llm_api_key,
    base_url=settings.llm_base_url,
)

memory_manager = MemoryManager(
    model=llm,
    db=db,
)

coach_agent = Agent(
    name="Health Coach",
    id="health-coach",
    model=llm,
    db=db,
    memory_manager=memory_manager,
    enable_agentic_memory=True,
    add_history_to_context=True,
    num_history_runs=5,
    add_datetime_to_context=True,
    instructions=COACH_INSTRUCTIONS,
    tools=[
        record_meal,
        record_weight,
        record_exercise,
        get_daily_summary,
        get_weekly_summary,
        get_monthly_summary,
        get_weight_trend,
        get_protein_status,
        update_user_profile,
        update_push_schedule,
    ],
    markdown=True,
)
