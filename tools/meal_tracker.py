import threading
from datetime import datetime

from agno.run import RunContext

from models.database import Meal, SessionLocal
from scheduler.push_scheduler import check_conditional_triggers


def infer_meal_type(hour: int) -> str:
    if hour < 10:
        return "breakfast"
    elif hour < 14:
        return "lunch"
    elif hour < 17:
        return "snack"
    else:
        return "dinner"


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
        protein_g (float): 估算蛋白质，单位克
        carbs_g (float): 估算碳水化合物，单位克
        fat_g (float): 估算脂肪，单位克
        meal_type (str): breakfast/lunch/dinner/snack 之一，留空则根据当前时间自动推断
    """
    user_id = run_context.user_id or "default"
    now = datetime.now()
    if not meal_type:
        meal_type = infer_meal_type(now.hour)

    db = SessionLocal()
    try:
        meal = Meal(
            user_id=user_id,
            meal_type=meal_type,
            description=description,
            calories_kcal=calories_kcal,
            protein_g=protein_g,
            carbs_g=carbs_g,
            fat_g=fat_g,
            recorded_at=now,
        )
        db.add(meal)
        db.commit()

        # 异步触发条件推送检查
        threading.Thread(target=check_conditional_triggers, args=(user_id,)).start()

        return (
            f"已记录{meal_type}：{description}\n"
            f"热量 {calories_kcal:.0f}kcal | 蛋白质 {protein_g:.0f}g | 碳水 {carbs_g:.0f}g | 脂肪 {fat_g:.0f}g"
        )
    finally:
        db.close()
