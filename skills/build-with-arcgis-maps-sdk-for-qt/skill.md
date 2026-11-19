---
name: build-with-arcgis-maps-sdk-for-qt
license: Apache-2.0
description: >-
  Use when building, extending, debugging, or reviewing native GIS applications with ArcGIS Maps
  SDK for Qt in C++ with a Qt Quick/QML or Qt Widgets UI. Guide SDK setup, compatible Qt kits,
  CMake integration, maps and scenes, layers, graphics, queries, editing, location, offline
  workflows, authentication, licensing, Toolkit components, and deployment. Consult
  follow-arcgis-authentication-patterns to select an authentication model. Not for Qt Location's
  Map item or other ArcGIS SDKs.
metadata:
  author: esri
  version: "1.0.0"
---

# Build with ArcGIS Maps SDK for Qt

Build native GIS applications using the SDK's C++ API with a Qt Quick/QML or Qt Widgets UI.
This skill follows the most recent released ArcGIS Maps SDK for Qt. Confirm platform and API
support for the project's selected SDK rather than assuming desktop and mobile targets offer
identical capabilities.

## Application requirements and version selection

If requirements are unclear, use `gather-arcgis-application-requirements` to review the project
and clarify consequential unknowns. Reuse decisions already supplied by the user or project.

- Honor explicit SDK, Qt, UI framework, and target-platform choices. Preserve an existing
  project's SDK and build system unless an upgrade or migration is requested or necessary;
  clarify consequential changes before proceeding.
- For new projects, if the user has no explicit preferences, prefer the following defaults:
  - ArcGIS Maps SDK for Qt version: choose the most recently **released** SDK, verified
    through [downloads](https://developers.arcgis.com/qt/downloads/) and
    [release notes](https://developers.arcgis.com/qt/release-notes/). Use documentation matching
    the selected SDK version.
  - Qt version: normally choose the newest installed Qt version compatible with the selected SDK and
    target. Verify required Qt modules, compiler/ABI, architecture, and OS in the selected release's
    [system requirements](https://developers.arcgis.com/qt/system-requirements/).
  - Build system: prefer CMake over QMake.
  - UI framework: prefer Qt Quick/QML for modern, cross-platform development, while Qt Widgets may be
    used for legacy or specialized desktop applications.

## Authentication and licensing

DO NOT SKIP: Refer to `follow-arcgis-authentication-patterns` to select the authentication model
for the audience, resources, and operations. If unavailable, inspect existing project patterns;
if none exist, consult official authentication guidance through the Esri developer documentation
MCP server or the linked [official documentation](references/resources.md).

Use the selected release's authentication APIs and supported Toolkit integration rather than
copying older implementations. Preserve established credential handling unless the task changes
it. Never print, hard-code, or commit API keys, tokens, client secrets, passwords, or license strings.

Service authentication and account privileges are separate from SDK licensing. Verify the
specific operation in [License by API](https://developers.arcgis.com/qt/license-and-deployment/license-by-api/)
and [License levels and capabilities](https://developers.arcgis.com/qt/license-and-deployment/license-levels-and-capabilities/);
do not infer a license level from account type or assume all local data requires Standard.
Handle licensing results and authentication failures explicitly.

## Setup and project integration

- Follow the selected release's [installation guide](https://developers.arcgis.com/qt/install-and-set-up/).
  Prefer CMake for new apps; preserve valid existing CMake or qmake integration for unrelated work.
- Prefer starting new apps from an official standalone solution, such as the
  [Display a map tutorial](https://developers.arcgis.com/qt/maps-2d/tutorials/display-a-map/) and its
  [solution project](https://developers.arcgis.com/qt/zips/display-a-map.zip), after checking its
  SDK version. Instructing the user to create a new project through the Qt Creator's ArcGIS wizard is
  another supported route. Do not copy unexpanded files from the SDK's `ideintegration` wizard directories
  as ready-to-build projects.
- The bundled [generator](scripts/new_project.sh) is optional, not a required or universally
  validated scaffolding workflow. See [its limitations](references/resources.md#optional-bundled-generator)
  before using it, and always select the intended SDK explicitly.
- Make configuration reproducible using documented CMake commands, presets, or toolchains.
  Legitimate SDK/Qt path overrides are allowed; keep machine-specific paths out of shared source.
  Verify the SDK and Qt kit actually resolved by CMake, including cached paths, rather than
  trusting `PATH` or a requested prefix. Do not require global registration changes merely to
  satisfy the bundled script's discovery assumptions.
- In build scripts, quote discovered tool paths correctly for the target shell. Verify the
  actual compiler/toolset, architecture, and ABI against the
  selected SDK's supported toolchain; IDE host branding alone does not identify the toolset
  or establish support for a newer compiler.
- Check the selected release's CMake integration for generator, build-type, runtime-library,
  and deployment requirements. Use separate build directories where configurations could
  reuse incompatible cached libraries. Preserve required SDK/Qt deployment steps and attribution.
- Verify renderer assets as well as native libraries against the matching solution and
  [deployment guide](https://developers.arcgis.com/qt/license-and-deployment/deployment/#deploying-shaders).
  Deploy renderer-specific assets to the locations required by the selected SDK release,
  target platform, and renderer rather than assuming a shared layout across environments.

### Integrating into an existing project

1. Inspect the project's SDK/Qt versions, build system, UI framework, targets, startup code,
   resources, and deployment configuration. Extend these in place rather than replacing the
   app's `CMakeLists.txt`, `main.cpp`, or resource/module layout with a generated project.
2. **CMake:** Obtain the selected SDK release's expanded `cmake/FindArcGISRuntime.cmake` from
   a matching official standalone solution or Qt Creator wizard-generated project. Add it to the
   project's CMake module directory and append that directory to `CMAKE_MODULE_PATH` before
   calling `find_package(ArcGISRuntime <selected-version> REQUIRED COMPONENTS Cpp)`. Link the
   existing app target to `ArcGISRuntime::Cpp` and find/link the Qt components required by that
   release and UI framework. Follow the matching solution's discovery logic, with documented
   SDK/Qt path settings or presets, and verify the resolved installation.
3. **qmake:** Follow the selected SDK's
   [existing-app integration guidance](https://developers.arcgis.com/qt/programming-patterns/best-practices/#integrate-the-sdk-into-an-existing-app)
   to include its Qt Quick or Qt Widgets `.pri` file in the existing `.pro` file; do not force a
   CMake migration.
4. **Views and resources:** For Qt Quick, register the required SDK view types before loading
   QML and expose the feature's C++ model/controller through the existing registration/module
   scheme. Add QML files to the project's existing resources or QML module. For Qt Widgets,
   create and attach the appropriate SDK view widget within the existing widget hierarchy;
   QML registration is not required.
5. **Startup:** Integrate authentication and licensing into the existing initialization sequence,
   following the selected release's guidance and [authentication and licensing](#authentication-and-licensing)
   above. Initialize required components before their first use without embedding credentials.
6. **Deployment:** Merge the applicable runtime-copy and platform packaging steps from the
   matching solution and [deployment guide](https://developers.arcgis.com/qt/license-and-deployment/deployment/).
   Include required SDK/native libraries and Qt plugins, renderer-specific shaders, and platform
   artifacts as applicable (for example Android's `MapsSDKNative.jar` and OpenSSL libraries,
   or iOS frameworks). Linking the SDK alone does not complete runtime deployment.

## Architecture and implementation

- Preserve a valid existing structure. [Official samples](https://github.com/Esri/arcgis-maps-sdk-samples-qt)
  teach focused API usage and often place a feature in one class; do not scale that into an
  application-wide catch-all class. When warranted, separate cohesive SDK features into appropriately
  scoped `.h`/`.cpp` classes and QML components. Keep application composition in the main app rather
  than introducing one class per API call.
- Use Toolkit's feature controller/component pattern as a reference: accept the relevant
  view/model dependencies and encapsulate feature state and behavior. For Qt Quick, expose
  deliberate C++ properties, signals, and actions to QML. Do not forbid valid programmatic
  Quick views or require an unrelated QML registration/resource-layout migration.
- Give dynamically allocated QObject SDK objects an appropriate parent for their intended
  lifetime; `this` is often an appropriate parent when the lifetimes align. Respect documented
  ownership transfer and deliberate RAII. Check ownership of collections and asynchronous
  results, preserve value semantics, and ensure exposed objects and callback captures outlive
  their use.
- Follow [tasks and jobs](https://developers.arcgis.com/qt/programming-patterns/tasks-and-jobs/)
  and [best practices](https://developers.arcgis.com/qt/programming-patterns/best-practices/).
  Keep blocking work off the UI thread, wait for required resource loading, and handle errors,
  cancellation, and stale results. For `QFuture` calls, include the required Qt headers and use
  context-bound continuations where appropriate to protect thread affinity and lifetimes.
- Verify the exact selected-version class, method, enum, defining header, and ownership contract
  in installed headers or official references. Include defining headers for forward-declared
  types used by the code. Do not infer SceneView functionality from MapView or infer export
  support merely because an API can consume a package.

## Toolkit

Prefer existing [ArcGIS Maps SDK Toolkit](https://developers.arcgis.com/qt/toolkit/) components
over custom equivalents. Choose a Toolkit release compatible with the selected SDK and UI
framework, and follow its integration instructions, including required Qt modules.

Use ready-to-use component defaults out of the box unless requirements call for customization.
The Toolkit is configurable and extensible; consult supported properties, controllers, and
integration points before replacing behavior. Consider its Calcite style when appropriate.
Preserving defaults is a technical starting point, not a requirement for manual-only testing.

## Documentation lookup

Use the Esri MCP server for developer documentation to find official guidance. Search with
`search_esri_developer_docs`, using `focus_area: "qt-sdk"` and a focused `search_term`,
then retrieve relevant pages with `fetch_esri_developer_doc(url)`. Use `fetch_esri_developer_focus_areas()`
when the appropriate scope is unclear. Follow the connected tools’ exposed schemas if client
naming or parameters differ. See [MCP server tools](https://developers.arcgis.com/ai/arcgis-agentic-developer-toolkit/mcp-server/).

Use [the resource guide](references/resources.md) for server setup, official references, and
samples. If the server is unavailable or returns no useful content, consult the linked official
documentation. Verify that documentation matches the selected SDK version, using installed
headers or versioned official references for release-specific details. Clearly identify
recommendations and assumptions not grounded in those sources.

## Validation

Validate proportionately to the changed feature and selected SDK, Qt kit, build system, and target.
Use relevant existing automated checks or targeted runtime checks; do not impose an exhaustive
new test campaign or require manual interaction for every task.

- **Configure/build (when code or integration changes):** Build the affected project and
  configuration, checking the resolved SDK/Qt kit and fixing new configuration or compile errors.
- **Runtime behavior (when applicable):** Exercise the changed workflow's relevant success and
  failure paths, including loading, permissions, offline/network behavior, or cancellation as
  applicable. Distinguish process survival, window creation, SDK attribution, map/layer loaded
  status, and completed drawing from visible requested content. When execution is authorized,
  verify content in the intended supported native launch environment; distinguish launch-harness
  or observation-timeout failures from application failures.
- **Blank-view diagnosis:** Retain useful QML, resource-load, and draw diagnostics instead of
  suppressing framework errors wholesale. Log credential-safe status names/codes or sanitized
  messages, not raw credential-bearing URLs. Check the active renderer and deployed shader
  layout even when maps/layers report loaded; loaded data alone does not establish drawing.
- **Authentication/licensing (when changed):** Verify intended access, denied access, and the
  configured credential flow as relevant; confirm the license covers the APIs used.

Report checks as run, not run, or blocked, with observed results and remaining limitations.
Do not claim build, runtime, device, or service verification without performing it. Skill-author
evaluation across representative prompts/projects is separate from validation of an app task.
