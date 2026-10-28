# Item Dependency Graphs

Use [`arcgis.apps.itemgraph`](https://developers.arcgis.com/python/latest/api-reference/arcgis.apps.itemgraph.html) to discover and inspect dependencies between portal items, and between portal items and ArcGIS Services. Useful before cloning, migration, overwrite, and deletion workflows, and for gathering metadata about an organization's content.

## Documentation by task

| Task | Documentation |
| --- | --- |
| Build and inspect a dependency graph, understand dependency direction, or repair references | [Working with Item Dependencies and Data Sources](https://developers.arcgis.com/python/latest/guide/itemgraph-and-remap-data/) |
| Discover organization-wide dependents and save, reload or maintain a graph | [Working with an Organization-Wide Dependency Graph (sample)](https://developers.arcgis.com/python/latest/samples/org-wide-dependency-graph/) |
| Visualize dependencies in ArcGIS Knowledge on a Knowledge-enabled Enterprise destination | [Visualizing an ItemGraph with ArcGIS Knowledge](https://developers.arcgis.com/python/latest/guide/itemgraph-to-knowledge-graph/) |

For copying content after reviewing its dependencies, see [Cloning](./cloning.md).

## Important limits

- `contained_by()` and `required_by()` report dependents already indexed in the graph, not every possible dependent in the organization. See the organization-wide sample for broader coverage.
- When maintaining a saved graph, load it with `load_from_file(..., retrieve_items=True)` so the API retrieves and validates its items and services. retrieve_items=False is meant for use cases where relationships need to be inspected offline, or if Item/Service validation is not required and retrieving items would cost significant time.
- A node without an associated `Item` is not automatically a deleted item: it may represent an inaccessible or external item, a service URL that failed validation, or another unknown reference. Confirm the node's expected type, the maintenance identity's access, and whether retrieval failures were transient before removing it.

## Usage Tips and Tricks

- The best and most complete way to discover item dependencies is to use the arcgis.apps.itemgraph create_dependency_graph() method, which accepts a list of items and recursively searches for all items referenced by those items, then searching those items, and so on. It performs regex search on the data structure and resource files of those items, specific json dissection on some item types, and also queries the related_items endpoints for each item to capture all relationships defined there. It creates an ItemGraph object filled with ItemNode objects.

- Setting include_services = True on create_dependency_graph() will also include service URL’s referenced in item structures, allowing for the discovery of services that may not be persisted as portal items. The function performs validation on these URL’s to ensure they are valid services. The ItemGraph will categorize each ItemNode as one referring to a portal item, a service, or an unknown type (where validation for either type failed). This designation can be found under the ItemNode.type property.

- If using with an ArcGIS Online organization, including parameter include_reverse=True in create_dependency_graph() will include the reverse dependencies for feature layers, web maps, story maps, experiences, and other common use items, to the same extent that the online GUI will. Allows users to easily view reverse dependencies; e.g., show me everything that directly references my feature layer, and show me everything that depends on it. Total reverse dependencies for any item can be found by indexing all items that may potentially reference it or any of its ancestors (since the default mode of discovery is top-down).

- If using ArcGIS Enterprise, including parameter include_reverse in create_dependency_graph() will capture reverse relationships available in the related_items endpoint, capturing reverse dependencies only in item types that manage those dependencies, such as Survey123 Forms and Hub Sites. Total reverse dependencies for any item can be found by indexing all items that may potentially reference it or any of its ancestors (since the default mode of discovery is top-down).

- An ItemGraph from any source organization can be visually inspected if a user has access to an ArcGIS Enterprise with ArcGIS Knowledge enabled. Calling ItemGraph.to_knowledge_graph() will create an ArcGIS Knowledge Graph containing the contents of the ItemGraph. Specific metadata can be included for items (import enum type called GraphItemProperty from module to see all options), and both items and services can have their types represented as individual entity types, or generic types for portal items and services can be made. The ItemGraph does not have to be from the same organization that has Knowledge enabled, so graphs generated from ArcGIS Online can be visualized as well.

- A helpful “quick” version of create_dependency_graph() exists on the Item type: get_dependencies(). This function internally creates an ItemGraph where the root node was just the given Item, allowing a user to view the items that the Item directly references or requires some way down the chain.

- For any given ItemNode in a graph, there exists functions to view the items within the graph it directly references (ItemNode.contains()), any items it requires to exist (ItemNode.requires(), which captures all chained contains() relationships), the items that directly reference it (ItemNode.contained_by()), and the items that require it to exist (ItemNode.required_by(), which captures chained contained_by() relationships).

- The ItemGraph is built on top of NetworkX’s DiGraph class, giving access to all functionality in there.

- An ItemGraph can be persisted to disk using the ItemGraph.write_to_file() function, which creates a GML file. The ItemGraph can then be loaded back in using the arcgis.apps.itemgraph load_from_file() function. For graph maintenance, use `retrieve_items=True`: retrieval validates whether each saved item or service still exists and identifies nodes with no retrievable object as removal candidates. Use `retrieve_items=False` only for quick structural analysis where existence validation is not required.

- The ItemGraph has async capability, which can be controlled with the “run_async” parameter in create_dependency_graph() and load_from_file(). Additionally, create_dependency_graph() has an “async_workers” parameter. These allow a user to retrieve items/services and dependencies asynchronously, greatly improving the speed of large-scale cases, at the risk of potentially overloading the server. Internal time jitters were implemented to combat rate limiting, but in extreme cases, null Items or dependencies may still be returned and the user should either lower the number of async_workers or attempt synchronously.

- An entire organization’s dependency picture can be actively updated by doing the workflow outlined in the organization-wide dependency graph notebook. That notebook also contains some helpful helper functionality for querying the nodes in the graphs.

- The ItemNode.type property should be used in workflows where validating a node corresponds to an existing item or service is necessary, as that validation occurs when setting the property. Any ItemNode with a type of "Portal Item" has a valid Item object stored in its item property, any node with a type of "Service URL" has a valid service object in the item property (though it could be any one of a number of different service class types), and any node with type "Unknown Type" is confirmed to have neither and will just have None in the item property.

- An existent graph can have more items added to it, with their dependencies analyzed, using the add_dependencies() function. It can either take new items, or merge another ItemGraph into it.

## Example Workflows

```
# which standalone server services do my web maps use?
my_items = gis.content.search("", item_type = "Web Map", max_items = 25)
wm_graph = create_dependency_graph(
    gis = gis, 
    item_list = my_items,
    include_services = True,
    run_async = True, 
    async_workers = 10,
)

standalone_services = [node for node in wm_graph.all_items() if node.type == "Service URL"]
for service in standalone_services:
    print(service.item)
```

```
# which feature layers are required by other items (ArcGIS Online)
my_items = gis.content.search("", item_type = "Feature Service")
service_graph = create_dependency_graph(
    gis = gis, 
    item_list = my_items,
    include_reverse = True,
    run_async = True, 
    async_workers = 10,
)

for item in my_items:
    node = service_graph.get_node(item.id)
    reqs = node.required_by("item")
    if not reqs:
        continue
    print(f"\nService: {item}")
    print("Required by:")
    for req in reqs:
        print(req)
```

```
# identify references within items that might be broken (no validated items/services associated)
my_items = gis.content.search("", max_items = 100)
graph = create_dependency_graph(
    gis = gis, 
    item_list = my_items,
    include_services = True,
    run_async = True, 
    async_workers = 10,
)

ids_to_inspect = [node.id for node in graph.all_items() if node.type == "Unknown Type"]
print(ids_to_inspect)
```