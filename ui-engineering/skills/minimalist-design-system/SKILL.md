---
name: minimalist-design-system
description: >
  Enforces a premium, minimalistic, professional user interface aesthetic and WCAG 2.1 AA accessibility standards.
  Use this skill whenever you are designing, styling, or building web interfaces (HTML, CSS, React, Next.js).
---

# Premium Minimalist & Accessible Design System Guidelines

This skill defines a professional, high-signal-to-noise UI design system coupled with strict WCAG 2.1 AA accessibility guidelines.

## When to Use This Skill

- Trigger this skill whenever you are building UI components, writing CSS, defining styling tokens, or refactoring frontend interfaces.
- Use it to ensure that any generated page is visually premium, clean, and fully accessible.

## 1. Color Palette (Sober, Low-Saturation)
Avoid raw primaries, saturated bright colors, or intense gradients. Default to a premium light/off-white theme with high contrast.
*   **Backgrounds**: Off-white (`#F8F9FA` or HSL `210, 20%, 98%`) and pure white (`#FFFFFF`).
*   **Borders & Dividers**: Subtle, thin borders in light grey (`#E9ECEF` or HSL `210, 16%, 93%`).
*   **Primary Text**: Slate Grey/Near Black (`#212529` or HSL `210, 11%, 15%`) for maximum readability.
*   **Secondary Text**: Muted Grey (`#6C757D` or HSL `208, 7%, 46%`).
*   **Brand/Accent**: Low-saturation navy or steel blue (`#495057` or HSL `210, 10%, 23%`). Avoid bright colors unless signaling errors or success states.

## 2. WCAG 2.1 AA Accessibility Guidelines

### Semantic HTML Structure
- **Page Landmark Elements**: Structure pages using appropriate HTML5 semantic elements (`<header>`, `<nav>`, `<main>`, `<section>`, `<article>`, `<footer>`).
- **Heading Hierarchy**: Use exactly one `<h1>` per page. Ensure subsequent headings (`<h2>` through `<h6>`) follow a strict logical hierarchy without skipping levels.
- **Interactive Elements**: Use `<button>` for clickable actions that don't change the URL, and `<a>` for navigational links. Never use `<div>` or `<span>` for click handlers without explicit ARIA mapping and keyboard listener implementations.

### ARIA Attributes & Roles
- **Form Labels**: Ensure every `<input>`, `<textarea>`, and `<select>` has a corresponding `<label>` or an `aria-label`/`aria-labelledby` attribute.
- **Dynamic UI States**: 
  - Use `aria-expanded="true/false"` for collapsible menus.
  - Use `aria-hidden="true"` to hide decorative illustrations or icon SVGs from screen readers.
  - Use `aria-live="polite"` for dynamic, real-time message areas or log viewers.

### Keyboard Navigation & Focus Management
- **Keyboard Navigability**: Every interactive element must be focusable using the `Tab` key.
- **Visible Focus States**: Never remove the browser's default focus ring unless implementing a highly visible custom focus state (e.g., `focus:ring-2 focus:ring-slate-400`).
- **Modal Focus Trap**: When displaying modals, implement focus trapping (preventing the user from tabbing out of the modal into background content) and close-on-Escape behavior.

## UI Design & Accessibility Audit Checklist

Audit your frontend work against this checklist:

```markdown
### UI & Accessibility Audit
- [ ] **Colors**: Saturated primaries replaced with sober, low-saturation tones?
- [ ] **Semantic Markup**: Validated landmarks and strict heading hierarchy?
- [ ] **Keyboard Navigation**: All interactive elements reachable via Tab?
- [ ] **ARIA Attributes**: Form controls labeled and dynamic states mapped?
- [ ] **Focus Management**: Focus ring visible and focus trapped in active modals?
```
