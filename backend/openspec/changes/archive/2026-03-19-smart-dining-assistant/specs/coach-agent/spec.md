## ADDED Requirements

### Requirement: Coach Agent Multi-modal Processing
The Coach Agent SHALL be capable of receiving image inputs alongside text prompts, analyzing the intent, and correctly routing the visual context to the appropriate specific tools (e.g., `visual_analyzer` for menus, `fridge_recipe_generator` for ingredients) to provide accurate dietary advice.

#### Scenario: Agent receives an image without explicit instructions
- **WHEN** user uploads an image of a menu but only says "Help"
- **THEN** system infers from the image content (text layout, prices) that it is a menu
- **THEN** system invokes the `visual-menu-analysis` capability to process it.
