# Project integration (ArcGIS Maps SDK for Qt 300.x)

Extend the generated project, add the SDK to an existing CMake project, add the toolkit, live with the Qt skills.
Contents: 1 Generated layout · 2 Extending it · 3 SDK in an existing project · 4 Toolkit · 5 Qt skills / `qt_add_qml_module` · 6 qmake

## 1. Generated layout (`new_project.sh` = Qt Creator's ArcGIS wizard)

| File | Role |
|---|---|
| `CMakeLists.txt` | Qt modules + min Qt check, `find_package(ArcGISRuntime <ver> … Cpp)`, post-build copy of SDK libs, icon/Android/iOS blocks, commented toolkit block |
| `cmake/FindArcGISRuntime.cmake` | Reads the SDK install registry (INI) for `<ver>`, includes `<InstallDir>/sdk/ideintegration/ArcGISRuntime.cmake` |
| `main.cpp` | API key from `ARCGIS_RUNTIME_API_KEY`, `qmlRegisterType` of the view + app class under `Esri.<Name>`, `engine.load("qrc:/qml/main.qml")` |
| `<Name>.h/.cpp` | QObject that owns the `Map`/`Scene`; `Q_PROPERTY mapView` set from QML |
| `qml/main.qml`, `qml/<Name>Form.qml`, `qml/qml.qrc` | Window, view + model, resource list |
| `Resources/`, `Win/`, `Mac/`, `Android/` (Qt Quick template only) | App icons and platform files - keep them |

## 2. Extending the template project

- **QML file:** create it in `qml/` **and** list it in `qml/qml.qrc`; otherwise it builds but fails at runtime
  with `<Type> is not a type`. Same folder = no import needed.
- **C++ QObject type:** add `.h/.cpp` to `SOURCE_FILES`, then register it in `main.cpp` **before** `engine.load`,
  under the same URI the QML already imports: `qmlRegisterType<LayerController>("Esri.<Name>", 1, 0, "LayerController");`
  Do not add `QML_ELEMENT` here - there is no QML module to collect it (see §5).
- **SDK view types** (`MapQuickView`, `SceneQuickView`, `LocalSceneQuickView` (300.x only)) have no `QML_ELEMENT`:
  always register them (`qmlRegisterType<SceneQuickView>("Esri.<Name>", 1, 0, "SceneView")`).
- **Qt module:** add it to `find_package(Qt6 COMPONENTS REQUIRED … <Module>)` and `Qt6::<Module>` to
  `target_link_libraries`. Never remove the SDK's modules (`Core Quick Multimedia Positioning Sensors WebSockets`;
  Widgets template: `Core Widgets Multimedia Positioning Sensors OpenGLWidgets WebSockets`).
- **Resources** (images, JSON): add a `.qrc` to `SOURCE_FILES` (AUTORCC is on) or extend `Resources/Resources.qrc`.
- Generic CMake/QML style: follow `qt-cmake-project` / `qt-qml` if installed, except where this file says otherwise.

## 3. Adding the SDK to an existing CMake Qt project

1. **Get `FindArcGISRuntime.cmake` from a rendered project** (`new_project.sh --name Tmp --dir <scratch>` and copy
   `Tmp/cmake/`). Never copy the raw file from `<InstallDir>/sdk/ideintegration/*Template*/cmake/`: it contains Qt
   Creator escapes (`ArcGIS\\ Runtime\\ SDK…`) that break the INI lookup.
2. Wire it in (verified against the 300.2 template and a migrated project):

```cmake
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
find_package(Qt6 6.8.2 REQUIRED COMPONENTS Core Quick Multimedia Positioning Sensors WebSockets)  # 300.2 minimum
find_package(ArcGISRuntime 300.2.0 REQUIRED COMPONENTS Cpp)   # exact installed version (INI file name)
# ... your qt_add_executable(app ...) ...
target_link_libraries(app PRIVATE Qt6::Core Qt6::Quick Qt6::Multimedia Qt6::Positioning
                                  Qt6::Sensors Qt6::WebSockets ArcGISRuntime::Cpp)
if(DEFINED ArcGISRuntime_LIBRARIES AND NOT IOS AND NOT ANDROID)   # SDK runtime libs next to the exe
  add_custom_command(TARGET app POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_if_different
                     ${ArcGISRuntime_LIBRARIES} $<TARGET_FILE_DIR:app>)
endif()
```

- The version in `find_package(ArcGISRuntime …)` selects the INI file `ArcGIS Runtime SDK for Qt <x.y.z>.ini`;
  a version that is not installed fails at configure. Take the version and Qt minimum from a freshly rendered
  template, not from memory - both change per release.
- For Android/iOS copy the corresponding blocks (`QT_ANDROID_EXTRA_LIBS`, `MapsSDKNative.jar`, frameworks) from the template.
- Register the view for QML: `qmlRegisterType<MapQuickView>("<YourUri>", 1, 0, "MapView")` before loading QML,
  or the `QML_FOREIGN` wrapper in §5 if the project uses `qt_add_qml_module`.
- Then call `ArcGISRuntimeEnvironment::setApiKey(...)` at startup (see `authentication.md`).

## 4. Toolkit (prebuilt QML UI components)

Components (300.2 `uitools/toolkitcpp`): `Authenticator`, `BasemapGallery`, `BookmarksView`, `Callout`,
`CoordinateConversion`, `FloorFilter`, `NorthArrow`, `OverviewMap`, `PopupView`, `Scalebar`, `SearchView`,
`TimeSlider`, `UtilityNetworkTrace`. Prefer these over hand-built equivalents. Widgets apps use `uitools/toolkitwidgets`.

- **Version must match the SDK.** Clone https://github.com/Esri/arcgis-maps-sdk-toolkit-qt and check out the
  tag for your SDK release (e.g. `300.2.*`). A mismatched or mixed checkout fails at configure
  (e.g. `Cannot find source file ...`) or at runtime. In 200.x the auth component was
  `AuthenticationView`; in 300.x it is `Authenticator`.

```cmake
# after the app's target_link_libraries(...)
if(NOT DEFINED ARCGIS_TOOLKIT_PATH)
  set(ARCGIS_TOOLKIT_PATH "$ENV{ARCGIS_TOOLKIT_PATH}")   # or a fixed path; -DARCGIS_TOOLKIT_PATH=... overrides
endif()
# The toolkit's Qt modules (300.2): find them here too, else "target is mentioned ... but not declared" warnings
find_package(Qt6 REQUIRED COMPONENTS QuickControls2 Svg WebView Graphs NetworkAuth)
add_subdirectory("${ARCGIS_TOOLKIT_PATH}/uitools/toolkitcpp" toolkitcpp)   # 2nd arg needed: source is outside the tree
target_link_libraries(${PROJECT_NAME} PRIVATE libtoolkitcpp Qt6::WebView)
```

```cpp
#include "Esri/ArcGISRuntime/Toolkit/register.h"
#include <QtWebView>
// in main():
QtWebView::initialize();                                    // before QGuiApplication (OAuth web view)
QGuiApplication app(argc, argv);
QQmlApplicationEngine engine;
Esri::ArcGISRuntime::Toolkit::registerComponents(engine);   // before engine.load / loadFromModule
```

```qml
import Esri.ArcGISRuntime.Toolkit
NorthArrow  { geoView: view; anchors { right: parent.right; top: parent.top; margins: 10 } }
OverviewMap { geoView: view; anchors { left: parent.left; top: parent.top; margins: 10 } }
Scalebar    { mapView: view; anchors { left: parent.left; bottom: parent.bottom; margins: 20 } }  // mapView, not geoView
Authenticator { anchors.centerIn: parent }   // handles all auth challenges, see authentication.md
```

Components bind to the **QML view item** (`MapView`/`SceneView` id), not to the C++ model.
Verified: 300.2 template + toolkit 300.2 builds and runs 10 s with no QML errors (Qt 6.8.3).
Docs: https://developers.arcgis.com/qt/toolkit/ · API: https://developers.arcgis.com/qt/toolkit/api-reference/

## 5. Coexisting with the Qt skills / migrating to `qt_add_qml_module`

The template's `qml.qrc` + `qmlRegisterType` + `engine.load("qrc:/…")` layout is intentional and works; the
`qt-cmake-project` skill calls it legacy. **Keep it** unless the user asks to migrate. A half-migration (QML moved
into `qt_add_qml_module` while `main.cpp` still loads `qrc:/qml/main.qml`) builds but fails at startup.
To migrate, change everything in one edit (verified on the 300.2 template: builds, runs, no QML errors):

1. Rename `qml/main.qml` → `qml/Main.qml` (QML type names must be capitalised); delete `qml/qml.qrc` and drop it from `SOURCE_FILES`.
2. `CMakeLists.txt`: after `find_package(ArcGISRuntime …)` add `qt_standard_project_setup(REQUIRES 6.8)`; after the
   `if(ANDROID) … else() … endif()` block that creates the executable (both branches call `qt_add_executable`) add, once,
   `qt_add_qml_module(${PROJECT_NAME} URI Esri.<Name> QML_FILES qml/Main.qml qml/<Name>Form.qml SOURCES ArcGISQmlTypes.h)`.
   Keeping URI `Esri.<Name>` means no QML import changes. Keep the icon, post-build copy, Android/iOS blocks.
3. `ArcGISQmlTypes.h` (SDK view types have no `QML_ELEMENT`, so expose them as foreign types):

```cpp
#pragma once
#include "MapQuickView.h"
#include <QtQml/qqmlregistration.h>
struct MapQuickViewForeign
{
  Q_GADGET
  QML_FOREIGN(Esri::ArcGISRuntime::MapQuickView)
  QML_NAMED_ELEMENT(MapView)
};
```

4. App class: `#include <QtQml/qqmlregistration.h>` and `QML_ELEMENT` after `Q_OBJECT`.
5. `main.cpp`: delete both `qmlRegisterType` calls; replace `engine.load(...)` with
   `engine.loadFromModule("Esri.<Name>", "Main");`. Keep the API-key code and `registerComponents` (toolkit).

## 6. qmake

`.pro` / `arcgisruntime.pri` still ship but are legacy: use CMake for new work, and do not migrate a build
system as part of an unrelated change.
