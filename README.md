# Antigravity (`agy`) Custom Plugins & Global User Profiles

This repository houses the modular, domain-specific plugins and global user configurations for the Antigravity (`agy`) CLI environment.

---

## Repository Architecture

The codebase has been refactored into a fully decoupled, scalable architecture where personal identity is cleanly separated from generic engineering capabilities:

```text
agy-plugins/
 ├── GEMINI.md                    # Baseline Global User Profile (Identity, Auth, Models)
 ├── README.md                    # This orchestration & deployment manual
 ├── core-engineering/            # Core standards plugin (PEP 8, Modularity)
 ├── gcp-data-eng/                # GCP Data/ML Engineering, BigQuery & Property Graphs
 └── ui-engineering/              # Premium minimalist UI design and WCAG accessibility
```

---

## 1. Operating & Installing Plugins

Manage your plugin installations using the native Antigravity `plugin` subcommands.

### Standard Subcommands:
*   **List installed plugins:**
    ```bash
    agy plugin list
    ```
*   **Install a local plugin:**
    ```bash
    agy plugin install /path/to/plugin_directory
    ```
*   **Uninstall an active plugin:**
    ```bash
    agy plugin uninstall <plugin-name>
    ```
*   **Validate plugin configuration schemas:**
    ```bash
    agy plugin validate /path/to/plugin_directory
    ```

### Bulk Installation Command:
To install or refresh all plugins hosted in this repository:
```bash
agy plugin install ./core-engineering && \
agy plugin install ./gcp-data-eng && \
agy plugin install ./ui-engineering
```

### The "CLI vs Shared Ecosystem" Architecture
*   **What `agy plugin install` does:** It installs the plugins into `~/.gemini/config/plugins/`. This makes them globally available to your entire machine, including IDE extensions (like Gemini Code Assist in VS Code/IntelliJ) and other clients.
*   **What the CLI expects for auto-discovery:** The standalone CLI only automatically scans its own local directory (`~/.gemini/antigravity-cli/skills` and `~/.gemini/antigravity-cli/agents`) for personal/local skills.
*   **Bridging the gap:** To tell the CLI where to find your globally installed plugins, we explicitly create lightweight `skills.json` and `agents.json` registries inside `~/.gemini/antigravity-cli/` that point to the shared global directory.

---

## 2. Deploying the Global User Profile (`GEMINI.md`)

The `GEMINI.md` file defines your personal user profile, Git identity overrides, sandbox environment constraints, and available model definitions. It acts as the central orchestrator and must be deployed to your home configuration folder to be loaded globally.

### Deployment Path:
The profile must be located exactly at:
`~/.gemini/GEMINI.md` (fully expanded as `/Users/antoniopaulino/.gemini/GEMINI.md`)

### Installation Command:
Run the following to deploy or update your global user profile:
```bash
cp ./GEMINI.md ~/.gemini/GEMINI.md
```

### Decoupled Profile Role:
This profile has been intentionally stripped of code-level styles, and instead contains the **Dynamic Plugin & Agent Discovery** engine. This engine automatically scans, registers, and contextually delegates tasks to your installed plugins (`gcp-data-eng`, `ui-engineering`), preventing workspace noise or duplicate authentication flows when executing local-only coding tasks.
