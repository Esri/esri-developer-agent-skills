# Cloning

Use this reference to choose documentation for copying supported content between portals, reusing destination dependencies, and transferring offline content packages.

Offline cloning here means disconnected content/group export-import artifacts. Offline map areas and synchronization replicas are outside this reference.

## Documentation by task

| Task | Documentation |
| --- | --- |
| Clone supported items and dependencies between connected portals | [Cloning Content](https://developers.arcgis.com/python/latest/guide/cloning-content/) and [clone_items() API](https://developers.arcgis.com/python/latest/api-reference/arcgis.gis.toc.html#arcgis.gis.ContentManager.clone_items) |
| Export, inspect and import offline content packages | [Cloning via Offline Backups](https://developers.arcgis.com/python/latest/guide/offline-cloning-backups/) and [OfflineContentManager API](https://developers.arcgis.com/python/latest/api-reference/arcgis.gis.toc.html#offlinecontentmanager) |
| Clone group configuration directly or through an offline package | [GroupManager.clone()](https://developers.arcgis.com/python/latest/api-reference/arcgis.gis.toc.html#arcgis.gis.GroupManager.clone) and [load_offline_configuration()](https://developers.arcgis.com/python/latest/api-reference/arcgis.gis.toc.html#arcgis.gis.GroupManager.load_offline_configuration) |
| Export and import group content between ArcGIS Enterprise organizations (Enterprise only) | [GroupMigrationManager API](https://developers.arcgis.com/python/latest/api-reference/arcgis.gis.toc.html#groupmigrationmanager) |
| Troubleshoot complex applications, reuse dependencies or remap references | [Cloning and Troubleshooting Complex Items](https://developers.arcgis.com/python/latest/guide/cloning-complex-apps/) and [Item.remap_data() API](https://developers.arcgis.com/python/latest/api-reference/arcgis.gis.toc.html#arcgis.gis.Item.remap_data) |

Review [Item dependency graphs](./item-dependency-graph.md) before selecting a cloning scope. Use the linked API references for supported item types, options, return types and release-specific limitations.

## Important limits

- Group configuration cloning does not clone the group's items. Its `.GROUP_CLONER` packages are separate from the `.contentexport` packages used by `OfflineContentManager`.
- Copying an item is not always copying its service or data. Map and image service items can retain their original service URLs; check destination references before treating a clone as independent of its source.
- Online and Enterprise organizations may have differing service configurations available, resulting in differences in the layer properties/settings.

## Usage Tips and Tricks

- The two de facto cloning methods for the API are clone_items() and the OfflineContentManager, which includes the functions export_items() and import_content(). clone_items() requires direct connections to multiple GIS organizations and will manually recreate and repopulate services, while the OfflineContentManager uses export_items() to persist items into packages on disk that import_content() can then import when called from an organization. The OfflineContentManager will persist services using export endpoints from the organization, and the preferred format for these written-out services can be specified. The OfflineContentManager is the recommended first step, as it is being developed/maintained more actively.

- The OfflineContentManager is also a helpful tool for version control and backing up items.

- Both tools will attempt to discover all dependencies for an item and clone those, later recreating all necessary items and swizzling them in the new org. clone_items() has its own dependency parsing regime, while the OfflineContentManager leverages create_dependency_graph(), meaning they may vary slightly in terms of what items are imported; however, the consistency with create_dependency_graph() is a benefit of the OfflineContentManager, meaning users can manually inspect the necessary dependencies if they need.

- Both tools can be cumbersome in execution time, but leverage async functionality within to attempt to combat the time requirement. This functionality is optional in the OfflineContentManager, meaning users can switch to synchronous imports if rate limiting issues are met.

- clone_items() will roll back and delete all created items if an error occurs, making it an “all-or-nothing” method. The OfflineContentManager allows users to skip over error items and continue importing the rest, should a user desire, making it the preferred case for item types where a partial migration is better than nothing. This is especially beneficial for complex item types with numerous referenced items such as Survey123 Forms, allowing users to troubleshoot individual pieces should they need to. For this reason, the OfflineContentManager is the recommended method for migrating Survey123 Forms.

- Both methods allow for a user to search the target organization for items that match the source items and reference them in other items instead of cloning them again unnecessarily. This is done with a typeKeyword on the item. This can be toggled with the search_existing_items parameter.

- If one method isn’t working to migrate an item for a user, trying with the other is recommended, as their different internal methodology can sometimes be complementary in covering shortcomings.

- If a user wishes to manually map their referenced items to ones in the target organization, that can be done with the item_mapping parameter in clone_items() and import_content().

- clone_items() contains additional options for remapping Dashboard fields and components.

- Both functions can attempt to preserve item id’s of items when cloning to ArcGIS Enterprise organization. This is not possible when cloning to ArcGIS Online organizations.

- When using export_items(), if no path is specified, the exported package will be created in a temporary directory that eventually gets cleaned up, leaving no trace on disk. The variable containing the temporary path name must be used in import_content() before that, however.

- In version 2.4.4 and higher, the OfflineContentManager should have the same item type coverage as clone_items(), plus the ability to clone Knowledge Graphs to orgs that have Knowledge enabled, which is unique to it.

- When using clone_items(), the copy_data parameter dictates whether or not a service's data is copied over or just re-referenced from the same original URL.

- clone_items() and OfflineContentManager are unique in that other item-level tools are often just for one type of deployment or a specific subset of items, while these two tools are meant for nearly all item types on both ArcGIS Online and ArcGIS Enterprise.