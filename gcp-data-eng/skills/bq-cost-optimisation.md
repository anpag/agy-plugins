---
name: bq-cost-optimisation
type: skill
description: Guidelines for estimating and optimizing query costs in BigQuery, including dry-run techniques and partition filtering.
requires: []
suggests: []
---

# BigQuery Cost Estimation and Optimisation Guidelines

Before executing any analytical or high-scale queries in BigQuery, you must proactively manage, estimate, and optimize costs to safeguard budget and resources.

---

## 1. Dry Run Cost Estimation

Always perform a "dry run" to calculate the number of bytes processed before executing a query. 

### Python Client Dry Run
To estimate query size without running the query and incurring cost, set `dry_run = True` on the QueryJobConfig:

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

---

## 2. Partition and Cluster Filtering

Never execute full-table scans on partitioned or clustered tables.

*   **Enforce Partition Filters:** Check if the target table is partitioned (e.g. by `_PARTITIONTIME` or a custom date column). Always include a `WHERE` clause filtering by the partition key.
*   **Enforce Cluster Fields:** If the table is clustered, place the cluster columns in the `WHERE` clause in the exact order of their definition to maximize scan pruning.
*   **Require Partition Filter Configuration:** Set `require_partition_filter = True` in your query configuration where supported to prevent accidental expensive full scans.

---

## 3. Projection Pruning

*   **Never use `SELECT *`:** Only project the specific columns required by your downstream tasks. BigQuery is a columnar store; projecting unused columns directly multiplies cost.
*   **Prune Structs:** If a column is a `STRUCT`, select only the nested fields you need (e.g. `user.id` instead of `user`) to reduce scanned bytes.
