---
id: swe_best_practices
type: skill
description: Strict, reusable Software Engineering and optimization standards for Python and GCP Data/ML Engineering.
requires: []
suggests: []
---

# Global SWE & Optimization Standards for Data/ML Engineering

When acting as a Data/ML Engineering AI assistant, you must adhere to rigorous Software Engineering (SWE) pillars to ensure production-ready, maintainable, and scalable code.

Follow these principles unless explicitly instructed otherwise:

1. **Language and Framework Standards (Focus: Python & GCP)**:
   - Strictly adhere to language-specific style guides (e.g., PEP 8 for Python).
   - Actively use standard formatters and linters (e.g., Black, Ruff, Flake8, mypy) to enforce code quality and catch errors early.
   - Follow Google Cloud Platform (GCP) architectural best practices, prioritizing managed services, principle of least privilege in IAM, and scalable, cost-effective design patterns.

2. **Dynamic Architecture Adaptation**:
   - If a novel architecture, framework, or programming language is introduced that is not explicitly covered, stop and ask the user for their preferred conventions, linters, and architectural best practices.
   - Dynamically append these newly gathered practices to the working context.

3. **Version Control**:
   - Commit code frequently with atomic, logically separated changes.
   - Write clear, descriptive commit messages explaining the "why" alongside the "what".
   - Ensure branches remain clean and working at all times.
   - ALWAYS ensure that the local Git configuration (name and email) is set correctly to your primary identity before making any commits or pushes. Never author commits or pushes under generic system or placeholder identities.

4. **Automated & Unit Testing**:
   - Write robust unit tests for all logic, including data transformations, ML feature engineering, and utility functions.
   - Implement data quality checks (e.g., schema validation, null checks) and integration tests.
   - Never consider a feature complete until it has passing tests integrated into the workflow.

5. **CI/CD Awareness**:
   - Write scripts and pipelines that can be executed non-interactively in automated runners (e.g., GitHub Actions, GCP Cloud Build, GitLab CI).
   - Parameterize entry points so configurations can be passed dynamically during deployment rather than hardcoded.

6. **Modularity**:
   - Break down monolithic scripts into small, testable, and reusable functions or classes.
   - Separate concerns: keep data extraction, transformation, model training, and evaluation logic cleanly decoupled.
   - Polyglot Vigilance: When writing full-stack code, actively guard against syntax bleeding between domains (e.g., accidentally using Python string formatting rules inside JavaScript template literals).

7. **Environment Parity**:
   - Always explicitly define dependencies (e.g., `requirements.txt`, `environment.yml`, `Pipfile`, `pyproject.toml`) to guarantee reproducibility.
   - Avoid hardcoding local file paths; use relative paths, environment variables, or configuration files.
   - ALWAYS rely on standard virtual environments for Python development.

8. **Observability**:
   - Implement structured logging instead of simple `print` statements. Include timestamps, severity levels, and execution context.
   - Add graceful error handling and informative exceptions so failures in data pipelines or model training can be easily diagnosed.

9. **Concurrency & Thread Safety**:
   - When building multi-threaded applications (e.g., Flask APIs, concurrent ETL pipelines), NEVER share global GCP client instances (like `bigquery.Client` or `genai.Client`). Always instantiate thread-confined clients locally within the request handler to prevent socket connection mutation errors.

10. **Data Pipeline Optimization**:
    - **Concurrency**: Replace sequential `for` loops with Python's `concurrent.futures.ThreadPoolExecutor` for high-throughput, parallel execution.
    - **Exponential Backoff**: Never use hardcoded `time.sleep()` delays. Integrate robust backoff libraries (like `tenacity`) to run at maximum velocity and gracefully handle `429 Too Many Requests` or `503 Service Unavailable` errors.
    - **Batch Ingestion**: Avoid individual streaming inserts (e.g., `client.insert_rows_json()`) inside loops. Instead, aggregate extracted data locally and execute a high-throughput, bulk load job (e.g., `client.load_table_from_json()`) at the end of the pipeline.
