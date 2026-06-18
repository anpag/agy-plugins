---
name: multimodal-document-parsing
type: skill
description: Guidelines for high-integrity unstructured document parsing using Gemini Multimodal Structured Outputs instead of brittle Python OCR/text extraction libraries.
requires: []
suggests: []
---

# Multimodal Document Parsing & Structured Extraction

When parsing unstructured documents (such as scanned PDFs, images of recipes, receipts, invoices, hand-written notes, and charts), you must use **Gemini Multimodal Structured Outputs** via the Vertex AI / Google GenAI SDK instead of attempting to use traditional Python libraries (such as `pypdf`, `pdfplumber`, `pytesseract`, etc.) for text extraction.

---

## 1. Why Traditional Python Libraries Fail
Traditional text extraction or OCR libraries fail on scanned PDFs or complex visual documents because:
*   They cannot extract text from raw image scans inside a PDF (requiring native multimodal vision).
*   They lose visual layout context (columns, tables, sidebars, margins), leading to scrambled words.
*   They cannot natively translate or clean text structure while extracting.

## 2. Guideline: Multimodal Structured Parsing with Gemini
To process these documents accurately and maintain absolute data integrity:

1.  **Do Not Parse with Local Text Libraries**: Never try to extract raw text or tables from scans using Python OCR or standard PDF readers.
2.  **Ingest Raw Bytes Directly**: Pass the raw PDF or image bytes directly as a multimodal part using the `google-genai` SDK:
    ```python
    pdf_part = types.Part.from_bytes(data=pdf_bytes, mime_type="application/pdf")
    ```
3.  **Define a Pydantic Schema**: Create a strict Pydantic model (`BaseModel`) reflecting the target relational table structure (nodes, edges, attributes).
4.  **Leverage Native Response Schema**: Configure the generation request to return structured JSON adhering directly to the Pydantic schema:
    ```python
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=[pdf_part, prompt],
        config=types.GenerateContentConfig(
            response_mime_type="application/json",
            response_schema=MyTargetPydanticModel,
            temperature=0.1
        ),
    )
    ```
5.  **Handle Quota/Rate Limits (Crucial)**:
    *   **Default Quota Boundaries**: Vertex AI Gemini API calls are generally subject to default quotas (e.g., 15 Requests Per Minute [RPM]).
    *   **Control Thread Concurrency**: Do not launch high-throughput thread pools (e.g., `ThreadPoolExecutor` with 8+ workers) without a rate limiter or sequential spacing, as this will trigger severe rate limiting and connection drops (raising `ValueError` or `APIError`).
    *   **Implement Persistence/Caching**: Cache successful extractions locally so that runs can resume if interrupted.

6.  **Bypass Python 3.13 mTLS OpenSSL Bug**:
    *   **Issue**: Under Python 3.13, standard GCP SDK clients may raise a `MutualTLSChannelError` ("Context has already been used to create a Connection") if `pyopenssl` is absent or improperly configured.
    *   **Programmatic Solution**: Programmatically set the environment variable at the very top of client-initiating Python scripts before invoking any GCP SDK client:
        ```python
        import os
        os.environ["GOOGLE_API_USE_CLIENT_CERTIFICATE"] = "false"
        ```
    *   *Alternative*: Uninstalling `pyopenssl` forces `urllib3` to use the standard library SSL module, which is also a robust workaround.

7.  **In-Parser Translation and Schema Mapping**:
    *   When parsing documents in foreign languages (e.g., recipes in Spanish, receipts in French) into standard schemas, do not run a separate translation phase. Instead, use Gemini's natural multilingual capabilities by specifying the translation requirements directly inside your Pydantic schema field descriptions.
    *   *Example*:
        ```python
        class Ingredient(BaseModel):
            name: str = Field(description="Name of the ingredient, translated to English (e.g. 'cinnamon stick' instead of 'rama de canela')")
            canonical_spanish_name: str = Field(description="The original ingredient name as written in Spanish")
        ```

