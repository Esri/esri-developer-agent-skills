---
name: build-with-arcgis-maps-sdk-for-unity
license: Apache-2.0
description: "Use this skill to build Unity apps with ArcGIS Maps SDK for Unity. Choose Map Creator, Components, or the C# API; add supported ArcGIS data; follow current setup, authentication, and compatibility guidance; and validate scenes and deployment targets. Consult the linked API reference for C# details."
---

# Build with ArcGIS Maps SDK for Unity

ArcGIS Maps SDK for Unity is a Unity plugin for using real-world maps and 3D ArcGIS content in interactive 3D and XR experiences. Use it to bring geospatial data into Unity scenes through Map Creator, SDK Components, or the C# API.

## ArcGIS account requirements

Developers must have one of the following ArcGIS accounts to create applications with ArcGIS Maps SDK for Unity: ArcGIS Location Platform, ArcGIS Online, or ArcGIS Enterprise. The user type, role, and privileges for the account provides an application with access to different ArcGIS resources and operations. In general, the requirements to develop apps with these products are:

* ArcGIS Location Platform - Any ArcGIS Location Platform account can be used to develop applications with ArcGIS Maps SDK for Unity. Sign up for free at https://location.arcgis.com/.
* ArcGIS Online - A user type of "Creator" or higher is required to create developer credentials and set up authentication. To learn more, go to https://www.esri.com/en-us/arcgis/products/arcgis-online/overview.
* ArcGIS Enterprise - A user type of "Creator" or higher is required to create developer credentials and set up authentication. To learn more, go to https://www.esri.com/en-us/arcgis/products/arcgis-enterprise/overview.

## Authentication

ArcGIS is a secure system that requires token-based authentication to authorize access to secure resources. There are different types of authentication available. The one you use depends on the application's runtime environment, audience, use case, and level of access. Refer to the `follow-esri-authentication-patterns` skill to learn more about authentication in ArcGIS, including user authentication, API key authentication, and app authentication. The skill also shows how to select the appropriate type of authentication for an application and how to set it up correctly.
If this skill is not available, search the project workspace for existing authentication patterns. If the project has no authentication framework, query the documentation for authentication best practices using the process below and follow any SDK-specific authentication recommendations.

## Installation and setup

1. Before creating or upgrading a project, check the [system requirements](https://developers.arcgis.com/unity/system-requirements/) for the SDK release in use. Verify Unity, render pipeline, and target-platform support.
2. Use HDRP or URP; the built-in render pipeline is unsupported. Check the setup guide for compatible render-pipeline package versions.
3. Install from the [Unity Asset Store](https://assetstore.unity.com/packages/tools/integration/arcgis-maps-sdk-for-unity-258537) or [SDK downloads](https://developers.arcgis.com/unity/downloads/). For tarballs, use Package Manager's **Add package from tarball**. For existing projects, follow the [setup guide](https://developers.arcgis.com/unity/install-and-set-up/add-the-plugin-to-an-existing-project/).
4. Import **Sample Content** if useful. Configure the scene with Map Creator, SDK Components, or the C# API according to the task.
5. Configure ArcGIS access using the authentication guidance above; keep credentials out of source control.
6. For upgrades, follow the [upgrade guide](https://developers.arcgis.com/unity/install-and-set-up/upgrade-to-a-new-plugin-version/) and recheck project compatibility.

## How to query documentation

Documentation can be queried using the MCP for Esri Developers server:
```
https://developers-mcp.arcgis.com/mcp
```
Use the `search_esri_developer_docs` tool to query authoritative documentation with `unity-sdk` as the `focus_area` parameter in addition to the `search_term`.

## Documentation links

- [ArcGIS Maps SDK for Unity](https://developers.arcgis.com/unity/) - Start here for an overview, key features, and links to current resources.
- [API reference](https://developers.arcgis.com/unity/api-reference/) - Look up SDK classes, methods, and properties before generating or changing C# code.
- [Install and setup](https://developers.arcgis.com/unity/install-and-set-up/) - Follow the current project creation and plugin installation workflow.
- [System requirements](https://developers.arcgis.com/unity/system-requirements/) - Check SDK-version-specific development and deployment compatibility.
- [Scene setting options](https://developers.arcgis.com/unity/install-and-set-up/scene-setting-options/) - Decide between Map Creator, Components, and the C# API.
- [Display a map with Map Creator](https://developers.arcgis.com/unity/maps/tutorials/display-a-map-ui/) - Create and configure a map through the editor UI.
- [Display a map with Components](https://developers.arcgis.com/unity/maps/tutorials/display-a-map-comp/) - Set up a map and layers using Unity components.
- [Display a map with the C# API](https://developers.arcgis.com/unity/maps/tutorials/display-a-map-api/) - Build a map setup through code.
- [Spatial references](https://developers.arcgis.com/unity/spatial-reference-and-data-analysis/spatial-references/) - Check coordinate-system support and map/data spatial-reference compatibility.
- [FAQ](https://developers.arcgis.com/unity/faq/) - Troubleshoot common data-loading and scene issues.
- [Sample code](https://developers.arcgis.com/unity/sample-code/) - Find working examples for SDK features.

## Patterns and guidelines

- Use C# scripting with the SDK API as the default approach; Use the SDK API directly; do not assume SDK Components are required. Use Map Creator for no-code map setup or SDK Components for GameObject-based integration. Components can also be configured through C#.
- Choose a global or local scene for the geographic extent. Ensure map and layer spatial references are compatible; the first layer may determine the map spatial reference.
- Preserve the ArcGIS Map's HPRoot setup, which addresses floating-point precision limits.
- For missing data, inspect view-state logs, camera extent, layer source, authentication, supported formats, and spatial-reference compatibility.
- Use the matching API reference and existing SDK components or samples instead of recreating SDK behavior.
- Check target-device requirements; editor success does not validate a player build.

## Validation process

- [ ] Check Unity, render pipeline, target platform, and installed SDK against the system requirements.
- [ ] Confirm the package and required Components are available; run a relevant sample when useful.
- [ ] Verify authentication and access to required ArcGIS resources without exposing credentials.
- [ ] Run the scene; check camera position, layer loading, Unity Console, and view-state logs.
- [ ] If data is missing, check spatial references, supported formats, and global/local scene choice.
- [ ] Build and test for the target platform when available.
