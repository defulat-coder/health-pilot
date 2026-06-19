## ADDED Requirements

### Requirement: Analyze takeout menus and receipts
The system SHALL accept image inputs of menus or food receipts, extract the food items, estimate their nutritional values, and compare them against the user's daily remaining calorie and macronutrient quotas to provide actionable recommendations.

#### Scenario: User uploads a menu with sufficient remaining calories
- **WHEN** user uploads an image of a restaurant menu and asks what to eat
- **THEN** system extracts the menu items
- **THEN** system checks the user's remaining daily calories
- **THEN** system recommends 1-3 items that fit within the remaining budget and flags items that exceed the budget or are known to be unhealthy.

#### Scenario: User uploads a menu with insufficient remaining calories
- **WHEN** user uploads an image of a menu but has very few calories left (e.g., < 300 kcal)
- **THEN** system warns the user about the low budget
- **THEN** system recommends the lowest calorie options (e.g., salads without dressing, clear soups) or suggests portion control (e.g., "only eat half").
