---
name: ontology-design
description: >
  Enforces semantic modeling, Knowledge Graph ontology design, W3C standards (OWL, RDF, SKOS), and entity resolution.
  Use this skill whenever you are designing taxonomies, modeling semantic relationships, or structuring ontologies.
---

# Knowledge Graph Ontology Design & Semantic Modeling Guidelines

This skill defines the standards for designing semantic models, taxonomies, and ontologies, and translating them into physical, queryable graph schemas in BigQuery.

## When to Use This Skill

- Trigger this skill when **designing node-edge schemas** for Knowledge Graphs.
- Use it when modeling semantic relationships, organizing taxonomies, or extracting entity relationships from unstructured text.

## Core Semantic Modeling Principles

### 1. Intrinsic Attributes vs. Relational Edges
- **Intrinsic Attributes (Nodes)**: Properties that describe the node itself and are independent of other nodes (e.g., `Person.birth_date`, `Product.price`).
- **Relational Edges (Connections)**: Properties that only exist because of a connection between two nodes (e.g., `Transfers.amount` between two Accounts, `EmployedBy.start_date` between a Person and a Company).
- **Rule**: Never store a relational attribute on a node, and never store a node property on an edge.

### 2. Taxonomies vs. Ontologies
- **Taxonomies (SKOS)**: Hierarchical classification systems (e.g., product categories, organizational charts). Use `skos:Concept` and relations like `broader`, `narrower`, and `related` to model them.
- **Ontologies (OWL)**: Rich, multi-dimensional semantic networks defining classes, properties, and constraints (e.g., "A Person *owns* an Account, which is a *subclass* of FinancialAsset").

---

## Mapping Ontologies to BigQuery GQL

To map a logical W3C ontology (classes and properties) into a physical BigQuery Property Graph, follow this mapping pattern:

| Semantic Concept | BigQuery Physical Map | Example |
| :--- | :--- | :--- |
| **Ontology Class** | Node Table | `university.Student`, `university.Course` |
| **Object Property (Relation)** | Edge Table | `university.Enrollment` (Student -> Course) |
| **Data Property (Attribute)** | Column on Node/Edge | `Student.name`, `Enrollment.grade` |
| **Taxonomy / Hierarchy** | Self-Referential Edge | `Department` `reports_to` `Department` |

---

## Entity Resolution & Consolidation (Canonical Mapping)

Unstructured extraction often produces variant names for the same real-world entity (e.g., "Google LLC", "Google Inc.", "Google").
- **Canonical Node Pattern**:
  - Store only the unique, normalized entity in the main **Canonical Node Table** (e.g., `id: 101`, `name: "Google LLC"`).
  - Maintain a **Synonym Mapping Table** (e.g., `variant: "Google" -> canonical_id: 101`).
  - During ETL/ingestion, resolve all raw mentions against the mapping table before creating edges to guarantee graph density and prevent duplicate node bloat.

## Ontology Design Checklist

Use this checklist during the design phase of a knowledge graph:

```markdown
### Ontology & Graph Model Audit
- [ ] **Separation of Concerns**: Node properties separated from relationship attributes?
- [ ] **Synonym Resolution**: Entity resolution mapping table defined to prevent duplicate nodes?
- [ ] **Taxonomy Standard**: Hierarchies modeled using self-referential edges or SKOS concepts?
- [ ] **GQL Mapping**: Every class mapped to a Node Table, and property to an Edge Table?
```
