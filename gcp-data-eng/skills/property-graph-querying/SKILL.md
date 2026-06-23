---
name: property-graph-querying
description: >
  Enforces GQL query writing, traversal syntax, path-search prefixes, graph-table joins, subquery rules, and query optimization in BigQuery.
  Use this skill whenever you are writing, executing, or optimizing BigQuery GQL / GRAPH_TABLE queries.
---

# BigQuery Property Graph Querying Guidelines

This skill defines the syntactic standards and optimization rules for querying BigQuery Property Graphs using GoogleSQL GQL and `GRAPH_TABLE`.

## When to Use This Skill

- Trigger this skill when writing **GQL queries** or integrating graph traversals into relational SQL.
- Use it to optimize slow queries, fix subquery compiler errors, or format output for visualization.

## Core Querying Standards

### 1. Basic Traversal & Subquery Rules
All GQL queries and subqueries must adhere to the syntactic standards and subquery scoping rules.
- For deep syntax details, path metadata functions, and subquery restrictions, refer to the [GQL Syntax Reference](file:///Users/antoniopaulino/dev/git/agy-plugins/gcp-data-eng/skills/property-graph-querying/references/gql-syntax.md).

### 2. Output Formats: Tabular vs. Visualization
- **Visualization (Network)**: Project graph elements inside the `TO_JSON()` function and enforce a `LIMIT 500` guardrail.
- **Tabular (Report)**: Return specific primitive properties (do not use `TO_JSON()`).

### 3. Relational Integration (`GRAPH_TABLE`)
To join graph traversals with standard SQL, wrap the GQL block inside `GRAPH_TABLE()` in the standard SQL `FROM` clause and declare output columns in the `COLUMNS` block:
```sql
SELECT owner_name, COUNT(acc_id) AS accounts
FROM GRAPH_TABLE(
  graph_db.FinGraph
  MATCH (p:Person)-[:Owns]->(a:Account)
  COLUMNS (p.name AS owner_name, a.id AS acc_id)
)
GROUP BY owner_name;
```

## Performance & Optimization Rules

1. **Filter Early**: Order path traversals to originate from the lowest cardinality nodes (e.g., matching a specific person ID first).
2. **Explicit Labels**: Always specify node and edge labels. Omitting them forces slow full scans over all underlying tables.
3. **Avoid Undirected Patterns**: BigQuery schemas are directional. If bidirectional matching is needed, use two unidirectional matches combined with `UNION ALL`.
4. **Mid-Path Sampling**: For deep or high fan-out queries, use `NEXT` chaining and intermediate window filters to sample paths mid-traversal.

## GQL Query Checklist

Run this safety check on every GQL query before execution:

```markdown
### GQL Query Safety Check
- [ ] **Graph Scope**: Graph name explicitly declared inside all subqueries?
- [ ] **Filter Placement**: Selective filters placed on the origin node of traversals?
- [ ] **Subquery Clause**: `FILTER` used instead of `WHERE` for `EXISTS` subqueries?
- [ ] **Pruning**: Variable-length hops prefixed with `ANY` / `ANY SHORTEST`?
- [ ] **Labels**: All nodes and edges declared with explicit labels (no open wildcards)?
```
