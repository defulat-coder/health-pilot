## 1. Setup & Configuration

- [x] 1.1 Update `.env.example` and `config.py` to support multi-modal LLM configuration (e.g., `qwen-vl-plus` or fallback strategy).
- [x] 1.2 Verify Agno AgentOS dependency supports multi-modal image inputs and test basic image parsing script.

## 2. Implement Visual Analysis Tools

- [x] 2.1 Create `tools/visual_analyzer.py` with function `analyze_menu_image` to parse food menus against user's remaining calories.
- [x] 2.2 Add function `generate_recipe_from_fridge` in `tools/visual_analyzer.py` to identify ingredients and generate a recipe.
- [x] 2.3 Integrate Agentic Memory queries into the visual analysis tools to ensure user preferences (e.g., allergies, aversions) are respected.

## 3. Implement Meal Prep Planner Tool

- [x] 3.1 Create `tools/meal_planner.py` with function `generate_multi_day_plan` to output daily meals based on calorie goals.
- [x] 3.2 Add functionality within `meal_planner.py` to aggregate ingredients and output a structured, categorized grocery shopping list.

## 4. Upgrade Coach Agent

- [x] 4.1 Update `agents/coach.py` instructions to recognize when a user uploads an image and properly set the context.
- [x] 4.2 Register the new tools (`visual_analyzer`, `meal_planner`) with the Coach Agent.
- [x] 4.3 Test the complete multi-modal routing: Upload an image of a menu and verify the Agent uses `analyze_menu_image` tool correctly.

## 5. End-to-End Testing & Refinement

- [x] 5.1 Test "Takeout Mine-sweeper" flow with a sample menu image and strict remaining calorie limit.
- [x] 5.2 Test "Fridge Blind Box" flow with a photo of 3-4 raw ingredients.
- [x] 5.3 Test "Meal Prep Shopping List" flow by requesting a 3-day vegetarian meal plan.
- [x] 5.4 Refine prompts in tools to ensure consistent Markdown/JSON outputs for easy reading by the user.