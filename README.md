# Antigravity Agentic Plugins & Skills Repository

Welcome to the Antigravity Agentic Plugins and Skills repository. This workspace contains a collection of modular, production-grade plugins, specialized agent personas, and triggerable skills designed to supercharge autonomous development workflows.

---

## Design Philosophy

This repository is built upon three core engineering pillars:

### 1. Skills as Stopgaps
*   **Targeted Resolution**: Skills are designed to bridge specific capability gaps. They should only be written when an LLM fails a task even after having access to standard documentation.
*   **Anti-Bloat**: A skill is **not** a summary of technical manuals. It is the *minimum rule set* required to make observed model failure modes uncommon.
*   **Keep it Lean**: Over-specified skills go stale quickly and are ignored by models. We focus on lean, high-impact instructions.

### 2. Evals as Contracts
*   Every skill is paired with an `EVAL.md` file that acts as a declarative contract.
*   The eval defines the exact problem context, a test prompt, and the expected deterministic outcome. A skill must demonstrate measurable improvement over baseline behavior to justify its context window cost.

### 3. Clear Domain Separation
*   **Core Engineering**: Base code quality, structured logging, testing, and concurrency safety.
*   **GCP & Data Engineering**: Secure cloud workflows, cost-controlled BigQuery operations, and Knowledge Graph/Ontology design.
*   **UI Engineering**: Premium, minimalist visual design systems and strict WCAG 2.1 AA accessibility compliance.

---

## Directory Structure

The repository adheres strictly to the standardized directory layout:

```
<plugin-folder>/
├── plugin.json                 # Plugin metadata & capabilities
├── agents/                     # Specialized agent personas
│   └── <agent-name>.json
└── skills/                     # Triggerable skills
    └── <skill-name>/
        ├── SKILL.md            # YAML frontmatter + core guidelines
        ├── EVAL.md             # Declarative testing contract
        ├── references/         # (Optional) Supplementary heavy context
        └── scripts/            # (Optional) Helper scripts & automations
```

---

## Best Practices for Contributors

1.  **Prefer Extension Over Creation**: If a related skill exists, contribute to it rather than starting from scratch to maintain high discovery rates.
2.  **Target the Trigger**: Ensure the YAML frontmatter `description` in `SKILL.md` is action-oriented, explaining *exactly when* the model should load the skill.
3.  **Split Large Skills**: When a skill grows too large, move deep syntax reference sheets or long code snippets into a `references/` subdirectory to conserve the active context window.
4.  **Write the Eval First**: Before drafting a skill, capture the observed failure mode in an `EVAL.md` file, then iterate on the skill instructions until the model consistently passes the eval.

---

## Validation & Testing

Always validate the repository structure and schemas using the validation tool:
```bash
agy plugin validate ./core-engineering
agy plugin validate ./gcp-data-eng
agy plugin validate ./ui-engineering
```
