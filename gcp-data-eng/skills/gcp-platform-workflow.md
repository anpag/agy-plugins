---
id: gcp-platform-workflow
type: skill
description: Guidelines for GCP authentication pre-checks, cost-estimation, and execution planning for cloud tasks.
requires: []
suggests: []
---

# GCP Platform Workflow & Authentication Guidelines

When executing tasks or commands that interact with Google Cloud Platform (GCP) services (e.g. BigQuery, Vertex AI, Google Cloud Storage, Cloud Build), you must adhere to these strict authentication, planning, and cost-control workflows.

---

## 1. GCP Authentication Pre-check (INITIAL ACTION BEFORE PLANNING)

Before creating any implementation or architecture plan that involves GCP resources:

1.  **Check Configuration:** Silently run `gcloud auth list --format=json` and `gcloud config get-value project` in the background.
2.  **Verify Account:** Extract the available account emails from the JSON output. Use the native `ask_question` tool to present an interactive UI modal containing the list of available accounts and the active project. Ask the user to select the correct account and confirm the project.
3.  **Validate Token:** Once the user selects an account, silently run `gcloud config set account <SELECTED_ACCOUNT>` and then validate the token by running `gcloud auth print-access-token`.
4.  **SSO Fallback:** If token validation fails, do not attempt to switch accounts. Propose running `gcloud auth login && gcloud auth application-default login` via the `run_command` tool to allow the user to perform browser SSO. Wait for successful completion before moving to the planning stage.

---

## 2. Execution Planning & Cost Estimation

Only after the interactive GCP Auth workflow is successfully completed:

1.  **Draft Detailed Plan:** Create a detailed execution plan broken down into atomic, specific tasks with testable outcomes.
2.  **Explicit Headings:** Your plan **must** explicitly list the selected GCP Account and active GCP Project at the very top.
3.  **Cost Estimate:** Your plan **must** include a clear Cost Estimate for any actions or resources that will be executed or spawned in the cloud (e.g., BigQuery queries using dry-run byte scans, Vertex AI endpoint training/prediction, Cloud Storage storage/network transfers).
4.  **User Approval Guardrail:** You **must not** start executing any downstream tasks (no terminal commands, no code generation) until the user explicitly approves this plan in the chat.
