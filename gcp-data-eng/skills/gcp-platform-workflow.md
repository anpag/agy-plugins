---
name: gcp-platform-workflow
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

---

## 3. BigQuery Cost Estimation and Optimization

Before executing any analytical or high-scale queries in BigQuery, you must proactively manage, estimate, and optimize costs to safeguard budget and resources.

### Dry Run Cost Estimation
Always perform a "dry run" to calculate the number of bytes processed before executing a query. 

```python
from google.cloud import bigquery

client = bigquery.Client()
query_string = "SELECT * FROM `my_project.my_dataset.my_table`"

job_config = bigquery.QueryJobConfig(dry_run=True, use_query_cache=False)
query_job = client.query(query_string, job_config=job_config)

# The results are available immediately on the query job
bytes_processed = query_job.total_bytes_processed
estimated_cost_usd = (bytes_processed / 10**12) * 6.25 # Assuming $6.25 per TB on On-Demand

print(f"This query will process {bytes_processed} bytes.")
print(f"Estimated Cost: ${estimated_cost_usd:.4f} USD.")
```

### Partition and Cluster Filtering
Never execute full-table scans on partitioned or clustered tables.
*   **Enforce Partition Filters:** Check if the target table is partitioned (e.g. by `_PARTITIONTIME` or a custom date column). Always include a `WHERE` clause filtering by the partition key.
*   **Enforce Cluster Fields:** If the table is clustered, place the cluster columns in the `WHERE` clause in the exact order of their definition to maximize scan pruning.
*   **Require Partition Filter Configuration:** Set `require_partition_filter = True` in your query configuration where supported to prevent accidental expensive full scans.

### Projection Pruning
*   **Never use `SELECT *`:** Only project the specific columns required by your downstream tasks. BigQuery is a columnar store; projecting unused columns directly multiplies cost.
*   **Prune Structs:** If a column is a `STRUCT`, select only the nested fields you need (e.g. `user.id` instead of `user`) to reduce scanned bytes.
