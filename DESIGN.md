---
name: Health Pilot
description: Lightweight personal health manager using a Doubao-style mobile chat experience.
colors:
  app-bg: "#F9F9FA"
  panel: "#FFFFFF"
  sidebar-bg: "#F8F8F8"
  text-primary: "#121214"
  text-secondary: "#0000007A"
  text-tertiary: "#0000004D"
  divider: "#00000014"
  chip-bg: "#0000000B"
  accent-blue: "#2963FA"
  soft-blue: "#E8F2FF"
  overlay: "#00000047"
typography:
  display:
    fontFamily: "SF Pro, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "30px"
    fontWeight: 600
    lineHeight: 1.15
    letterSpacing: "0"
  headline:
    fontFamily: "SF Pro, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "28px"
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: "0"
  title:
    fontFamily: "SF Pro, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "16px"
    fontWeight: 600
    lineHeight: 1.25
    letterSpacing: "0"
  body:
    fontFamily: "SF Pro, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.45
    letterSpacing: "0"
  label:
    fontFamily: "SF Pro, -apple-system, BlinkMacSystemFont, sans-serif"
    fontSize: "14px"
    fontWeight: 500
    lineHeight: 1.2
    letterSpacing: "0"
rounded:
  sm: "7px"
  md: "10px"
  lg: "12px"
  composer: "24px"
  pill: "999px"
spacing:
  xs: "6px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "24px"
components:
  button-primary:
    backgroundColor: "{colors.accent-blue}"
    textColor: "{colors.panel}"
    rounded: "{rounded.md}"
    height: "38px"
    padding: "0 16px"
  button-dark:
    backgroundColor: "{colors.text-primary}"
    textColor: "{colors.panel}"
    rounded: "{rounded.lg}"
    height: "36px"
    padding: "0 14px"
  chip-action:
    backgroundColor: "{colors.chip-bg}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.lg}"
    height: "42px"
    padding: "0 16px"
  composer:
    backgroundColor: "{colors.panel}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.composer}"
    height: "100px"
---

# Design System: Health Pilot

## 1. Overview

**Creative North Star: "Featherweight Health Console"**

Health Pilot should feel like a fast personal health manager living inside a familiar mobile AI chat shell. The interface uses Doubao-style conversation patterns, bottom composers, compact chips, side navigation, and modal rhythm as ergonomic reference points, but the identity is Health Pilot: efficient, intelligent, and lightweight.

The system is deliberately restrained. It uses near-white surfaces, black text, subtle gray chips, and the same crisp blue family seen in the Doubao mobile interaction language. Health-specific information should not introduce a separate green palette; it stays inside the blue-and-neutral system. The design explicitly rejects generic SaaS purple-blue gradients, gold accents, decorative metric cards, and heavy medical-admin dashboards.

**Key Characteristics:**
- Mobile-first, chat-first, and task-focused.
- Near-white layered surfaces with restrained shadows.
- Single sans typographic system using native iOS proportions.
- Blue appears only for active sends, confirmations, selected actions, and focus.
- Health content uses the same Doubao-style blue and neutral controls; no separate health green.

## 2. Colors

The palette is a restrained product palette: cool near-white surfaces, high-contrast dark text, low-opacity gray controls, one Doubao-style action blue, and a pale blue tint for selected or icon-backed UI.

### Primary
- **Action Blue**: Primary active state for send buttons, confirmation buttons, selected controls, and focused action affordances.
- **Soft Blue**: Pale support color for icon tiles, selected health rows, and gentle emphasis. It must read as the same family as Action Blue, not as a new semantic palette.

### Neutral
- **App Canvas**: The full-screen mobile background. It should stay quiet and slightly cooler than pure white.
- **Panel White**: Composer cards, modals, popovers, and menu surfaces.
- **Sidebar Mist**: Drawer background that separates navigation from conversation without introducing a new brand color.
- **Primary Ink**: Main text and icon color.
- **Secondary Ink**: Supporting labels, captions, and inactive metadata.
- **Tertiary Ink**: Placeholders and low-priority iconography.
- **Soft Divider**: Hairline borders, modal fields, and subtle container strokes.
- **Chip Wash**: Suggestion chips, toolbar controls, and user message bubbles.

### Named Rules

**The One Accent Rule.** Blue is the only general-purpose accent. If a screen has green, gold, purple, or any second saturated accent competing for attention, it is wrong.

**The No SaaS Gradient Rule.** Purple-blue gradients, gold accents, and gradient hero treatments are prohibited. Health Pilot is a product surface, not a SaaS landing page.

## 3. Typography

**Display Font:** SF Pro with system fallbacks
**Body Font:** SF Pro with system fallbacks
**Label/Mono Font:** SF Pro with system fallbacks

**Character:** The typography is native, familiar, and compact. It should disappear into the task: clear Chinese labels, short button text, predictable hierarchy, and no decorative display font.

### Hierarchy

- **Display** (600, 30px, 1.15): Creation screen titles and rare high-emphasis empty states.
- **Headline** (600, 28px, 1.2): Chat empty-state prompt and main conversational invitation.
- **Title** (600, 16px, 1.25): Header titles, menu labels, modal headings, and primary row text.
- **Body** (400, 16px, 1.45): Chat messages, assistant replies, and longer health explanations.
- **Label** (500, 14px, 1.2): Chips, toolbar pills, buttons, sidebar rows, and compact controls.

### Named Rules

**The Native Scale Rule.** Use fixed product UI sizes, not viewport-fluid typography. A mobile tool should stay predictable screen to screen.

**The No Display Labels Rule.** Buttons, menu rows, chips, health cards, and modal controls must use product UI typography, never expressive display styling.

## 4. Elevation

Health Pilot uses a hybrid of tonal layering and soft structural shadows. Most surfaces are flat at rest. Shadows are reserved for composer cards, floating menus, popovers, toast banners, and modals that must separate from conversation content.

### Shadow Vocabulary

- **Composer Shadow** (`0 8px 24px rgba(0,0,0,0.12)`): Bottom composer cards and large floating panels.
- **Small Floating Shadow** (`0 6px 16px rgba(0,0,0,0.14)`): Toasts and small popovers.
- **Overlay Dim** (`rgba(0,0,0,0.28)`): Modal and drawer backdrops.

### Named Rules

**The Shadow Earns Its Layer Rule.** Do not put wide soft shadows on ordinary chips, rows, or repeated cards. A shadow means the element is floating above the current task.

## 5. Components

### Buttons

- **Shape:** Medium rounded rectangles for modal actions (10px), compact rounded header pills (12px), and circular icon buttons when the control is purely iconic.
- **Primary:** Action Blue background with white text for decisive actions such as send and confirm.
- **Dark:** Primary account/login action uses dark ink with white text.
- **Hover / Focus:** On native iOS, focus should be expressed through state, pressed opacity, or subtle scale. Do not add decorative glow.
- **Secondary / Ghost:** White or transparent backgrounds with Primary Ink text and a hairline divider only when a boundary is needed.

### Chips

- **Style:** Chip Wash background, Primary Ink text, 12px radius for suggestion chips, full pill for toolbar controls.
- **State:** Chips are action controls, not decoration. Tapping a suggestion sends immediately; it should not prefill and wait unless the interaction explicitly says so.

### Cards / Containers

- **Corner Style:** Composer cards use 24px radius. Menus, modals, toasts, and popovers use 10-12px. Avoid larger radii on ordinary content.
- **Background:** Panel White for elevated surfaces; App Canvas for the page.
- **Shadow Strategy:** Use Composer Shadow or Small Floating Shadow only for floating UI.
- **Border:** Hairline dividers only when they clarify a field, modal edge, or selected row.
- **Internal Padding:** 12-16px for mobile controls, 22-24px for modal interiors.

### Inputs / Fields

- **Style:** Text input areas are white, compact, and native. The chat composer has no heavy border; modal text fields can use a thin gray rectangular border.
- **Focus:** Focus should preserve the layout and avoid color noise. Use cursor/focus behavior and primary action availability as the main signal.
- **Error / Disabled:** Disabled actions should remain visibly unavailable through opacity or muted text, not through red unless there is a true error.

### Navigation

- **Style:** The sidebar is a 280px light-gray drawer with compact rows, SF Symbols, and a white selected row.
- **Typography:** 15px medium row labels, 12px secondary section labels, and 17px semibold product mark.
- **Mobile Treatment:** Drawer overlay dims the current conversation and closes on backdrop tap. Navigation should never feel like a separate dashboard shell.

### Composer

The composer is the signature component. It is a bottom white rounded surface with a large text input area, compact toolbar pills, attachment/model/more controls, and a right-side mic/send button. Empty state uses a neutral mic; non-empty state switches to Action Blue send.

## 6. Do's and Don'ts

### Do:

- **Do** keep the product mobile-first and chat-first; a health task should feel as quick as sending a message.
- **Do** use App Canvas, Panel White, Chip Wash, and Primary Ink as the default visual vocabulary.
- **Do** reserve Action Blue for active send, confirm, selection, and focus states.
- **Do** use Soft Blue when health rows or icon tiles need gentle emphasis.
- **Do** keep transitions short, state-driven, and native-feeling.
- **Do** keep suggestions, follow-up chips, and health cards actionable.

### Don't:

- **Don't** use generic SaaS purple-blue gradients, gold accents, oversized metric cards, or decorative gradient cards.
- **Don't** introduce health green or other semantic color families for core product UI; keep the color system close to the original Doubao mobile blue-and-neutral palette.
- **Don't** make the app feel like a hospital admin system, insurance portal, or medical record backend.
- **Don't** create high-pressure fitness streak UI that shames users for missed records.
- **Don't** copy Doubao proprietary brand assets; reuse interaction patterns only.
- **Don't** pair a border with a wide soft shadow on ordinary cards or controls.
- **Don't** use 32px+ radii on regular cards, menus, inputs, or list items.
- **Don't** add gradient text, side-stripe borders, glassmorphism, or decorative stripe backgrounds.
