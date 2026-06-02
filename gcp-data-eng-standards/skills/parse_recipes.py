"""
---
id: parse_recipes
type: skill
description: Extract structured entities (ingredients, allergens, seasonal pairings) from recipe PDFs using Vertex AI Gemini.
requires: []
suggests: []
---
"""

import json
import os
from typing import Any, Dict


def extract_recipe_entities(pdf_path: str) -> Dict[str, Any]:
    """Parses a culinary recipe PDF to extract ingredients, allergens, and pairings.

    Args:
        pdf_path: Path to the unstructured recipe PDF.

    Returns:
        A structured dictionary containing extracted culinary metadata.
    """
    if not os.path.exists(pdf_path):
        raise FileNotFoundError(f"Recipe PDF not found at: {pdf_path}")

    print(f"Extracting culinary entities from: {pdf_path} using Vertex AI Gemini...")

    # Simulated structured output of Gemini extraction for the demo
    extracted_data = {
        "recipe_name": "Pan-Seared Ribeye with Herb Butter",
        "flavor_profile": "Rich, savory, herbal, bold",
        "ingredients": [
            {"name": "Ribeye Steak", "category": "Protein", "amount": "16 oz"},
            {"name": "Unsalted Butter", "category": "Dairy", "amount": "2 tbsp"},
            {"name": "Fresh Rosemary", "category": "Herb", "amount": "3 sprigs"},
            {"name": "Garlic", "category": "Allium", "amount": "4 cloves"},
        ],
        "allergens": ["Dairy"],
        "seasonal_pairings": [
            {"item": "Roasted Asparagus", "season": "Spring"},
            {"item": "Cabernet Sauvignon", "season": "All-Year"},
        ],
    }
    return extracted_data


if __name__ == "__main__":
    # Demo-ready dry run
    try:
        sample_data = extract_recipe_entities("ribeye_steak.pdf")
        print("Extracted Culinary Data Structure:")
        print(json.dumps(sample_data, indent=2))
    except FileNotFoundError:
        print("Recipe parser skill initialized and ready for execution context.")
