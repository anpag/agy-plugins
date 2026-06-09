---
id: property-graph-querying
type: skill
description: Extremely dense and detailed guidelines for querying BigQuery Property Graphs using BigQuery GoogleSQL GQL, including pattern matching, subqueries, and advanced optimization techniques.
requires: []
suggests: []
---

# BigQuery Property Graph Querying Guidelines

These guidelines govern the query construction, syntax standards, and optimization practices for executing Graph Query Language (GQL) or SQL/PGQ queries against a BigQuery Property Graph. This includes multi-hop traversal, path finding, shortest path queries, subquery correlation, and performance tuning.

---

## 1. Pre-generation Checklist

Before writing or generating any BigQuery Graph query, you must complete this checklist:

1. **Verify Language Standard**: Use **ONLY the BigQuery GoogleSQL GQL standard**, which implements the ISO GQL standard. 
   > [!IMPORTANT]
   > **NEVER generate Cypher queries.** BigQuery GQL syntax differs from Cypher in key keywords, subqueries, horizontal aggregations, and standard functions.
2. **Identify Output Intent**:
   - **Graph Network Visualization**: The client wants to render nodes/edges in a visual graph UI. This requires mapping the full graph path or elements to JSON using `TO_JSON()`.
   - **Tabular Data / Charts**: The client wants standard row/column tables or aggregates. This requires returning specific primitive properties without `TO_JSON()`.

---

## 2. Core Syntactic Directives

When writing queries, adhere to these global rules:

1. **Default Query Construction (Standalone GQL)**:
   - Prefer standalone GQL statements starting with the `GRAPH` keyword when only graph traversing and projecting are needed.
   - Use `GRAPH_TABLE()` only when the graph needs to be joined with standard relational tables, grouped using standard SQL, or processed with advanced analytical window functions.
2. **Escaping Reserved Keywords**:
   - You **MUST** escape GQL and SQL reserved keywords with backticks (`` ` ``) if they are used as identifiers (e.g., column names, labels, variable names). Common keywords to watch for: `` `order` ``, `` `begin` ``, `` `path` ``, `` `type` ``.
3. **Result Uniqueness**:
   - Apply `DISTINCT` in the `RETURN` or `COLUMNS` clause if the user request implies extracting unique entities, avoiding duplicate matching rows.
4. **Path Assignment**:
   - For path-finding, reachability, or traversal analytics, bind the pattern to a path variable: `MATCH p = (src)-[e]->(dst)`.

---

## 3. Basic GQL Query Construction & Chaining

A linear GQL query statement executes its clauses sequentially. The output of each clause serves as the "working table" for the next.

### Key Linear Statements
- `MATCH`: Defines the topological graph pattern to search for.
- `WITH`: Projects and filters variables from the current scope into the next scope. Optionally includes `ORDER BY`, `LIMIT`, and `OFFSET`.
- `LET`: Defines a new read-only scalar variable or alias within the query scope.
- `FILTER`: Evaluates search filters on graph elements. (Highly preferred over `WHERE` for complex structures).
- `RETURN`: Terminates the query and projects final outputs.

### Chaining Statements with `NEXT`
You can chain multiple linear statements together using the `NEXT` keyword. The results of the first block are passed as inputs to the next.

```sql
GRAPH graph_db.FinGraph
MATCH (src:Person {name: "Dana"})-[own:Owns]->(account:Account)
RETURN account.id AS source_account_id
NEXT
MATCH (a:Account)-[t:Transfers]->(b:Account)
FILTER a.id = source_account_id
RETURN a.id AS source, b.id AS destination, t.amount AS amount
```

---

## 4. Graph Pattern Matching

### Node Patterns
Node patterns are enclosed in parentheses `()`.
- `MATCH (n)`: Matches any node and binds it to `n`.
- `MATCH (p:Person)`: Matches nodes labeled `:Person`.
- `MATCH (p:Person|Account)`: Matches nodes labeled either `:Person` **OR** `:Account`.
- `MATCH (p:Person {id: 1001})`: Matches nodes with property `id = 1001` (inline property filter).
- `MATCH (p:Person WHERE p.age > 21)`: Matches nodes using a conditional filter.

### Edge Patterns
Edge patterns are enclosed in brackets `[]` and specify relationships.
- `(a)-[e]->(b)`: Matches a directed edge from `a` to `b`.
- `(a)-[e:Transfers]->(b)`: Matches a directed edge specifically labeled `:Transfers`.
- `(a)-[e:Transfers {amount: 5000}]->(b)`: Matches with inline property constraints.
- `(a)-[e:Transfers]-(b)`: Matches an undirected edge. (Avoid where possible; see optimizations).

### Pattern Joins and Commas
Separate multiple patterns with a comma to join topologies.
- If patterns **do not** share variables, they result in a **cross-product** (join).
- If patterns **share** a variable, they result in an **equijoin** on that element.

```sql
-- Equijoin matching accounts that share a person owner
GRAPH graph_db.FinGraph
MATCH (a1:Account)<-[:Owns]-(owner:Person),
      (owner)-[:Owns]->(a2:Account)
FILTER a1.id != a2.id
RETURN a1.id AS acc_1, a2.id AS acc_2, owner.name AS common_owner
```

### Quantifiers and Group Variables
To find variable-length multi-hop paths, append a quantifier `{m, n}` to the edge pattern.
- `{1, 5}`: Between 1 and 5 hops.
- `{3}`: Exactly 3 hops.
- `{1,}`: 1 or more hops.

#### Group Variables Rule
When an edge is quantified (e.g., `-[e:Transfers]->{1,3}`), the variable `e` becomes a **Group Variable** (an array of edges). You cannot extract properties from `e` directly (e.g., `e.amount` throws an error). Instead, you must use array operations or horizontal aggregations:
- `ARRAY_LENGTH(e)`: Finds the exact number of hops in the path.
- `SUM(e.amount)` (GQL horizontal aggregate): Computes the aggregate sum of a property across all matched edges in that path segment.

```sql
GRAPH graph_db.FinGraph
MATCH (a:Account)-[t:Transfers]->{1,3}(b:Account)
RETURN a.id AS src, b.id AS dst, SUM(t.amount) AS total_transfer_volume
```

---

## 5. Path Search Prefixes

Variable-length paths can lead to combinatorial explosion. Use search prefixes before the path pattern to enforce constraints:

- `ANY`: Returns exactly one arbitrary path for each unique source and destination pair.
- `ANY SHORTEST`: Returns a single path with the minimum number of edge hops between each pair.
- `ANY CHEAPEST`: Returns a single path with the minimum total cost, aggregating the custom `COST` expression defined on the edges.

```sql
GRAPH graph_db.FinGraph
MATCH ANY SHORTEST
  (src:Account {id: 10})-[transfers:Transfers]->{1,5}(dst:Account {id: 20})
RETURN PATH_LENGTH(transfers) AS hops
```

---

## 6. GQL Functions & Traversal Operators

Use these native GQL functions to extract path properties and analyze topology:

### Path Metadata Extraction
- `PATH_FIRST(p)`: Returns the start node of path `p`.
- `PATH_LAST(p)`: Returns the end node of path `p`.
- `PATH_LENGTH(p)`: Returns the `INT64` count of edge hops in path `p`.
- `NODES(p)`: Returns an ordered array of all node elements in path `p`.
- `EDGES(p)`: Returns an ordered array of all edge elements in path `p`.

### Element Inspection
- `ELEMENT_ID(x)`: Returns the unique internal identifier for node/edge `x`.
- `LABELS(x)`: Returns an array of string labels bound to node/edge `x`.
- `SOURCE_NODE_ID(e)`: Returns the internal ID of edge `e`'s source node.
- `DESTINATION_NODE_ID(e)`: Returns the internal ID of edge `e`'s destination node.

---

## 7. Output Formatting: Visualization vs. Tabular

### Visualization Format (`TO_JSON`)
When the user wants to "visualize", "view network", or "see connections", you **must** project variables inside `TO_JSON()`. Graph engines require JSON payloads of nodes/edges to construct visual topologies.
- Enforce `LIMIT 500` by default to prevent UI crashes unless requested otherwise.

```sql
GRAPH graph_db.FinGraph
MATCH p = (src:Person)-[e:Owns]->(dst:Account)
RETURN TO_JSON(src) AS source_node, TO_JSON(e) AS edge, TO_JSON(dst) AS target_node
LIMIT 500
```

### Tabular Format
When the user wants to "list", "count", "calculate", or view details in a standard table or chart, return specific primitive properties. Do **NOT** use `TO_JSON()`.

```sql
GRAPH graph_db.FinGraph
MATCH (src:Person)-[e:Owns]->(dst:Account)
RETURN src.name AS owner, dst.id AS account_id, dst.nick_name AS account_name
```

---

## 8. Relational SQL Integration (`GRAPH_TABLE`)

To combine graph pattern matching with standard SQL aggregates, window functions, and physical relational tables, use the `GRAPH_TABLE()` table-valued function.

### Basic Syntax
`GRAPH_TABLE` acts as a standard SQL source in the `FROM` clause. You must define a `COLUMNS` clause to specify the relational output schema.

```sql
SELECT
  owner_name,
  COUNT(DISTINCT acc_id) AS owned_accounts,
  SUM(balance) AS total_balance
FROM GRAPH_TABLE(
  graph_db.FinGraph
  MATCH (p:Person)-[:Owns]->(a:Account)
  COLUMNS (p.name AS owner_name, a.id AS acc_id, a.balance AS balance)
)
GROUP BY owner_name
ORDER BY total_balance DESC;
```

### Outer Variable Correlation (Parameterized `GRAPH_TABLE`)
To filter a `GRAPH_TABLE` query using variables from a relational table earlier in the standard SQL `FROM` clause, refer to the outer columns directly inside the `MATCH` pattern:

```sql
SELECT
  rel.customer_id,
  g.hop_count
FROM relational_db.Watchlist AS rel
JOIN GRAPH_TABLE(
  graph_db.FinGraph
  -- Enforce connection to outer table column: rel.customer_id
  MATCH p = (src:Person {id: rel.customer_id})-[:Transfers]->{1,3}(dst:Person)
  COLUMNS (PATH_LENGTH(p) AS hop_count)
) AS g ON TRUE;
```

---

## 9. Subquery Limitations and Syntax Quirks

Subqueries in GQL are enclosed in braces `{}`. BigQuery Graph imposes several critical constraints on subqueries that you **must** strictly enforce to avoid compiler errors:

### 1. Mandatory Graph Name Rule
Unlike standard SQL subqueries which inherit the scope, any GQL subquery (such as those inside `EXISTS {}` or `ARRAY {}`) **MUST explicitly re-declare the graph name** inside the subquery block.

```sql
-- CORRECT
GRAPH graph_db.FinGraph
MATCH (a:Account)
FILTER EXISTS {
  GRAPH graph_db.FinGraph -- Syntactically mandatory
  MATCH (a)-[:Transfers]->(b:Account)
  FILTER b.is_blocked = true
  RETURN 1
}
RETURN a.id
```

### 2. The `WHERE` vs. `FILTER` Rule
Certain types of GQL subqueries cannot be evaluated inside a `WHERE` clause because the optimizer cannot decorrelate them for join predicates.
- Subqueries of type `EXISTS`, `IN`, `LIKE`, and `LIKE ANY/SOME/ALL` **MUST** use the GQL `FILTER` clause. They will throw compiling errors if written inside a `WHERE` clause.

```sql
-- INCORRECT (Throws Compiler Error)
GRAPH graph_db.FinGraph
MATCH (p:Person)
WHERE EXISTS { ... }

-- CORRECT (Compiles Successfully)
GRAPH graph_db.FinGraph
MATCH (p:Person)
FILTER EXISTS {
  GRAPH graph_db.FinGraph
  ...
}
```

### 3. Correlation Limits inside `VALUE` Subqueries
Scalar-valued subqueries (`VALUE {}`) cannot reference correlated variables defined in the outer GQL block. If correlation is required, rewrite the query to use `MATCH` pattern joins or `NEXT` chaining instead.

---

## 10. Query Optimization & Performance Tuning

To ensure sub-second latency over large-scale graphs, enforce these optimization principles:

### 1. Filter Early and Start from Low-Cardinality Nodes
Always order your path traversals to originate from the lowest cardinality nodes (e.g., matching a single person by ID rather than scanning all active accounts). Push selective filters into the first `MATCH` pattern or immediate `FILTER` clause.

```sql
-- OPTIMIZED: Starts search exclusively at Person 55
GRAPH graph_db.FinGraph
MATCH p = (src:Person {id: 55})-[:Transfers]->{1,3}(dst:Person)
RETURN p
```

### 2. Specify Node and Edge Labels Explicitly
Always include explicit label filters (e.g., `(a:Account)-[e:Transfers]->(b:Account)`). 
If labels are omitted (e.g., `(a)-[e]->(b)`), the query engine is forced to perform expensive full scans over every underlying node and edge table defined in the property graph schema.

### 3. Avoid Undirected / Bi-directional Patterns
Do not use undirected patterns (e.g., `(a)-[e:Transfers]-(b)`). BigQuery physical schemas are directional; undirected matching incurs a massive performance penalty.
- If bidirectional searching is required, use explicit unidirectional matches combined with `UNION ALL`:

```sql
-- OPTIMIZED BIDIRECTIONAL SEARCH
GRAPH graph_db.FinGraph
MATCH (a:Account {id: 10})-[t:Transfers]->(b:Account)
RETURN b.id AS connected_id
UNION ALL
GRAPH graph_db.FinGraph
MATCH (a:Account {id: 10})<-[t:Transfers]-(b:Account)
RETURN b.id AS connected_id
```

### 4. Prefer Single MATCH over Chained MATCH Statements
A single comprehensive `MATCH` statement (e.g., `MATCH (a)-[]->(b)-[]->(c)`) gives the global query optimizer a complete view of the graph pattern. Chaining multiple matches with `NEXT` or `WITH` limits the optimizer's ability to reorder joins and tune scans. Use `NEXT` only when explicit filtering, grouping, or mid-path sampling is required.

### 5. Advanced Mid-Path Sampling (Multi-hop Optimization)
For very deep or highly connected graphs (high fan-out), you can prevent exponential path combinations by using standard window functions like `ROW_NUMBER()` to sample intermediate paths. 
- Break the traversal into multiple `MATCH` blocks separated by `NEXT`.
- Apply a `FILTER ROW_NUMBER() OVER (PARTITION BY ELEMENT_ID(source))` at the midpoint to prune the search space before executing the next hops.

```sql
-- OPTIMIZED MULTI-HOP WITH INTERMEDIATE SAMPLING
GRAPH graph_db.FinGraph
MATCH (a1:Account {id: 7})-[e1:Transfers]->(a2:Account)
-- Sample and keep at most 5 outgoing transfer paths per starting account (a1)
FILTER ROW_NUMBER() OVER (PARTITION BY ELEMENT_ID(a1)) <= 5
RETURN a1, a2
NEXT
MATCH (a2)-[e2:Transfers]->(a3:Account)
RETURN a1.id AS source, a2.id AS mid_point, a3.id AS destination
```
This reduces the computational complexity of the second hop from millions of paths to a controlled, predictable subset.
