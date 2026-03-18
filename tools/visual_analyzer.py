from typing import Optional, Dict, Any
from agno.tools import Toolkit
from agno.agent import Agent
from agno.run import RunContext
from agno.models.openai import OpenAILike
from agno.media import Image

from config import settings
from tools.data_analyzer import DataAnalyzer
from models.database import SessionLocal, UserProfile


class VisualAnalyzer(Toolkit):
    def __init__(self):
        super().__init__(name="visual_analyzer")
        self.register(self.analyze_menu_image)
        self.register(self.generate_recipe_from_fridge)
        
        # Initialize the vision model
        self.vision_model = OpenAILike(
            id=settings.vision_llm_model,
            api_key=settings.vision_llm_api_key or settings.llm_api_key,
            base_url=settings.vision_llm_base_url or settings.llm_base_url,
        )

    def analyze_menu_image(self, image_url_or_path: str, context: Optional[str] = None, run_context: Optional[RunContext] = None) -> str:
        """
        分析外卖菜单或小票图片，结合用户当天的剩余热量，给出推荐的点单建议（红黑榜）。
        
        Args:
            image_url_or_path: 菜单或小票的图片URL或本地路径。
            context: 用户的附加文字说明，例如“这家咋样”或“想吃清淡点”。
            run_context: Agno注入的上下文，包含当前用户ID。
            
        Returns:
            str: 包含推荐菜品和避坑建议的分析结果。
        """
        user_id = run_context.user_id if run_context else "default_user"
        
        # 1. 获取用户今日剩余热量
        data_analyzer = DataAnalyzer()
        try:
            today_summary = data_analyzer.get_today_summary(run_context=run_context)
            # Simple parsing, assuming summary has these keywords. In a real app, you might want structured data.
            remaining_calories = "未知"
            if "剩余额度" in today_summary:
                parts = today_summary.split("剩余额度")
                if len(parts) > 1:
                    remaining_calories = parts[1].split("\n")[0].strip()
        except Exception as e:
            today_summary = "无法获取今日数据。"
            remaining_calories = "未知"

        # 2. 调用多模态Agent进行分析
        vision_agent = Agent(
            model=self.vision_model,
            instructions=[
                "你是一个专业的减脂营养师。",
                "你的任务是分析用户提供的菜单或小票图片，并结合用户的剩余热量额度给出点单建议。",
                "1. 提取图片中的菜品信息，预估其热量和营养成分。",
                "2. 将预估热量与用户的剩余额度进行对比。",
                "3. 给出1-3个推荐菜品（绿榜/推荐），确保它们符合剩余额度并相对健康。",
                "4. 给出1-2个不推荐菜品（红榜/避坑），说明原因（如高糖、高油、热量超标）。",
                "5. 如果剩余热量极低，必须强烈警告，并推荐最低热量的选项（如纯蔬菜沙拉、清汤）或建议少吃一半。",
                "6. 语气要像私人教练一样，专业且带点人情味。"
            ],
            markdown=True
        )

        prompt = f"这是菜单图片。用户的附加说明是：{context or '无'}。\n用户的今日饮食总结如下：\n{today_summary}\n\n请根据以上信息，给出你的点单建议。"
        
        try:
            response = vision_agent.run(prompt, images=[Image(url=image_url_or_path) if image_url_or_path.startswith("http") else Image(filepath=image_url_or_path)])
            return response.content
        except Exception as e:
            return f"抱歉，图片分析失败，请检查图片链接或格式是否正确。错误信息：{str(e)}"

    def generate_recipe_from_fridge(self, image_url_or_path: str, context: Optional[str] = None, run_context: Optional[RunContext] = None) -> str:
        """
        识别冰箱内部或食材图片，结合用户的偏好（忌口、过敏），生成一份健康的减脂食谱。
        
        Args:
            image_url_or_path: 冰箱或食材的图片URL或本地路径。
            context: 用户的附加文字说明，例如“晚上只剩这些了”。
            run_context: Agno注入的上下文，包含当前用户ID。
            
        Returns:
            str: 包含识别出的食材和生成的健康食谱的做法。
        """
        user_id = run_context.user_id if run_context else "default_user"
        
        # 获取用户偏好
        db = SessionLocal()
        try:
            profile = db.query(UserProfile).filter(UserProfile.user_id == user_id).first()
            # 简化处理，实际应用中可以从数据库或记忆中提取 "dietary_preferences" 或 "allergies"
            preferences = "无特殊忌口"
        except Exception:
            preferences = "无特殊忌口"
        finally:
            db.close()

        # 调用多模态Agent进行分析
        vision_agent = Agent(
            model=self.vision_model,
            instructions=[
                "你是一个创意十足的健康主厨兼减脂教练。",
                "你的任务是根据用户提供的食材照片，生成一份健康、符合减脂需求的菜谱。",
                "1. 首先识别出图片中可见的主要食材。",
                "2. 结合用户的饮食偏好和忌口信息，构思一道或两道菜。",
                "3. 确保菜谱尽量低油低糖，蛋白质和蔬菜搭配合理。",
                "4. 给出详细但易懂的烹饪步骤。",
                "5. 如果图片中只有极度不健康或单一的食材（比如只有泡面和火腿肠），你需要温柔地指出缺乏蛋白质或蔬菜，并建议如何稍微健康地烹饪（例如只用一半调料包，或者建议点个健康配菜）。",
                "6. 语气要鼓励、温暖，像是在救场的朋友。"
            ],
            markdown=True
        )

        prompt = f"这是我现有的食材照片。附加说明：{context or '无'}。\n请注意我的饮食偏好/忌口：{preferences}。\n\n请帮我看看能做点什么健康餐？"
        
        try:
            response = vision_agent.run(prompt, images=[Image(url=image_url_or_path) if image_url_or_path.startswith("http") else Image(filepath=image_url_or_path)])
            return response.content
        except Exception as e:
            return f"抱歉，食材识别失败，请检查图片链接或格式是否正确。错误信息：{str(e)}"
