---
id: minimalist-design-system
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

## 2. Spacing & Negative Space (Generous Breathing Room)

*   **Padding:** Default to large padding (`p-6` or `p-8` in Tailwind, `24px` to `32px` in CSS) to allow components to breathe.
*   **Margins:** Use standard multipliers of `8px` (`8px`, `16px`, `24px`, `32px`, `48px`) to maintain rigid grid alignment.
*   **Grid Layouts:** Use CSS Grid or Flexbox with a gap of at least `24px` (`gap-6`) to separate content card components cleanly.

---

## 3. Typography & Hierarchy

Use modern, clean, geometric sans-serif typefaces (e.g. Inter, Outfit, or standard system-sans) instead of browser defaults.

*   **Headings:** Thick weights (`600` or `700`) with small font sizes to maintain a sleek, premium look.
*   **Line-Height:** Ensure body text line-height is at least `1.6` to allow comfortable reading.
*   **Letter-Spacing:** Tighten headings slightly (`tracking-tight`) and widen uppercase labels (`tracking-wider`).
