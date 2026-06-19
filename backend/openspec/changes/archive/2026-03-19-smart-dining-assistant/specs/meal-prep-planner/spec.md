## ADDED Requirements

### Requirement: Generate multi-day meal plans and shopping lists
The system SHALL be able to generate meal plans for a specified number of days (e.g., 3 days) based on the user's daily calorie targets, macronutrient goals, and preferences. It MUST aggregate the ingredients required for the plan into a structured grocery shopping list.

#### Scenario: User requests a 3-day meal prep plan
- **WHEN** user asks "Plan my lunches for the next 3 days and give me a shopping list"
- **THEN** system generates a 3-day lunch menu meeting the user's daily calorie goals
- **THEN** system calculates the total quantities of ingredients needed
- **THEN** system outputs a structured shopping list categorized by sections (e.g., Produce, Meat, Pantry).

#### Scenario: User requests a plan with specific constraints
- **WHEN** user asks "Plan my dinners for the week, I am vegetarian"
- **THEN** system checks the user profile/memory to confirm vegetarian status
- **THEN** system generates a 7-day dinner menu without meat, ensuring sufficient plant-based protein
- **THEN** system outputs the corresponding categorized shopping list.
