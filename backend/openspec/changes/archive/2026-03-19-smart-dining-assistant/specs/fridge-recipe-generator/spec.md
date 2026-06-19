## ADDED Requirements

### Requirement: Generate recipes from fridge photos
The system SHALL accept image inputs of a fridge interior or a collection of ingredients, identify the available food items, and generate a healthy recipe that aligns with the user's dietary preferences, allergies, and current nutritional goals.

#### Scenario: User uploads a photo of common ingredients
- **WHEN** user uploads a photo showing eggs, tomatoes, and chicken breast
- **THEN** system identifies the ingredients
- **THEN** system checks Agentic Memory for user preferences (e.g., "no dairy", "low carb")
- **THEN** system provides a step-by-step recipe utilizing the identified ingredients that fits the user's dietary constraints.

#### Scenario: User uploads a photo with limited or unhealthy ingredients
- **WHEN** user uploads a photo containing only instant noodles and hot dogs
- **THEN** system identifies the ingredients
- **THEN** system gently points out the lack of protein/vegetables
- **THEN** system suggests a way to make the meal slightly healthier (e.g., "Boil the noodles but only use half the seasoning packet") or recommends ordering a healthy side dish.
