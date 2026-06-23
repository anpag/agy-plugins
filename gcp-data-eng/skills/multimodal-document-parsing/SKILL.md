---
name: multimodal-document-parsing
description: >
  Enforces high-integrity unstructured document parsing using Gemini Multimodal Structured Outputs.
  Use this skill whenever you need to parse PDFs, scans, receipts, invoices, or visual documents
  using the GenAI SDK. Do not use local Python OCR libraries.
---

# Multimodal Document Parsing & Structured Extraction

This skill defines the standards for high-integrity unstructured document parsing using Gemini Multimodal Structured Outputs via the Vertex AI / Google GenAI SDK.

## When to Use This Skill

- Trigger this skill whenever you are tasked with **extracting text, tables, or relations from unstructured documents** (such as scanned PDFs, images, receipts, invoices, hand-written notes, or charts).
- **DO NOT** attempt to use traditional Python libraries (such as `pypdf`, `pdfplumber`, `pytesseract`, etc.) for text extraction.

## Core Parsing Workflow

### 1. Ingest Raw Bytes Directly
Pass the raw PDF or image bytes directly as a multimodal part using the `google-genai` SDK:
```python
pdf_part = types.Part.from_bytes(data=pdf_bytes, mime_type="application/pdf")
```

### 2. Define a Pydantic Schema
Create a strict Pydantic model (`BaseModel`) reflecting the target relational table structure (nodes, edges, attributes) and specify translation requirements directly inside field descriptions:
```python
from pydantic import BaseModel, Field

class Ingredient(BaseModel):
    name: str = Field(description="Name of the ingredient, translated to English (e.g. 'cinnamon stick' instead of 'rama de canela')")
    canonical_spanish_name: str = Field(description="The original ingredient name as written in Spanish")
```

### 3. Leverage Native Response Schema
Configure the generation request to return structured JSON adhering directly to the Pydantic schema:
```python
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents=[pdf_part, prompt],
    config=types.GenerateContentConfig(
        response_mime_type="application/json",
        response_schema=Ingredient,
        temperature=0.1
    ),
)
```

### 4. Spacing Concurrency for Rate Limits (Crucial)
- **Quota Boundaries**: Vertex AI Gemini API calls are subject to Requests Per Minute (RPM) limits (typically 15 RPM by default).
- **Concurrency Guardrail**: Do not launch high-throughput thread pools (e.g., `ThreadPoolExecutor` with 8+ workers) without a rate limiter or sequential spacing, as this will trigger severe rate limiting and connection drops (raising `ValueError` or `APIError`).
- **Persistence**: Cache successful extractions locally so that runs can resume if interrupted.

### 5. Bypass Python 3.13 mTLS OpenSSL Bug
Under Python 3.13, standard GCP SDK clients may raise a `MutualTLSChannelError` ("Context has already been used to create a Connection") if `pyopenssl` is absent.
- **Programmatic Solution**: Programmatically set the environment variable at the very top of client-initiating Python scripts before invoking any GCP SDK client:
  ```python
  import os
  os.environ["GOOGLE_API_USE_CLIENT_CERTIFICATE"] = "false"
  ```

## Multimodal Parsing Checklist

Use this checklist during document extraction tasks:

```markdown
### Multimodal Extraction Audit
- [ ] **No Local OCR**: Traditional PDF/OCR text libraries bypassed?
- [ ] **Native Bytes**: Ingested directly using `Part.from_bytes`?
- [ ] **Pydantic Schema**: Strict schema with field descriptions for translation defined?
- [ ] **Rate Limiting**: Concurrency capped and rate-spaced to prevent 429/APIError?
- [ ] **mTLS Bug Workaround**: `GOOGLE_API_USE_CLIENT_CERTIFICATE="false"` set for Python 3.13 compatibility?
```
