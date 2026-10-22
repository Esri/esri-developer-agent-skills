# Item Dependency Graphs

Use [`arcgis.apps.itemgraph`](https://developers.arcgis.com/python/latest/api-reference/arcgis.apps.itemgraph.html) to discover and inspect item dependencies before cloning, migration, overwrite or deletion.

## Documentation by task

| Task | Documentation |
| --- | --- |
| Build and inspect a dependency graph, understand dependency direction, or repair references | [Working with Item Dependencies and Data Sources](https://developers.arcgis.com/python/latest/guide/itemgraph-and-remap-data/) |
| Discover organization-wide dependents and save, reload or maintain a graph | [Working with an Organization-Wide Dependency Graph (sample)](https://developers.arcgis.com/python/latest/samples/org-wide-dependency-graph/) |
| Visualize dependencies in ArcGIS Knowledge on a Knowledge-enabled Enterprise destination | [Visualizing an ItemGraph with ArcGIS Knowledge](https://developers.arcgis.com/python/latest/guide/itemgraph-to-knowledge-graph/) |

For copying content after reviewing its dependencies, see [Cloning](./cloning.md).

## Important limits

- `contained_by()` and `required_by()` report dependents already indexed in the graph, not every possible dependent in the organization. See the organization-wide sample for broader coverage.
- A node without an associated `Item` is not automatically a deleted item: it may represent a service URL, an inaccessible or external item, or a saved graph loaded without retrieving items.
