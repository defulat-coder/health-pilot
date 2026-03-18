import json
from typing import Optional, Dict, Any
from agno.tools import Toolkit
from agno.agent import Agent
from agno.run import RunContext
from agno.models.openai import OpenAILike

from config import settings
from models.database import SessionLocal, UserProfile


class MealPlanner(Toolkit):
    def __init__(self):
        super().__init__(name="meal_planner")
        self.register(self.generate_multi_day_plan)
        
        self.llm_model = OpenAILike(
            id=settings.llm_model,
            api_key=settings.llm_api_key,
            base_url=settings.llm_base_url,
        )

    def generate_multi_day_plan(self, days: int, meals_per_day: str = "三餐", specific_requests: str = "", run_context: Optional[RunContext] = None) -> str:
        """
        为用户生成多日的备餐计划（食谱）并汇总生成结构化的生鲜购物清单。
        
        Args:
            days: 计划天数，例如 3 或 7。
            meals_per_day: 每天包含的餐食，例如 "午餐" 或 "早午晚三餐"。
            specific_requests: 用户的特殊要求，例如 "素食"、"不吃香菜"、"高蛋白"。
            run_context: Agno注入的上下文。
            
        Returns:
            str: 包含每日食谱和汇总购物清单的Markdown文本。
        """
        user_id = run_context.user_id if run_context else "default_user"
        
        # 获取用户基础数据（目标热量、偏好等）
        db = SessionLocal()
        try:
            profile = db.query(UserProfile).filter(UserProfile.user_id == user_id).first()
            if profile:
                target_calories = f"{profile.tdee_kcal - (profile.target_rate_kg_per_week or 0.5) * 1100:.0f}" if profile.tdee_kcal else "未知 (请按照常规减脂1500kcal计算)"
                # Assuming dietary_preferences might be added later, currently we just use what user provided in specific_requests
                dietary_preferences = "无"
            else:
                target_calories = "1500 (默认减脂)"
                dietary_preferences = "无"
        except Exception:
            target_calories = "1500 (默认减脂)"
            dietary_preferences = "无"
        finally:
            db.close()

        planner_agent = Agent(
            model=self.llm_model,
            instructions=[
                "你是一位专业的运动营养师和高级主厨，擅长做减脂备餐规划。",
                "你的任务是根据用户的需求，生成一份多日的食谱，并最终汇总出一份可以直接去超市采购的【结构化购物清单】。",
                "要求：",
                "1. 食谱要符合减脂需求，满足目标热量，蛋白质充足，蔬菜丰富。",
                "2. 尽量考虑备餐的便捷性（比如有些食材可以一次性处理好，分几天吃）。",
                "3. 明确列出每天/每顿吃什么。",
                "4. 在输出的最后，必须提供一个【生鲜采购清单 (按区域整理)】，汇总所有所需的食材和预估分量。",
                "5. 购物清单的分类建议：🥩 肉类/海鲜、🥬 蔬菜/水果、🥚 蛋奶/豆制品、🍚 主食/碳水、🧂 调料/其他。",
                "6. 严格遵守用户的特殊要求和饮食偏好（如果有忌口，绝对不能出现在清单里）。"
            ],
            markdown=True
        )

        prompt = f"""
        请帮我制定一个备餐计划和购物清单。
        
        【基本信息】
        - 计划天数：{days} 天
        - 包含餐食：{meals_per_day}
        - 每日目标热量：约 {target_calories} kcal
        - 饮食偏好/历史忌口：{dietary_preferences}
        - 特殊要求：{specific_requests if specific_requests else "无"}
        
        请按照要求输出详细的食谱规划，并在末尾附上汇总的购物清单。
        """
        
        try:
            response = planner_agent.run(prompt)
            return response.content
        except Exception as e:
            return f"生成备餐计划失败，请稍后再试。错误信息：{str(e)}"
