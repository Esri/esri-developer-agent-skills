# Resources and documentation lookup

Where to look things up, in order of preference. Prefer the installed SDK and official docs over memory:
most training data shows the retired 100.x API.

## 1. The installed SDK (authoritative for the version in use)

| Need | Where |
|---|---|
| Does a class / method / signal / enum exist? Exact signature? | grep `<InstallDir>/sdk/include/` (auth classes in `Authentication/`) |
| Which header defines an enum | `grep -rl "enum class <Name>$" <InstallDir>/sdk/include --include='*Types.h'` |
| A working project skeleton | `scripts/new_project.sh` (renders the SDK's own Qt Creator template) |
| Offline API reference | `<InstallDir>/sdk/doc/*.qch` (Qt Assistant / Qt Creator help) |

`new_project.sh --list` prints the SDK installs found, including `<InstallDir>`.

## 2. Documentation MCP servers (if connected)

- **Esri developer docs** (`https://developers-mcp.arcgis.com/mcp`): `search_esri_developer_docs` with
  `focus_area: "qt-sdk"` and a `search_term`; then `fetch_esri_developer_docs` with `page_url` for the full page.
- **Qt docs** (`qt-docs` / `qt_documentation_search`): Qt classes, QML types, Qt CMake commands.

Say which recommendations are not grounded in docs or headers.

## 3. Official links

Guide and reference
- [Maps SDK for Qt guide](https://developers.arcgis.com/qt/) · [API reference](https://developers.arcgis.com/qt/api-reference/) · [Release notes](https://developers.arcgis.com/qt/release-notes/)
- [System requirements](https://developers.arcgis.com/qt/system-requirements/) · [Install and set up](https://developers.arcgis.com/qt/install-and-set-up/) · [Downloads](https://developers.arcgis.com/qt/downloads/)

Programming patterns
- [Tasks and jobs](https://developers.arcgis.com/qt/programming-patterns/tasks-and-jobs/) · [Performance considerations](https://developers.arcgis.com/qt/programming-patterns/performance-considerations/) · [Best practices](https://developers.arcgis.com/qt/programming-patterns/best-practices/)
- [Layer types](https://developers.arcgis.com/qt/layers/layer-types/) · [Offline maps, scenes, and data](https://developers.arcgis.com/qt/offline-maps-scenes-and-data/)

Security and licensing
- [How to authenticate](https://developers.arcgis.com/qt/security-and-authentication/how-to-authenticate/) · [Implement authentication](https://developers.arcgis.com/qt/security-and-authentication/implement-authentication/)
- [License levels and capabilities](https://developers.arcgis.com/qt/license-and-deployment/license-levels-and-capabilities/) · [License by API](https://developers.arcgis.com/qt/license-and-deployment/license-by-api/)

Code
- [Qt Maps SDK samples](https://github.com/Esri/arcgis-maps-sdk-qt-samples) (C++ with QML, and Widgets) — the best source of working patterns
- [Tutorials](https://developers.arcgis.com/qt/tutorials/) · [Display a map tutorial](https://developers.arcgis.com/qt/maps-2d/tutorials/display-a-map/)
- [Toolkit](https://developers.arcgis.com/qt/toolkit/) · [Toolkit source](https://github.com/Esri/arcgis-maps-sdk-toolkit-qt) · [Calcite style for Qt](https://github.com/Esri/arcgis-maps-sdk-toolkit-qt/tree/main/calcite)
- [Dynamic Situational Awareness app](https://github.com/Esri/dynamic-situational-awareness-qt) — a large reference app

Community
- [Esri Community – Qt](https://community.esri.com/en/search?domain=all_content&query=qt&scope=site&source=community) · [ArcGIS Blog – Qt](https://www.esri.com/arcgis-blog/?s=qt)

Qt framework
- [Qt documentation](https://doc.qt.io/) · [Qt C++ classes](https://doc.qt.io/qt-6/classes.html) · [Qt CMake manual](https://doc.qt.io/qt-6/cmake-manual.html)
