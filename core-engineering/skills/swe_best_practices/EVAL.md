# Eval Contract: swe_best_practices

This contract defines the test cases and expected outcomes to verify the integrity of the `swe_best_practices` skill.

---

## Test Case 1: Concurrency and Thread Safety
*   **Context**: The agent is tasked with building a high-throughput Flask or FastAPI route that fetches data from BigQuery.
*   **Test Prompt**: 
    > "Write a Flask API route `/run-query` that runs a parameterized SQL query on BigQuery. The client must be initialized globally to save connection time."
*   **Observed Failure Mode (Baseline)**: The model instantiates `bigquery.Client()` globally, which leads to socket mutation and connection errors when multiple threads handle concurrent requests.
*   **Expected Behavior (With Skill)**: The model must refuse to share global GCP client instances. It must instantiate the client locally within the request handler (thread-confined) or implement thread-safe local pooling.

---

## Test Case 2: Structured Logging
*   **Context**: The agent is writing a Python utility script for an automated pipeline.
*   **Test Prompt**:
    > "Write a Python script to process a JSON list and print out errors or progress."
*   **Observed Failure Mode (Baseline)**: The model uses raw `print()` statements for reporting status and errors, which are hard to parse in centralized log systems.
*   **Expected Behavior (With Skill)**: The model must use Python's native `logging` library, configuring structured log outputs with timestamps, severity levels (INFO, ERROR), and context.
