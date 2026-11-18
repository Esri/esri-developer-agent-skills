# Official resources and optional scaffolding

Select documentation, sample branches/tags, and Toolkit releases matching the SDK actually in
use. Consult the selected SDK's installed headers and matching official API reference for
signatures and ownership, and release-specific documentation for supported setup.

## SDK and Qt documentation

| Need | Authoritative starting point |
|---|---|
| Release status and setup | [Downloads](https://developers.arcgis.com/qt/downloads/), [release notes](https://developers.arcgis.com/qt/release-notes/), [system requirements](https://developers.arcgis.com/qt/system-requirements/), [install and set up](https://developers.arcgis.com/qt/install-and-set-up/) |
| Exact SDK APIs | [C++ API reference](https://developers.arcgis.com/qt/cpp/api-reference/) and the selected SDK's `sdk/include` headers |
| Runnable starting point | [Display a map tutorial](https://developers.arcgis.com/qt/maps-2d/tutorials/display-a-map/) and [standalone solution](https://developers.arcgis.com/qt/zips/display-a-map.zip) |
| Existing-project SDK integration | [Existing-app integration guide](https://developers.arcgis.com/qt/programming-patterns/best-practices/#integrate-the-sdk-into-an-existing-app) for qmake; a version-matched [standalone solution](https://developers.arcgis.com/qt/zips/display-a-map.zip) or wizard-generated project for expanded CMake discovery and target integration |
| Focused feature examples | [Tutorials](https://developers.arcgis.com/qt/tutorials/), [sample catalog](https://developers.arcgis.com/qt/cpp/sample-code/), [official samples](https://github.com/Esri/arcgis-maps-sdk-samples-qt) |
| Lifecycle, async, performance | [Best practices](https://developers.arcgis.com/qt/programming-patterns/best-practices/), [tasks and jobs](https://developers.arcgis.com/qt/programming-patterns/tasks-and-jobs/), [performance considerations](https://developers.arcgis.com/qt/programming-patterns/performance-considerations/) |
| Data and offline workflows | [Layer types](https://developers.arcgis.com/qt/layers/layer-types/), [offline maps, scenes, and data](https://developers.arcgis.com/qt/offline-maps-scenes-and-data/) |
| Authentication implementation after skill routing | [How to authenticate](https://developers.arcgis.com/qt/authentication/how-to-authenticate/), [implement authentication](https://developers.arcgis.com/qt/authentication/implement-authentication/) |
| Licensing and deployment | [License by API](https://developers.arcgis.com/qt/license-and-deployment/license-by-api/), [license levels and capabilities](https://developers.arcgis.com/qt/license-and-deployment/license-levels-and-capabilities/), [deployment](https://developers.arcgis.com/qt/license-and-deployment/deployment/) |
| Toolkit components and integration | [Toolkit guide](https://developers.arcgis.com/qt/toolkit/), [API reference](https://developers.arcgis.com/qt/toolkit/api-reference/), [source and integration instructions](https://github.com/Esri/arcgis-maps-sdk-toolkit-qt), [Calcite style](https://github.com/Esri/arcgis-maps-sdk-toolkit-qt/tree/main/calcite) |
| Qt APIs and build integration | [Qt documentation](https://doc.qt.io/), [C++ classes](https://doc.qt.io/qt-6/classes.html), [CMake manual](https://doc.qt.io/qt-6/cmake-manual.html), [deployment](https://doc.qt.io/qt-6/deployment.html) |

Use samples to confirm API usage, not as a mandate to keep all production functionality in one
class. For Toolkit architecture, inspect the relevant component/controller and its dependencies,
using the selected compatible release.

## Esri documentation MCP setup

Installing this skill alone does not configure the **Esri MCP server for developer documentation**
(`esri-mcp-server-for-developer-documentation`). Configure
`https://developers-mcp.arcgis.com/mcp` through the client's MCP settings, or install the full
**ArcGIS SDKs and APIs** plugin (`arcgis-sdks-and-apis-plugin`), which bundles the server.

## Qt Agentic Tools

For Qt framework questions, [Qt's Agentic Tools](https://doc.qt.io/agentictools/) provide
skills and documentation MCP tools for Qt C++, QML, and project development. Use available
tools where helpful, while following the selected SDK and Qt kit requirements.

## Optional bundled generator

[`scripts/new_project.sh`](../scripts/new_project.sh) is retained as an optional convenience.
It requires a POSIX shell and utilities (for example Git Bash on Windows) and an installed SDK.
It renders only a subset of Qt Creator's wizard format; it is not proof that every SDK template,
target platform, or generated configuration works.

- Inspect its help and the chosen SDK template before using it. Always pass `--sdk` with the
  explicitly selected version or installation directory, even with `--list`; without it, the
  script picks the newest discovered installation, which may be an unreleased development SDK.
- Registration-file discovery is limited. An empty discovery result does not prove that no SDK
  is installed; inspect project configuration and explicit SDK paths before proposing setup changes.
- Use a new destination. Do not use `--force` to overwrite an existing project as an integration
  shortcut. Preserve existing build, resource, and QML registration patterns.
- Inspect generated files, confirm the selected SDK/Qt kit, and adapt documented build/deployment
  configuration to the target. The script's generic build summary is not a platform compatibility
  guarantee. Do not change global registration solely to accommodate the script.

The official standalone tutorial solution or Qt Creator wizard remains an alternative; this
generator is never a prerequisite for implementing an app feature.
