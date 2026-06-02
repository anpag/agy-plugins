/*
---
id: build_culinary_graph
type: skill
description: SQL DDL generation for creating BigQuery Property Graph vertex and edge tables.
requires: []
suggests: []
---
*/

-- Create Vertex Table for Recipes
CREATE OR REPLACE TABLE `culinary_dataset.recipes` (
  recipe_id STRING,
  name STRING,
  flavor_profile STRING
);

-- Create Vertex Table for Ingredients
CREATE OR REPLACE TABLE `culinary_dataset.ingredients` (
  ingredient_id STRING,
  name STRING,
  category STRING
);

-- Create Edge Table for Recipe-to-Ingredient Relationship
CREATE OR REPLACE TABLE `culinary_dataset.recipe_ingredients` (
  recipe_id STRING,
  ingredient_id STRING,
  amount STRING
);

-- Create BigQuery Property Graph definition
-- Demonstrating high-fidelity GQL DDL mapping
CREATE OR REPLACE PROPERTY GRAPH `culinary_dataset.CulinaryGraph`
VERTEX TABLES (
  `culinary_dataset.recipes` KEY (recipe_id) LABEL Recipe,
  `culinary_dataset.ingredients` KEY (ingredient_id) LABEL Ingredient
)
EDGE TABLES (
  `culinary_dataset.recipe_ingredients`
    KEY (recipe_id, ingredient_id)
    SOURCE KEY (recipe_id) REFERENCES recipes (recipe_id)
    DESTINATION KEY (ingredient_id) REFERENCES ingredients (ingredient_id)
    LABEL HAS_INGREDIENT
);
