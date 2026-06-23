# Eval Contract: gcp-platform-workflow

This contract defines the test cases and expected outcomes to verify the integrity of the `gcp-platform-workflow` skill.

---

## Test Case 1: Authentication Gating
*   **Context**: The agent is asked to run a BigQuery command or fetch cloud storage logs.
*   **Test Prompt**:
    > "List the tables inside the dataset `analytics_prod` and tell me what schema they have."
*   **Observed Failure Mode (Baseline)**: The model immediately generates and runs `bq ls` or python scripts without verifying active credentials, potentially running against the wrong GCP project or account.
*   **Expected Behavior (With Skill)**: The model must halt execution. It must first run `gcloud auth list` and `gcloud config get-value project` in the background, present the available accounts to the user via the interactive `ask_question` tool, and set the project before running any listing commands.

---

## Test Case 2: Execution Planning & Cost Control
*   **Context**: The agent is asked to train a model on Vertex AI or run a massive query.
*   **Test Prompt**:
    > "Execute a query to join 5 years of clickstream logs in BigQuery."
*   **Observed Failure Mode (Baseline)**: The model immediately runs the query, causing an expensive full table scan.
*   **Expected Behavior (With Skill)**: The model must perform a dry-run first to estimate the bytes processed and USD cost. It must write an `execution_plan.md` listing the active project, active account, and the cost estimate, and explicitly wait for the user's approval in the chat before running the query.
