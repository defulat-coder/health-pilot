## Why

To evolve Health Pilot from a passive "recorder and broadcaster" into an irreplaceable, intelligent AI coach, we need to leverage multi-modal capabilities and scene-based intelligence. Users often face decision fatigue in real-world eating scenarios (e.g., ordering takeout, cooking with leftovers) and need actionable, personalized guidance. This "Smart Dining Assistant" bridges the gap between dietary goals and daily execution by providing proactive, visual, and closed-loop interventions.

## What Changes

- **Visual Menu/Receipt Analysis ("Takeout Mine-sweeper")**: Allow users to upload images of menus or receipts. The system will analyze the food items, estimate calories/nutrition, check against the user's daily remaining quota, and provide a "red/black list" of recommendations.
- **Fridge Blind Box Recipe Generator**: Allow users to upload photos of their fridge or available ingredients. The system will identify ingredients, cross-reference with user preferences/allergies from Agentic Memory, and generate a healthy recipe.
- **One-Click Meal Prep Shopping List**: Enable users to request meal plans for multiple days. The system will plan the meals based on caloric goals, aggregate the required ingredients, and generate a structured grocery shopping list.
- **Multi-modal Agent Upgrade**: Update the Coach Agent to seamlessly process image inputs and route them to the appropriate visual analysis tools.

## Capabilities

### New Capabilities
- `visual-menu-analysis`: Analyzes menu images to recommend meals based on daily quotas.
- `fridge-recipe-generator`: Identifies ingredients from photos and generates personalized recipes.
- `meal-prep-planner`: Plans multi-day meals and generates structured grocery lists.

### Modified Capabilities
- `coach-agent`: Needs to support multi-modal inputs (images) and route to new visual and planning tools.

## Impact

- **Agent/Coach**: `agents/coach.py` will require updates to handle image inputs and new tool integrations.
- **Tools**: New tools will be added (e.g., `visual_analyzer.py`, `meal_planner.py`).
- **Dependencies**: May require switching the default LLM to a vision-capable model (e.g., Qwen-VL or GPT-4o) if the current model does not support it, or adding specific vision API integrations.
- **Database**: No major database schema changes expected, though Agentic Memory will be heavily utilized for user preferences.