# Reference: BigQuery GQL Syntax & Subquery Rules

This reference contains the syntax specifications, subquery limitations, and GQL features supported by BigQuery Property Graph querying.

## 1. Basic Traversal Syntax
- Nodes: `(var:Label)`
- Directed Edges: `-[var:Label]->`
- Path Variables: `p = (src)-[e]->(dst)`

## 2. Variable-Length Traversal
For traversing multiple hops (e.g., finding transfers up to 3 hops away):
- Syntax: `-[e:Label]->{min_hops, max_hops}`
- Pruning: Always specify search prefixes (`ANY`, `ANY SHORTEST`, `ANY CHEAPEST`) before the `MATCH` keyword to prevent combinatorial path explosion.

## 3. GQL Subquery Constraints (Crucial)
BigQuery Graph enforces strict compiler rules on GQL subqueries (e.g., inside `EXISTS {}`):
- **Graph Name Rule**: Every GQL subquery **MUST** explicitly re-declare the `GRAPH <graph_name>` name inside the subquery braces `{}`.
- **WHERE vs. FILTER Rule**: Subqueries of type `EXISTS`, `IN`, `LIKE`, etc., **MUST** use GQL's `FILTER` clause. They will throw compiler errors if placed inside a `WHERE` clause.

## 4. GQL Functions & Traversal Operators
- `PATH_FIRST(p)`: Returns the start node of path `p`.
- `PATH_LAST(p)`: Returns the end node of path `p`.
- `PATH_LENGTH(p)`: Returns the `INT64` count of edge hops in path `p`.
- `NODES(p)`: Returns an ordered array of all node elements in path `p`.
- `EDGES(p)`: Returns an ordered array of all edge elements in path `p`.
