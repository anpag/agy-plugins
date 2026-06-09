---
id: wcag-accessibility
type: skill
description: Comprehensive checklists for meeting WCAG 2.1 AA accessibility standards in web interfaces.
requires: []
suggests: []
---

# WCAG 2.1 AA Accessibility Guidelines

All web interfaces must strictly comply with WCAG 2.1 AA accessibility guidelines.

---

## 1. Semantic HTML Structure

*   **Page Structure:** Use `<header>`, `<nav>`, `<main>`, `<section>`, `<article>`, and `<footer>` appropriately.
*   **Headings Hierarchy:** Use exactly one `<h1>` per page. Ensure subsequent headings (`<h2>` through `<h6>`) follow a strict logical hierarchy without skipping levels.
*   **Interactive Elements:** Use `<button>` for clickable actions that don't change the URL, and `<a>` for navigational links. Never use `<div>` or `<span>` for click handlers without explicit ARIA mapping and keyboard listener implementations.

---

## 2. ARIA Attributes & Roles

*   **Form Labels:** Ensure every `<input>`, `<textarea>`, and `<select>` has an associated `<label>` or an `aria-label`/`aria-labelledby` attribute.
*   **Dynamic UI States:** 
    *   Use `aria-expanded="true/false"` for collapsible menus.
    *   Use `aria-hidden="true"` to hide decorative illustrations or icon SVGs from screen readers.
    *   Use `aria-live="polite"` for dynamic, real-time message areas or log viewers.

---

## 3. Keyboard Navigation & Focus Management

*   **Keyboard Navigability:** Every interactive element must be focusable using the `Tab` key.
*   **Visible Focus States:** Never remove the browser's default focus ring unless implementing a highly visible custom focus state (e.g., `focus:ring-2 focus:ring-slate-400`).
*   **Modal Focus Trap:** When displaying modals, implement focus trapping (preventing the user from tabbing out of the modal into background content) and close-on-Escape behavior.
