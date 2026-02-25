from datetime import datetime

from agno.run import RunContext

from models.database import Meal, SessionLocal


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
    """Record a meal for the user. Call this when the user reports what they ate, sends a food photo, or a delivery order screenshot.

    Args:
        description (str): Food description, e.g. "黄焖鸡米饭 + 一个鸡蛋"
        calories_kcal (float): Estimated total calories in kcal
        protein_g (float): Estimated protein in grams
        carbs_g (float): Estimated carbohydrates in grams
        fat_g (float): Estimated fat in grams
        meal_type (str): One of breakfast/lunch/dinner/snack. Leave empty to auto-infer from current time.
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

        return (
            f"已记录{meal_type}：{description}\n"
            f"热量 {calories_kcal:.0f}kcal | 蛋白质 {protein_g:.0f}g | 碳水 {carbs_g:.0f}g | 脂肪 {fat_g:.0f}g"
        )
    finally:
        db.close()
