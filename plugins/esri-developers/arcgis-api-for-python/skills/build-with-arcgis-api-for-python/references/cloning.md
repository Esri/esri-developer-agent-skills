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