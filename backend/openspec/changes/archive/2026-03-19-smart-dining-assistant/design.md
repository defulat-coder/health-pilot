## Context

Health Pilot currently tracks diet, weight, and exercise based on text inputs and sends periodic reminders. However, real-world diet management is highly visual and scenario-driven (e.g., looking at a menu, opening a fridge). To become a proactive "Smart Dining Assistant", the system must process images (multi-modal) and generate closed-loop actionable plans (like a shopping list).

## Goals / Non-Goals

**Goals:**
- Enable the Coach Agent to accept and analyze image inputs (menus, receipts, fridge contents).
- Cross-reference visual data with the user's daily nutritional quotas and long-term preferences (Agentic Memory).
- Generate actionable outputs: red/black lists for menus, recipes for fridge ingredients, and structured shopping lists for meal plans.

**Non-Goals:**
- Building a standalone mobile app for scanning. (We still rely on the Agent OS API).
- Exact 100% accurate calorie counting from images (estimation is acceptable).
- Integration with external delivery or grocery shopping APIs (we only generate the list).

## Decisions

1. **Multi-Modal LLM Integration**
   - *Decision*: Configure the Agno Agent to use a vision-capable LLM (e.g., `qwen-vl-plus` or `gpt-4o`) via the OpenAILike adapter.
   - *Rationale*: Agno supports multi-modal inputs natively if the underlying model supports it. We will pass the image URL or base64 data to the agent along with the user's prompt.

2. **New Tool: `visual_analyzer.py`**
   - *Decision*: Create a new tool that handles specific visual prompts (e.g., "Analyze this menu against my 500 kcal remaining budget").
   - *Rationale*: While the main Agent can see images, delegating the structured analysis (fetching user quotas + analyzing food + formatting the response) to a specific tool ensures consistent output and separates concerns.

3. **New Tool: `meal_planner.py`**
   - *Decision*: Create a tool dedicated to multi-day meal planning and grocery list generation.
   - *Rationale*: Planning multiple days requires complex prompt engineering and structured output (JSON or Markdown lists). A dedicated tool handles this better than raw agent reasoning.

4. **Agentic Memory Utilization**
   - *Decision*: The `visual_analyzer` and `meal_planner` tools will heavily query the user's Agentic Memory (allergies, preferences, historical habits) before generating recommendations.
   - *Rationale*: Personalization is key. A recipe generator must know if the user is lactose intolerant.

## Risks / Trade-offs

- [Risk] **High latency for image processing** → Mitigation: Use streaming responses (if supported) and keep prompts concise. Inform the user "I'm looking at your image..."
- [Risk] **Inaccurate food recognition** → Mitigation: Instruct the LLM to state its assumptions (e.g., "I see what looks like chicken breast...").
- [Risk] **Model compatibility** → Mitigation: Document the exact models that support this feature in `.env.example`.

## Migration Plan

- Update `.env` to recommend a vision-capable model.
- No database migration required as we are leveraging existing user profiles and Agentic Memory.
- Deploy the new tools and update `agents/coach.py` instructions to make the agent aware of its new visual capabilities.
