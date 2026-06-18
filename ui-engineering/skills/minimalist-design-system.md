---
name: minimalist-design-system
type: skill
description: Strict design system guidelines enforcing a premium, minimalistic, and professional user interface aesthetic.
requires: []
suggests: []
---

# Premium Minimalist Design System Guidelines

These guidelines define a professional, high-signal-to-noise UI design system. When acting as a UI Design Engineer, you must strictly implement these layout, spacing, and color specifications.

---

## 1. Color Palette (Sober, Low-Saturation)

Avoid raw primaries, saturated bright colors, or intense gradients. Default to a premium light/off-white theme with high contrast.

*   **Backgrounds:** Off-white (`#F8F9FA` or HSL `210, 20%, 98%`) and pure white (`#FFFFFF`).
*   **Borders & Dividers:** Subtle, thin borders in light grey (`#E9ECEF` or HSL `210, 16%, 93%`).
*   **Primary Text:** Slate Grey/Near Black (`#212529` or HSL `210, 11%, 15%`) for maximum readability.
*   **Secondary Text:** Muted Grey (`#6C757D` or HSL `208, 7%, 46%`).
*   **Brand/Accent:** Low-saturation navy or steel blue (`#495057` or HSL `210, 10%, 23%`). Avoid bright blues/reds/greens unless signaling errors or success states.

---

## 2. WCAG 2.1 AA Accessibility Guidelines

All web interfaces must strictly comply with WCAG 2.1 AA accessibility guidelines.

### Semantic HTML Structure

*   **Page Structure:** Use `<header>`, `<nav>`, `<main>`, `<section>`, `<article>`, and `<footer>` appropriately.
*   **Headings Hierarchy:** Use exactly one `<h1>` per page. Ensure subsequent headings (`<h2>` through `<h6>`) follow a strict logical hierarchy without skipping levels.
*   **Interactive Elements:** Use `<button>` for clickable actions that don't change the URL, and `<a>` for navigational links. Never use `<div>` or `<span>` for click handlers without explicit ARIA mapping and keyboard listener implementations.

### ARIA Attributes & Roles

*   **Form Labels:** Ensure every `<input>`, `<textarea>`, and `<select>` has an associated `<label>` or an `aria-label`/`aria-labelledby` attribute.
*   **Dynamic UI States:** 
    *   Use `aria-expanded="true/false"` for collapsible menus.
    *   Use `aria-hidden="true"` to hide decorative illustrations or icon SVGs from screen readers.
    *   Use `aria-live="polite"` for dynamic, real-time message areas or log viewers.

### Keyboard Navigation & Focus Management

*   **Keyboard Navigability:** Every interactive element must be focusable using the `Tab` key.
*   **Visible Focus States:** Never remove the browser's default focus ring unless implementing a highly visible custom focus state (e.g., `focus:ring-2 focus:ring-slate-400`).
*   **Modal Focus Trap:** When displaying modals, implement focus trapping (preventing the user from tabbing out of the modal into background content) and close-on-Escape behavior.
