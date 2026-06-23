---
name: swe_best_practices
description: >
  Enforces global software engineering, code modularity, logging, testing, and concurrency standards.
  Use this skill for all programming, refactoring, and software design tasks.
---

# Global Software Engineering & Optimization Standards

This skill defines the rigorous software engineering standards required to build production-grade, maintainable, and scalable applications.

## When to Use This Skill

- Apply these principles to **every** coding, refactoring, or code-design task.
- Enforce these rules during code generation, test writing, and pull request preparation.

## Core Development Pillars

### 1. Code Modularity & Separation of Concerns
- Avoid monolithic scripts. Decouple your logic into small, single-responsibility functions or classes.
- Separate concerns cleanly: decouple data extraction (ETL), business logic, model training, and evaluation.
- **Polyglot Vigilance**: When writing full-stack code, actively guard against syntax bleeding between languages (e.g., using Python f-strings inside JavaScript templates).

### 2. Robust Observability & Logging
- Never use raw `print()` statements for application logs. Implement structured logging with timestamps, severity levels, and execution context.
- Implement elegant error handling and informative exceptions so failures in automated runners or pipelines can be easily diagnosed.

### 3. Concurrency & Thread Safety
- **Shared Client Isolation**: When building multi-threaded or concurrent applications (e.g., Flask/FastAPI, concurrent ETL), **never** share global GCP client instances (like `bigquery.Client` or `genai.Client`). Always instantiate thread-confined clients locally within the request handler to prevent socket connection mutation errors.
- **High-Throughput ETL**: Replace sequential loops with Python's `concurrent.futures.ThreadPoolExecutor` for parallel API or database operations.

### 4. High-Performance Data Ingestion
- **Batch Ingestion**: Avoid individual streaming inserts (e.g., `insert_rows_json()`) inside loops. Instead, aggregate data locally and execute a high-throughput, bulk load job (e.g., `load_table_from_json()`) at the end of the pipeline.
- **Exponential Backoff**: Never use hardcoded `time.sleep()` delays. Integrate robust backoff libraries (like `tenacity`) to handle `429 Too Many Requests` or `503 Service Unavailable` errors gracefully.

### 5. Automated Testing & Reproducibility
- Write comprehensive unit tests for all business logic, data transformations, and utility functions.
- Define dependencies explicitly in standard files (`requirements.txt`, `pyproject.toml`, `package.json`) to guarantee environment parity. Never hardcode local paths.
- **Git Identity Override**: Before authoring commits or pushing, verify that your local Git config is overridden to your primary identity. Never commit under generic system identities.

## Code Quality Checklist

Before submitting code changes or declaring a task complete, run through this checklist:

```markdown
### Code Quality Checklist
- [ ] **Modularity**: Monolithic code broken down? Concerns decoupled?
- [ ] **Logging**: Structured logging used instead of print?
- [ ] **Thread Safety**: GCP clients confined to local threads?
- [ ] **Error Handling**: Graceful exceptions and backoffs (tenacity) in place?
- [ ] **Git Identity**: Committing under the user's verified name/email?
- [ ] **Testing**: Unit tests written and passing locally?
```
