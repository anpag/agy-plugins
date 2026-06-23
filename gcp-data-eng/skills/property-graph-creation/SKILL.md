---
name: property-graph-creation
description: >
  Enforces BigQuery property graph schema creation, vertex/edge mapping, measures aggregation, and junction-table promotion.
  Use this skill whenever you are designing, creating, or refactoring BigQuery Property Graph schemas (DDL).
---

# BigQuery Property Graph Creation Guidelines

This skill defines the strict architectural standards and design patterns for creating and managing logical Property Graphs in BigQuery.

## When to Use This Skill

- Trigger this skill when writing **DDL schemas** for property graphs (`CREATE PROPERTY GRAPH`).
- Use it to resolve design issues with overcounting, many-to-many relationships, or `GRAPH_EXPAND` compatibility.

## Core Schema Design Workflows

### Step 1: Mapping Nodes & Edges (DDL)
1. **Keys**: Every node table must declare a primary key (`KEY`). Every edge table must declare `SOURCE KEY` and `DESTINATION KEY` referencing parent node tables.
2. **Properties**: List exposed columns inside the `PROPERTIES` clause.
   - Use `PROPERTIES ALL` or `PROPERTIES ALL EXCEPT` to streamline declarations.
3. **Labels**: By default, labels match the table name. Use the `LABEL` clause to assign custom synonyms (e.g., mapping edge table `PersonOwnAccount` to label `Owns`).

#### Financial Graph DDL Example:
```sql
CREATE OR REPLACE PROPERTY GRAPH graph_db.FinGraph
  NODE TABLES (
    graph_db.Account PROPERTIES (id, create_time, is_blocked, nick_name),
    graph_db.Person PROPERTIES (id, name, country, city)
  )
  EDGE TABLES (
    graph_db.PersonOwnAccount
      SOURCE KEY (id) REFERENCES Person (id)
      DESTINATION KEY (account_id) REFERENCES Account (id)
      PROPERTIES (create_time)
      LABEL Owns,
    graph_db.AccountTransferAccount
      SOURCE KEY (id) REFERENCES Account (id)
      DESTINATION KEY (to_id) REFERENCES Account (id)
      PROPERTIES (amount, create_time, order_number)
      LABEL Transfers
  );
```

### Step 2: Overcounting Safeguard (Measures)
When joining graph paths with standard SQL tables, duplicate paths lead to the **Fan-Out/Overcounting problem** (e.g., aggregating a department budget multiple times across courses).
- **Solution**: Define **Measures** (`MEASURE(AGG_FUNC(col)) AS alias`) in the node/edge tables. Measures lock aggregation to the node/edge's physical key, ensuring it is calculated exactly once regardless of path duplicates.
- **Querying Measures**: You cannot query measures in pure GQL. You **must** use the `GRAPH_EXPAND` TVF and wrap the measure column in the standard SQL `AGG()` function in the outer query.

### Step 3: Resolving Many-to-Many Relationships (M:N)
The `GRAPH_EXPAND` TVF requires a tree-like structure and fails on many-to-many edges.
- **Junction Table Promotion Pattern**:
  1. Promote the M:N junction table (e.g., `Enrollment`) to a **Node Table** (acting as the tree root).
  2. Define two **Many-to-One (N:1) Edge Tables** using the junction table as the source, referencing the dimension node tables.

## Property Graph Design Template

Include this schema checklist when designing a property graph:

```markdown
### Property Graph Schema Checklist
- [ ] **Vertex & Edge Keys**: Source/destination keys declared and referenced?
- [ ] **Measures (No Overcounting)**: Aggregates locked to physical keys using `MEASURE`?
- [ ] **M:N Promotion**: Junction tables promoted to node tables to prevent `GRAPH_EXPAND` errors?
- [ ] **Cache Protection**: Cache disabled (`use_query_cache = False`) for all `GRAPH_EXPAND` calls?
```
