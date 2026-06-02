/*
---
id: create_bq_property_graph
type: skill
description: Standard SQL DDL template for creating BigQuery Property Graph vertex and edge tables dynamically.
requires: []
suggests: []
---
*/

-- Step 1: Create Vertex Table placeholders for Nodes
CREATE OR REPLACE TABLE `target_dataset.source_nodes` (
  node_id STRING,
  node_name STRING,
  node_type STRING
);

CREATE OR REPLACE TABLE `target_dataset.destination_nodes` (
  node_id STRING,
  node_name STRING,
  node_type STRING
);

-- Step 2: Create Edge Table placeholders for Relationships
CREATE OR REPLACE TABLE `target_dataset.node_relationships` (
  source_id STRING,
  destination_id STRING,
  relationship_type STRING
);

-- Step 3: Create BigQuery Property Graph definition linking vertices and edges
CREATE OR REPLACE PROPERTY GRAPH `target_dataset.EntityGraph`
VERTEX TABLES (
  `target_dataset.source_nodes` KEY (node_id) LABEL SourceNode,
  `target_dataset.destination_nodes` KEY (node_id) LABEL DestinationNode
)
EDGE TABLES (
  `target_dataset.node_relationships`
    KEY (source_id, destination_id)
    SOURCE KEY (source_id) REFERENCES source_nodes (node_id)
    DESTINATION KEY (destination_id) REFERENCES destination_nodes (node_id)
    LABEL CONNECTED_TO
);
