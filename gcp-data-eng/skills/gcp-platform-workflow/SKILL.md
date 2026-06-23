---
name: gcp-platform-workflow
description: >
  Enforces GCP authentication pre-checks, cost estimation, BigQuery query optimization, and user approval guardrails.
  Use this skill whenever the task involves interacting with Google Cloud Platform (GCP) services
  (e.g., BigQuery, Vertex AI, Google Cloud Storage, Cloud Build, Cloud Run).
---

# GCP Platform Workflow & Authentication Guidelines

To ensure secure, cost-controlled, and reliable operations on Google Cloud Platform (GCP), you MUST follow this systematic workflow before executing any commands or generating code that interacts with GCP services.

## When to Use This Skill

- Use this skill **immediately** at the start of any task that references GCP services.
- This skill must be executed **before** writing any code or proposing implementation plans.

## Workflow

### Step 1: Authentication Pre-Check & Verification
Before drafting an implementation plan or running GCP commands, you must verify the active GCP credentials and project to prevent deploying to or scanning the wrong environment.

1. **Retrieve Credentials**: Run the following command in the background to get authenticated accounts and the active project:
   ```bash
   gcloud auth list --format=json
   gcloud config get-value project
   ```
2. **User Confirmation**: Parse the JSON output and extract the available account emails. Use the `ask_question` tool to present an interactive modal to the user containing the list of available accounts and the active project. Ask the user to select the correct account and confirm the project.
3. **Set & Validate Account**:
   - Run `gcloud config set account <selected_account>`.
   - Validate the token by running `gcloud auth print-access-token`.
4. **SSO Fallback**: If token validation fails or no accounts are active, propose running browser-based SSO:
   ```bash
   gcloud auth login && gcloud auth application-default login
   ```
   Wait for the user's approval and successful login before proceeding.

### Step 2: Execution Planning & Cost Estimation
Only after authentication is verified, create a detailed implementation plan. 

- **Plan Headers**: Explicitly list the selected GCP Account and active GCP Project at the very top of your plan.
- **Cost Estimate**: Include a clear cost estimation or dry-run byte scans (e.g., BigQuery dry-runs) for any cloud resources that will be executed or spawned in the cloud (e.g., BigQuery queries using dry-run byte scans, Vertex AI endpoint training/prediction, Cloud Storage storage/network transfers).
- **User Approval Guardrail**: You **MUST NOT** execute any downstream commands or generate code until the user explicitly approves this plan in the chat.

### Step 3: BigQuery Cost Estimation and Optimization
Before executing any analytical or high-scale queries in BigQuery, you must proactively manage, estimate, and optimize costs to safeguard budget and resources.

#### Dry Run Cost Estimation
Always perform a "dry run" to calculate the number of bytes processed before executing a query. 

```python
from google.cloud import bigquery

client = bigquery.Client()
query_string = "SELECT id, name FROM `my_project.my_dataset.my_table`"

job_config = bigquery.QueryJobConfig(dry_run=True, use_query_cache=False)
query_job = client.query(query_string, job_config=job_config)

# The results are available immediately on the query job
bytes_processed = query_job.total_bytes_processed
estimated_cost_usd = (bytes_processed / 10**12) * 6.25  # Assuming $6.25 per TB on On-Demand

print(f"This query will process {bytes_processed} bytes.")
print(f"Estimated Cost: ${estimated_cost_usd:.4f} USD.")
```

#### Partition and Cluster Filtering
Never execute full-table scans on partitioned or clustered tables.
*   **Enforce Partition Filters**: Check if the target table is partitioned (e.g. by `_PARTITIONTIME` or a custom date column). Always include a `WHERE` clause filtering by the partition key.
*   **Enforce Cluster Fields**: If the table is clustered, place the cluster columns in the `WHERE` clause in the exact order of their definition to maximize scan pruning.
*   **Require Partition Filter Configuration**: Set `require_partition_filter = True` in your query configuration where supported to prevent accidental expensive full scans.

#### Projection Pruning
- **Never use `SELECT *`**: Only project the specific columns required by your downstream tasks. BigQuery is a columnar store; projecting unused columns directly multiplies cost.
- **Prune Structs**: If a column is a `STRUCT`, select only the nested fields you need (e.g. `user.id` instead of `user`) to reduce scanned bytes.

## Execution Plan Template

When proposing an implementation plan for GCP tasks, prepend this section to the top of your plan:

```markdown
# GCP Execution Plan

## GCP Environment Context
- **Active GCP Account**: `<selected_account_email>`
- **Active GCP Project**: `<active_project_id>`
- **Estimated Resource Cost/Usage**: `<estimated_cost_or_bytes_scanned>`

## High-Level Tasks
1. [Task 1]
2. [Task 2]

*Please approve this plan in the chat before execution begins.*
```
