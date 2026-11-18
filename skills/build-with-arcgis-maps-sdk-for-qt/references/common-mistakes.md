# Common mistakes — pre-flight checklist

Walk this list before reporting any ArcGIS Maps SDK for Qt work as done. Each item is something agents
do by default, observed in evaluations or reproduced against SDK 300.2.

1. [Process](#1-process) · 2. [Headers](#2-headers) · 3. [100.x leftovers](#3-100x-api-leftovers) ·
4. [Project and build](#4-project-and-build) · 5. [Ownership](#5-ownership) · 6. [Running](#6-running)

## 1. Process

| Wrong | Right | Why |
|---|---|---|
| Write ArcGIS calls from memory and finish without compiling | Check each SDK name in `<InstallDir>/sdk/include/`, then build | Training data is mostly the retired 100.x API; wrong names only show up when you compile |
| Invent a header from a type name (`LayerCollection.h`, `BasemapStyle.h`, `LoadStatus.h`) | `ls <InstallDir>/sdk/include/<Name>.h`; enums live in `*Types.h` | There is no per-enum header; guessed headers fail with "cannot open include file" |
| "Builds and runs" after passing extra `-D` flags on your own command line | The committed project must configure with only `CMAKE_PREFIX_PATH` and `CMAKE_BUILD_TYPE` | Ad-hoc flags are not saved; the next person (or Qt Creator) gets the original error |
| Report checks that were not run | Say exactly what was built, run, and observed | Unverified success claims are the most common failure |

## 2. Headers

Class headers **forward-declare** enums, value types they return, and `QFuture`. Using them needs the defining header.

```cpp
// WRONG — compiles only in your head
#include "Map.h"
#include "MapQuickView.h"
m_map = new Map(BasemapStyle::ArcGISTopographic, this);          // error: incomplete/undefined type BasemapStyle
m_mapView->setViewpointGeometryAsync(layer->fullExtent(), 20);    // error: incomplete type Envelope (and QFuture<bool>)

// RIGHT
#include "Envelope.h"
#include "Map.h"
#include "MapQuickView.h"
#include "MapTypes.h"      // BasemapStyle, LoadStatus, SelectionMode
#include <QFuture>
```

| You use | Include |
|---|---|
| `BasemapStyle`, `LoadStatus`, `SelectionMode` | `MapTypes.h` |
| `DrawStatus`, `LocationDisplayAutoPanMode` | `MapViewTypes.h` |
| `SceneViewingMode` | `SceneViewTypes.h` |
| `SimpleMarkerSymbolStyle`, `SimpleLineSymbolStyle`, `SimpleFillSymbolStyle` | `SymbolTypes.h` |
| `GeometryType` | `GeometryTypes.h` |
| `JobStatus` | `TaskTypes.h` |
| `LicenseStatus`, `LicenseLevel`, `SpatialRelationship` | `CoreTypes.h` |
| `QueryFeatureFields` | `GeodatabaseTypes.h` |
| `ErrorType` | `ErrorTypes.h` |
| any `...Async()` call | `<QFuture>` |
| `fullExtent()` → `Envelope`, `attributes()` → `AttributeListModel`, `toGeometry()` → `Geometry` | `Envelope.h`, `AttributeListModel.h`, `Geometry.h` |
| a `mouseClicked(QMouseEvent&)` handler declared in your header | `class QMouseEvent;` (or `<QMouseEvent>`) |

Unsure where an enum lives: `grep -rl "enum class <Name>$" <InstallDir>/sdk/include --include='*Types.h'`.

## 3. 100.x API leftovers

| 100.x / older (does not exist in 300.x) | 300.x |
|---|---|
| `import Esri.ArcGISRuntime 100.x` QML-only apps | C++ API + QML UI; register `MapQuickView` from C++ (see template) |
| `setViewpointGeometry(...)`, `setViewpointCenter(...)` | `setViewpointGeometryAsync(...)`, `setViewpointCenterAsync(...)` (return `QFuture<bool>`) |
| `identifyLayer(...)` + `identifyLayerCompleted` signal, `...Completed(QUuid, …)` signals, `TaskWatcher` | `identifyLayerAsync(...)` returning `QFuture<IdentifyLayerResult*>`; continue with `.then(this, …)` |
| `geocode(text, params)` / `geocodeAsync(text, params)` | `geocodeWithParametersAsync(text, params)` (`geocodeAsync(text)` has no params overload) |
| `Basemap::topographic()` and other static factories | `new Map(BasemapStyle::ArcGISTopographic, this)` or `new Basemap(BasemapStyle::…, this)` |
| `PopupManager` | `Popup` from `IdentifyLayerResult::popups()`, `evaluateExpressionsAsync()`, or the toolkit `PopupView` |
| `job->status()`, `job->cancelAsync()` | `job->jobStatus()`, `job->cancelJobAsync()`; signal `statusChanged(JobStatus)` |
| `Viewpoint(x, y, scale)` with longitude first | `Viewpoint(latitude, longitude, scale)` |
| `MapGraphicsView` / `SceneGraphicsView` (Widgets) | `MapViewWidget` / `SceneViewWidget` (300.2+; the old classes go away at 300.4) |

## 4. Project and build

| Wrong | Right | Why |
|---|---|---|
| Hand-write the CMake + `main.cpp` skeleton, or copy files raw from `sdk/ideintegration/` | `scripts/new_project.sh` | Template files contain Qt Creator escapes (`\\ `) that break `FindArcGISRuntime.cmake`'s install lookup |
| `find_package(ArcGISRuntime <ver>)` with a version that is not installed | An installed version, e.g. `300.2.0` (`300.2` means `300.2.0`) | The lookup reads the install registry file named after that version |
| Multi-config generator (Visual Studio, Xcode) or no `CMAKE_BUILD_TYPE` | Ninja + `-DCMAKE_BUILD_TYPE=Debug` (or `Release`); iOS is the exception (Xcode, see `setup-and-build.md`) | The SDK picks debug vs release libraries from `CMAKE_BUILD_TYPE` at configure time |
| Re-configure one build dir with a different build type | One build dir per build type | Library paths are cached; mixing gives runtime-library mismatch link errors |
| Any Qt kit that happens to be first | A kit ≥ the minimum in `CMakeLists.txt` with every module it lists; check `Qt6_DIR` in `CMakeCache.txt` | Kits without Positioning/Sensors/WebSockets/Multimedia fail; CMake may silently pick another Qt |
| Any compiler | The one listed in the SDK system requirements for your platform | The SDK ships prebuilt libraries |
| Rewrite the generated qrc/`qmlRegisterType` layout piecemeal to `qt_add_qml_module` | Keep it, or migrate everything at once (`project-integration.md`) | A half-migration builds but fails at startup (`main.qml` not found / "is not a type") |
| Add a `.qml` file without listing it in `qml/qml.qrc` | List it in the qrc | Builds fine, then "<Type> is not a type" at runtime |
| Any toolkit checkout | The toolkit tag matching the SDK version (e.g. 300.2.x for SDK 300.2) | Mismatched toolkits fail at configure (missing sources) or at runtime |
| Toolkit added without its Qt modules | `find_package` QuickControls2, Svg, WebView, Graphs, NetworkAuth (300.2) | Otherwise configure warns "target is mentioned as a dependency for libtoolkitcpp, but not declared", or fails if you link e.g. `Qt6::WebView` without finding it |
| `AuthenticationView` (200.x) | `Authenticator` + `OAuthUserConfigurationManager` (300.x), `QtWebView::initialize()` before the app object | Renamed in 300.x; OAuth sign-in UI is only provided by the toolkit |

## 5. Ownership

| Wrong | Right |
|---|---|
| Leave async results (`IdentifyLayerResult*`, `FeatureQueryResult*`, `QList<FeatureEditResult*>`) unowned | Own them (`std::unique_ptr`, `qDeleteAll`) or pass a parent; `setParent(this)` on a feature you keep |
| `graphics()->clear()` and assume the graphics are freed | Delete them, or parent them to a throwaway `QObject` you delete |
| Range-for over `FeatureQueryResult` | `auto it = result->iterator(); while (it.hasNext()) { Feature* f = it.next(this); … }` |
| SDK objects with no parent | Always pass a parent (`this`, the map, the layer) |

## 6. Running

| Wrong | Right |
|---|---|
| "The process stayed up, so it works" | Read the console: a QML load error leaves the process running with no window |
| Ignore auth messages | "An ArcGIS authentication error occurred" / "Host requires authentication" means no or bad API key / credential |
| Hard-code the API key | Read `ARCGIS_RUNTIME_API_KEY` from the environment (the generated `main.cpp` does) |
| `ArcGISRuntimeEnvironment::setLicense("…");` and move on | It returns a `[[nodiscard]]` `LicenseResult`; check `licenseStatus()` — an invalid string fails silently except for the watermark |
| QML `id: model` used inside a `ListView`/`Repeater` delegate | Rename the id (e.g. `id: app`); inside delegates `model` is the delegate's data |
| Deploy without the SDK `shaders` folder | Deploy it next to the executable for Direct3D/Metal renderers; a dev machine hides this |
