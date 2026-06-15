These are the personal identity, authentication, and workspace constraints for Antonio Paulino.

1. **Git Identity Management**:
   - ALWAYS use the user's personal Git identity (`Antonio Paulino` <antoniopaulino@google.com>) for all commits and pushes. If the globally or locally configured Git identity is set to 'Gemini Coach' or 'gemini-coach@example.com', you MUST immediately override them locally by running:
      `git config --local user.name "Antonio Paulino"`
      `git config --local user.email "antoniopaulino@google.com"`
      Never author commits or pushes under 'Gemini Coach' or other placeholder system identities.
   - Commit code frequently with atomic, logically separated changes, and write clear, descriptive commit messages.

2. **Environment & Dependency Control**:
   - Always explicitly define dependencies (e.g., `requirements.txt`, `environment.yml`, `Pipfile`, `pyproject.toml`) to guarantee reproducibility.
   - Avoid hardcoding local file paths; use relative paths, environment variables, or configuration files.
   - CRITICAL: ALWAYS rely on standard `pip` and `venv` for Python environments. NEVER use `uv`, as it is blocked by company policy.

3. **AI Model Selection & Regions (CRITICAL)**:
   - You MUST NEVER use deprecated models such as `gemini-1.5-flash` or `gemini-1.5-pro`.
   - You MUST ONLY use the following current models:
     - `gemini-3.5-flash` (Generally Available). Available regions: `global`, `us` (multi-region), `eu` (multi-region).
     - `gemini-3.1-pro` (Public Preview). Available regions: `global`.
   - When initializing Vertex AI clients or generating content, explicitly ensure you use these exact model names and set the location/region appropriately based on the model's availability.

4. **Dynamic Plugin & Agent Discovery**:
   - For any task, proactively inspect the globally registered plugins, their descriptions, and their exposed subagents/skills.
   - If the task aligns with the domain description of an installed plugin, dynamically delegate the execution of that task to the plugin's specialized subagent(s) rather than handling it under a generic persona.
   - Instruct the subagents to automatically load and adhere to their respective plugin skills.

5. **Professional Communication & Documentation**:
   - NEVER use emojis or emoticons in documentation, comments, scripts, or output logs.
   - Maintain a highly professional, clinical, and clean tone across all system files and console outputs.

6. **Dynamic Planning & Architecture Isolation (CRITICAL)**:
   - For all Tier 1 tasks (e.g., standard coding queries, direct tool executions, system checks, and direct questions), do NOT write formal plans, HTML task-tracking sheets, or ASCII architecture diagrams. Respond and execute directly.
   - For Tier 2 tasks (e.g., multi-file refactorings, system architecture setup, or database migrations), proactively instruct the user to delegate the work to the specialized `tech-lead` subagent. The `tech-lead` subagent will automatically load the `rigorous-planning` skill to execute high-rigor planning, ASCII diagramming, HTML progress tracking (`tasks.html`), and approval gating.
