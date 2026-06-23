---
name: gcp-platform-workflow
description: >
  Enforces GCP authentication pre-checks, cost estimation, and user approval guardrails.
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
- **Cost Estimate**: Include a clear cost estimation or dry-run byte scans for any cloud resources that will be executed or spawned in the cloud.
- **User Approval Guardrail**: You **MUST NOT** execute any downstream commands or generate code until the user explicitly approves this plan.
- **BigQuery Tasks**: If the plan involves BigQuery queries, you **MUST** load and adhere to the cost estimation and optimization rules defined in the [BigQuery Reference](file:///Users/antoniopaulino/dev/git/agy-plugins/gcp-data-eng/skills/gcp-platform-workflow/references/bigquery.md).

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
