---
id: property-graph-creation
type: skill
description: Extremely dense and detailed guidelines for BigQuery Property Graph creation, including DDL syntax, schema design, constraints, and measures.
requires: []
suggests: []
---

# BigQuery Property Graph Creation Guidelines

These guidelines govern the creation, schema design, and DDL syntax of BigQuery Property Graphs. BigQuery Property Graphs model relational tables as logical property graphs, allowing rich topological queries while storing and managing data natively in standard tables.

---

## 1. Conceptual Foundation of the BigQuery Property Graph Model

A BigQuery Property Graph is a **logical view** over existing relational tables. Creating a graph does not copy, move, or duplicate any physical data. The graph acts as a metadata abstraction layer.

- **Vertices (Nodes)**: Entities in the graph (e.g., `Person`, `Account`, `College`). They are defined by **Vertex Tables**.
- **Edges (Relationships)**: Connections between vertices (e.g., `Transfers`, `Owns`, `EnrolledIn`). They are defined by **Edge Tables**.
- **Labels**: Categorizations for nodes and edges (e.g., `:Person`, `:Transfers`). Elements can have multiple labels, though they typically have one.
- **Properties**: Key-value attributes associated with nodes or edges, mapped directly from columns of the underlying relational tables.
- **Directionality**: All edge definitions in BigQuery are inherently directed from a **Source** vertex to a **Destination** vertex, although queries can traverse them in either direction.

---

## 2. Table Schema Design and Constraints

Before you can define a property graph, the underlying tables must be correctly configured. The relational schemas must explicitly define primary and foreign keys, as BigQuery uses these keys to establish the graph's topology.

### Primary Key Constraints (Nodes)
Every vertex (node) table **MUST** have a primary key that uniquely identifies each vertex.
- BigQuery does not enforce primary key constraints during data ingestion. However, they are **syntactically mandatory** for creating property graphs.
- They must be declared using the `PRIMARY KEY (column) NOT ENFORCED` syntax.

```sql
CREATE OR REPLACE TABLE university.College (
  college_id INT64,
  college_name STRING,
  PRIMARY KEY (college_id) NOT ENFORCED
);
```

### Foreign Key Constraints (Edges)
Every edge table represents a relationship between a source vertex table and a destination vertex table. To enable this mapping:
- The edge table must have columns that act as foreign keys pointing to the primary keys of the respective vertex tables.
- While not strictly required to be declared as foreign keys at the table DDL level, declaring them using `FOREIGN KEY (col) REFERENCES vertex_table (key) NOT ENFORCED` is highly recommended for documentation, validation, and optimization.

```sql
CREATE OR REPLACE TABLE university.Department (
  dept_id INT64,
  dept_name STRING,
  college_id INT64,
  budget FLOAT64,
  PRIMARY KEY (dept_id) NOT ENFORCED,
  FOREIGN KEY (college_id) REFERENCES university.College(college_id) NOT ENFORCED
);
```

---

## 3. The CREATE PROPERTY GRAPH DDL Statement

The `CREATE PROPERTY GRAPH` statement defines the logical property graph schema.

### Complete DDL Syntax Template

```sql
CREATE OR REPLACE PROPERTY GRAPH [project_id.]dataset_name.graph_name
  NODE TABLES (
    [project_id.]dataset_name.table_name [AS label_alias]
      [KEY (column_list)]
      [PROPERTIES (column_list) | PROPERTIES EXCEPT (column_list)]
      [LABEL label_name],
    ...
  )
  EDGE TABLES (
    [project_id.]dataset_name.table_name [AS label_alias]
      [KEY (column_list)]
      SOURCE KEY (source_column_list) REFERENCES vertex_table [(vertex_primary_key_list)]
      DESTINATION KEY (dest_column_list) REFERENCES vertex_table [(vertex_primary_key_list)]
      [PROPERTIES (column_list) | PROPERTIES EXCEPT (column_list)]
      [LABEL label_name],
    ...
  );
```

### Core Syntactic Rules

1. **Table Aliasing (`AS`)**:
   - If a table name is used multiple times (e.g., a self-referencing relationship), you must use the `AS` keyword to provide unique aliases.
2. **Key Specifications**:
   - If the `KEY` clause is omitted for a Node or Edge table, BigQuery infers the key from the underlying physical table's primary key constraint.
3. **Properties Mappings**:
   - **All Properties (Default)**: Omit the `PROPERTIES` clause entirely. All columns from the table become properties on the graph element.
   - **Filtered Properties (`PROPERTIES (...)`)**: List only the columns that should be exposed. Recommended to prevent exposing internal system columns or raw keys.
   - **Excluded Properties (`PROPERTIES EXCEPT (...)`)**: Expose all columns except the specified subset.
4. **Labels**:
   - Omit the `LABEL` clause to let BigQuery infer the label name. The inferred label is the base table name (case-sensitive).
   - Use `LABEL label_name` to define a custom label (e.g., mapping table `PersonOwnAccount` to label `Owns`).

### DDL Example: Financial Graph

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

---

## 4. Customizing Property Options (Metadata & Synonyms)

You can enrich properties with descriptions and synonyms using the `OPTIONS` block. This is highly valuable for self-documenting schemas and integrating with natural language search engines (such as conversational analytics).

- **`description`**: A string description of the property.
- **`synonyms`**: An array of string aliases or alternate terms that refer to this property.

```sql
CREATE OR REPLACE PROPERTY GRAPH university.SchoolGraph
  NODE TABLES (
    university.Department
      KEY (dept_id)
      PROPERTIES (
        dept_id,
        dept_name OPTIONS (synonyms=["department name", "division"]),
        budget OPTIONS (description="The annual operational budget in USD")
      )
  );
```

---

## 5. Measures (Advanced Multi-Dimensional Aggregation)

### The Overcounting/Fan-Out Problem
When joining graph elements with standard SQL tables, data is repeated across one-to-many paths. 
For instance, joining `College -> Department -> Course` results in a Department with 5 courses appearing 5 times in the flattened output. If you perform `SUM(Department.budget)` on the flattened set, the budget is multiplied by 5, leading to incorrect calculations.

### Measures as a Solution
A **Measure** is a pre-aggregated column defined inside the graph schema using the `MEASURE()` keyword wrapping an aggregate function (e.g., `SUM`, `AVG`, `COUNT`, `MAX`, `MIN`).
- Measures lock the aggregate calculation to the node or edge's physical key (e.g., `dept_id` for Department).
- Aggregations are calculated **exactly once** per key, ensuring mathematically sound results and preventing overcounting, regardless of subsequent graph flattening operations.

### Declaring Measures in DDL
Measures are declared inside the `PROPERTIES` list of `NODE TABLES` or `EDGE TABLES` and **must** be assigned an alias.

```sql
CREATE OR REPLACE PROPERTY GRAPH university.SchoolGraph
  NODE TABLES (
    university.College KEY (college_id),
    university.Department
      KEY (dept_id)
      PROPERTIES (
        dept_id, dept_name, budget,
        MEASURE(SUM(budget)) AS total_budget
      ),
    university.Course
      KEY (course_id)
      PROPERTIES (
        course_id, course_name, credits,
        MEASURE(AVG(credits)) AS avg_credits,
        MEASURE(COUNT(course_id)) AS course_count
      )
  )
  EDGE TABLES (
    university.Department AS CollegeDept
      SOURCE KEY (college_id) REFERENCES College (college_id)
      DESTINATION KEY (dept_id) REFERENCES Department (dept_id),
    university.Course AS DeptCourse
      SOURCE KEY (dept_id) REFERENCES Department (dept_id)
      DESTINATION KEY (course_id) REFERENCES Course (course_id)
  );
```

### Querying Measures with `GRAPH_EXPAND`
You cannot directly reference measure properties in pure GQL queries. Instead, you must query them using the `GRAPH_EXPAND` Table-Valued Function (TVF) and standard SQL.

1. **`GRAPH_EXPAND("<project>.<dataset>.<graph_name>")`**:
   - Flattens the graph into a single tabular output.
   - Column names are auto-generated by concatenating the label and the property name: `[Label]_[Property]` (e.g., `Department_total_budget`, `Course_course_count`).
2. **`AGG()` Aggregate Function**:
   - To retrieve measure columns from `GRAPH_EXPAND`, you **MUST** wrap them in the standard SQL `AGG()` function in the `SELECT` list.
   - `AGG` tells BigQuery to apply the pre-defined measure aggregation rules to the flattened data stream exactly once per key.

```sql
SELECT
  College_college_name,
  AGG(Department_total_budget) AS college_budget,
  AGG(Course_course_count) AS total_courses
FROM
  GRAPH_EXPAND("university.SchoolGraph")
GROUP BY
  College_college_name;
```

> [!CAUTION]
> **Disable Query Cache for GRAPH_EXPAND**: 
> Changes to underlying graph tables do not automatically invalidate the query cache for TVF calls like `GRAPH_EXPAND`. To guarantee data correctness, disable cached results when running these queries (e.g., in Python client options or by setting `use_query_cache = False`).

---

## 6. Modeling Many-to-Many (M:N) Relationships for Measures

### The Ambiguity Limitation
If you have a many-to-many relationship (e.g., `Student <-> Enrollment <-> Course`), modeling the junction table `Enrollment` as a simple edge table connecting `Student` and `Course` makes the schema ambiguous for flattening. 
The `GRAPH_EXPAND` function requires a strict, tree-like structure with a single root. When faced with an M:N edge table, `GRAPH_EXPAND` ignores the edge as ambiguous, and the query fails.

### The Junction Table Promotion Pattern
To model M:N relationships so they work with measures and `GRAPH_EXPAND`, follow this design pattern:

1. **Promote the junction table to a Node Table**:
   - This junction node table acts as the single root node table in the hierarchy (in-degree of zero).
2. **Define two Many-to-One (N:1) Edge Tables**:
   - Define both edge tables using the junction table as the physical source.
   - Set the source key of both edges to the junction table's primary key.
   - Set the destination keys to reference the dimension tables (`Student` and `Course`).

```sql
CREATE OR REPLACE PROPERTY GRAPH university.SchoolGraph
  NODE TABLES (
    university.Student KEY (student_id),
    university.Course KEY (course_id),
    -- Promote junction table to a Node Table (acting as the single root node)
    university.Enrollment KEY (enrollment_id)
  )
  EDGE TABLES (
    -- Shared physical table Enrollment mapped to two N:1 outgoing edge tables
    university.Enrollment AS EnrollmentToStudent
      SOURCE KEY (enrollment_id) REFERENCES Enrollment (enrollment_id)
      DESTINATION KEY (student_id) REFERENCES Student (student_id),
    university.Enrollment AS EnrollmentToCourse
      SOURCE KEY (enrollment_id) REFERENCES Enrollment (enrollment_id)
      DESTINATION KEY (course_id) REFERENCES Course (course_id)
  );
```

This structural pattern allows `GRAPH_EXPAND` to traverse cleanly from `Enrollment` outwards to both dimension tables, enabling valid SQL aggregations on measures.

---

## 7. Schema Management and Troubleshooting

### Inspecting Graph Schemas
To inspect the column schemas returned by `GRAPH_EXPAND` (including data types, modes, aliases, synonyms, and whether a property is a measure), use the `BQ.SHOW_GRAPH_EXPAND_SCHEMA` system procedure.

```sql
DECLARE schema_output STRING DEFAULT '';
CALL BQ.SHOW_GRAPH_EXPAND_SCHEMA('university.SchoolGraph', schema_output);
SELECT schema_output;
```

### Deleting Graphs
To delete a property graph, use the `DROP PROPERTY GRAPH` statement. This drops the logical graph definition but has **no effect** on the underlying node and edge tables.

```sql
DROP PROPERTY GRAPH university.SchoolGraph;
```

> [!WARNING]
> **Dependent Schema Integrity Warning**:
> BigQuery does not prevent you from deleting or modifying the schemas of physical tables that a logical property graph depends on. Altering or deleting a node or edge table without updating your graph schema will immediately invalidate the graph, causing all subsequent GQL and `GRAPH_EXPAND` queries to fail with severe compilation errors.
