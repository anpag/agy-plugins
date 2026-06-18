---
name: rigorous-planning
type: skill
description: Guidelines for high-rigor project planning, architectural ASCII visualization, and explicit milestone execution tracking.
requires: []
suggests: []
---

# Skill: Rigorous Planning and Structured Execution

This skill governs high-rigor project planning, architectural visualization, and milestone execution tracking. It ensures complete separation between planning and execution phases to guarantee software safety, clarity, and structural alignment.

## Guidelines

### 1. Planning vs. Execution Isolation (CRITICAL)
- **Planning Phase**: NEVER generate, output, or preview code (Python, YAML, JavaScript, SQL, etc.) during the initial planning phase. You must produce:
  1. An execution plan in `/usr/local/google/home/antoniopaulino/.gemini/antigravity-cli/brain/<conversation-id>/execution_plan.md` containing the high-level plan, ASCII diagram, and a concurrent execution matrix.
  2. A task tracking file in `/usr/local/google/home/antoniopaulino/.gemini/antigravity-cli/brain/<conversation-id>/tasks.html` structured as an HTML table showing Task ID, Track, Description, and Status.
  3. You must request explicit human approval using the system's approval feature before entering the execution phase.
- **Execution Phase**: Once approval is granted, proceed with code changes, script executions, and database/pipeline creations. Keep `tasks.html` updated as each task is finished. When generating database schemas, graph DDLs, or queries, always provide the complete code without placeholders or truncation.

### 2. Visual Architecture Planning (ASCII Only)
- During the planning phase, you MUST output a high-level architectural diagram showing the data/execution flow across parallel tracks (Data, ML, UI).
- This diagram MUST be constructed using pure, raw ASCII art (plain text characters like `+`, `-`, `|`, `>`).
- NEVER use Mermaid.js, Markdown code blocks for rendering, HTML, or SVG. The diagram must be perfectly legible in a raw, unformatted terminal console.

### 3. File Formats and Templates

#### A. Tasks Tracking Table (`tasks.html`)
The `tasks.html` file must contain an interactive or cleanly styled HTML table. Initial task status must be `<span class="status-pending">PENDING</span>`.

Template:
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Tasks Status</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #121212; color: #e0e0e0; padding: 20px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #333; padding: 12px; text-align: left; }
        th { background-color: #1a1a1a; color: #ffffff; }
        tr:nth-child(even) { background-color: #161616; }
        .status-pending { color: #ff9800; font-weight: bold; }
        .status-running { color: #2196f3; font-weight: bold; }
        .status-completed { color: #4caf50; font-weight: bold; }
    </style>
</head>
<body>
    <h1>Task Tracking</h1>
    <table>
        <thead>
            <tr>
                <th>Task ID</th>
                <th>Track</th>
                <th>Milestone / Task Description</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <!-- Tasks here -->
        </tbody>
    </table>
</body>
</html>
```

#### B. Execution Plan (`execution_plan.md`)
The `execution_plan.md` file must contain the ASCII data-flow diagram and a Markdown-formatted table representing the concurrent execution matrix.

---

## Dynamic Status Updates
During the execution phase, as each milestone task starts running or reaches completion, the agent MUST update `tasks.html` using the appropriate file editing tools to update the Status column (e.g., to `RUNNING` or `COMPLETED`).
