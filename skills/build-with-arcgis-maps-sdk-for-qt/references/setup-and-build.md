# Setup, build, run, license and deploy

How to get an ArcGIS Maps SDK for Qt app configured, built, run, licensed and shipped. Facts are from SDK 300.2 (`sdk/ideintegration/ArcGISRuntime.cmake`, the project template's `cmake/FindArcGISRuntime.cmake` and `CMakeLists.txt`).

1. [SDK registration](#1-sdk-registration) · 2. [Qt kit](#2-pick-a-qt-kit) · 3. [Configure and build](#3-configure-and-build) · 4. [Troubleshooting](#4-troubleshooting) · 5. [Run](#5-run) · 6. [Verify](#6-verify-a-build) · 7. [License](#7-license) · 8. [Deploy](#8-deploy) · 9. [Links](#9-links)

## 1. SDK registration
- The SDK is an unpacked folder. You run its configure script once per SDK version (it asks you to accept the license). The script writes a registration file, `EsriRuntimeQt/ArcGIS Runtime SDK for Qt <major.minor.patch>.ini`, containing `InstallDir="<sdk root>"`, and installs the Qt Creator wizards. Where that file lives depends on the OS. `scripts/new_project.sh` finds it and prints the SDK it used.
- `cmake/FindArcGISRuntime.cmake` is copied into every project. It builds the INI file name from the version in `find_package(ArcGISRuntime 300.2.0 COMPONENTS REQUIRED Cpp)`, so that version must be registered (a missing patch counts as `.0`: `300.2` looks up `300.2.0`). A version that is not installed fails. It caches `InstallDir` as `ArcGISRuntime_INSTALL_DIR`, then includes `<InstallDir>/sdk/ideintegration/ArcGISRuntime.cmake`. That file defines the `ArcGISRuntime::Core` and `ArcGISRuntime::Cpp` targets and the `ArcGISRuntime_LIBRARIES` list.
- Hints: the `ArcGISRuntime_INSTALL_DIR` cache variable and the `ArcGISRuntimeInstall` environment variable. The environment variable is only a `HINTS` for the library and header searches *inside* `ArcGISRuntime.cmake`. It does not replace a missing INI file: configure still fails (verified).
- If the SDK folder moves or is renamed, re-run its configure script, then configure into a fresh build directory. Otherwise the cached `ArcGISRuntime_INSTALL_DIR` and library paths still point to the old location.
- Upgrading the SDK means changing the `find_package` version as well. Templates change between releases (CMake minimum, auth, toolkit wiring), so diff your project against a freshly rendered template.

## 2. Pick a Qt kit
- **Minimum Qt version:** the generated `CMakeLists.txt` checks it (`if (Qt6Core_VERSION VERSION_LESS 6.8.2) message(FATAL_ERROR ...)` in 300.2).
- **Required modules:** listed in its `find_package(Qt6 COMPONENTS REQUIRED ...)`. For 300.2 that is `Core Quick Multimedia Positioning Sensors WebSockets` (Qt Quick) or `Core Widgets Multimedia Positioning Sensors OpenGLWidgets WebSockets` (Widgets). The toolkit adds its own (`uitools/toolkitcpp/CMakeLists.txt`: `Core Gui QuickControls2 Svg WebView Graphs NetworkAuth`).
- **Check every module before choosing a kit:** `<kit>/lib/cmake/Qt6<Module>/` must exist. Do not choose by version number alone. On the test machine, 2 of 4 kits with the same compiler lacked these modules.
- **Compiler:** use the one listed in the SDK system requirements for your platform and SDK version. The SDK ships prebuilt C++ libraries (`EsriRuntimeQt`, `EsriCommonQt`, `runtimecore`), so another compiler or ABI (e.g. a MinGW kit where MSVC is required) fails at link time.
- **Architecture:** the kit's target architecture must have a folder `<sdk>/sdk/<platform>/<arch>/lib`. If it doesn't, you get `Missing library: ...`.
- **Confirm which Qt CMake actually used:** read `Qt6_DIR` in `<build>/CMakeCache.txt`. A Qt `bin` folder on `PATH` can win over an incomplete kit given in `CMAKE_PREFIX_PATH` (verified: a broken 6.9.1 prefix silently configured against 6.8.3).

## 3. Configure and build
Use one out-of-tree build directory per build type, a single-config generator and an explicit build type:
```sh
cmake -S <project> -B <project>/build-debug -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH=<qt-kit-dir>
cmake --build <project>/build-debug
```
- **Why an explicit build type:** `ArcGISRuntime.cmake` picks debug libraries **at configure time**:
  `if(${CMAKE_SYSTEM_NAME} STREQUAL Windows AND CMAKE_BUILD_TYPE MATCHES Debug) set(ArcGISRuntime_DEBUG_POSTFIX "d")`. That selects `EsriCommonQtd` / `EsriRuntimeQtd`; only Windows ships separate debug libraries.
- **Why not a multi-config generator:** Visual Studio, Xcode and Ninja Multi-Config leave `CMAKE_BUILD_TYPE` empty, so the release SDK libraries are linked into the Debug config, which causes debug/release runtime mismatch link errors.
- **Why one build directory per type:** `find_library`/`find_file` cache the library paths. Re-running configure in an existing directory with another `CMAKE_BUILD_TYPE` keeps the old libraries (verified: Debug→Release kept `EsriRuntimeQtd.lib` and failed with `LNK2038 ... '_ITERATOR_DEBUG_LEVEL'` / `'RuntimeLibrary'`).
- **Compiler environment:** run with the kit's compiler as the active one, because Ninja uses whatever compiler the environment provides. Qt Creator does this for you.
- **The project must configure with exactly the flags above, as committed.** Do not add machine-specific workarounds: no `-DArcGISRuntime_INSTALL_DIR=`, no `-DQt6_DIR=`, no edits to `FindArcGISRuntime.cmake`. If more is needed, fix the environment (registration, kit, compiler), not the project.

## 4. Troubleshooting
| Error (verbatim prefix) | Cause | Fix |
|---|---|---|
| `module /sdk/ideintegration/ArcGISRuntime.cmake does not exist. Run the configure script and clear the CMake cache.` (empty path before `/sdk`) | No INI file for exactly the `find_package(ArcGISRuntime <ver>)` version: configure not run, a different SDK version is installed, or a version typo | Run that SDK's configure script, or set the version to one that is installed (re-check against the template). Then use a fresh build dir |
| Same message with a real path in front | The INI file points to an SDK folder that was moved or deleted | Re-run configure from the new location; fresh build dir |
| `Missing ArcGIS Maps install location in configuration file. Run the configure script ...` | The INI file exists but has no `InstallDir=` | Re-run configure |
| `Missing library: ArcGISRuntime_<Name>-NOTFOUND` | No `sdk/<platform>/<arch>/lib` for the kit's target (wrong architecture, or no SDK installed for that target platform) | Use a kit/arch the SDK ships, or install the SDK for that platform |
| `Failed to find required Qt component "<M>"` | The kit lacks a required module | Add the module with Qt's maintenance tool, or pick another kit (§2) |
| `Could not find a package configuration file provided by "Qt6"` | `CMAKE_PREFIX_PATH` is not a complete Qt kit | Point it at the kit root (`<qt>/<version>/<compiler>`) |
| `This version of the ArcGIS Maps SDK for Qt requires at least Qt <x>` | The kit is too old | Use a newer kit |
| Unresolved/undefined Esri or Qt symbols at link time | Unsupported compiler/ABI for the prebuilt SDK | Use the compiler listed in the system requirements |
| Debug/release runtime mismatch (`LNK2038 _ITERATOR_DEBUG_LEVEL`, `RuntimeLibrary`) | Multi-config generator, or build type changed in an existing build dir | Ninja + explicit `CMAKE_BUILD_TYPE`, one build dir per type |
| `use of undefined type 'QFuture<...>'`, incomplete enum type | Forward-declared types | `#include <QFuture>` / the enum's `*Types.h` (see `common-mistakes.md`) |

## 5. Run
- The template's post-build step copies `${ArcGISRuntime_LIBRARIES}` (the `EsriCommonQt` and `runtimecore` shared libraries) next to the executable on desktop. Keep that step when you edit `CMakeLists.txt`.
- The **Qt** shared libraries and plugins must be findable at runtime. Run from Qt Creator, put the kit's library folder on the library search path, or run Qt's deployment tool (§8). Use libraries from the same kit you built with.
- Access token: the generated `main.cpp` reads `ARCGIS_RUNTIME_API_KEY` and calls `ArcGISRuntimeEnvironment::setApiKey()`. If the variable is empty, it prints a warning and basemap styles and other location services fail. Set it in the run environment (shell or Qt Creator run settings), never in source. See `authentication.md`.
- Set `QT_FORCE_STDERR_LOGGING=1` when capturing output. Otherwise Qt may send warnings to a system log instead of a redirected stderr.

## 6. Verify a build
1. Configure from scratch with the generic command (§3) and build.
2. Launch with a time limit (~10 s) and capture stderr. A process that is still running does **not** prove success: a QML load failure leaves the process running with no window (verified).
3. Scan the output:

| Output | Meaning |
|---|---|
| `QQmlApplicationEngine failed to load component`, `... is not a type`, `module "..." is not installed` | QML failed to load |
| `Use of ArcGIS location services ... requires you to authenticate ...` | `ARCGIS_RUNTIME_API_KEY` is not set |
| `An ArcGIS authentication error occurred when accessing <url>` | Token missing, invalid or lacking privileges |
| `GPU shaders must be deployed when targeting Direct3D or Metal ...` | Shaders folder missing (§8) |
| "Licensed for Developer Use Only" watermark | Expected until a license is set (§7) |

4. Report only the checks that ran (e.g. "built; launched 10 s; no QML or auth errors"). Do not claim "the map displays" unless someone looked at it.

## 7. License
- No license is needed for development. Without one, views show a "Licensed For Developer Use Only" watermark. Production apps need a level: **Lite** (free with an ArcGIS account), **Basic**, **Standard** or **Advanced**, plus optional extensions (Analysis, Advanced Editing, StreetMap Premium). The level decides which capabilities work, e.g. local data and analysis need Standard. See the license-levels page.
- **A license string is not an API key.** The API key or user authentication authorizes access to services and items; the license sets the capability level. A production app usually needs both.
- API (`ArcGISRuntimeEnvironment.h`). All overloads are `[[nodiscard]] static LicenseResult`:
  `setLicense(const QString& licenseKey)`, `setLicense(const QString& licenseKey, const QStringList& extensions)`, and `setLicense(const LicenseInfo&)`. The `LicenseInfo` comes from `Portal::fetchLicenseInfoAsync()` after sign-in; that license travels with the user, and you persist it with `toJson()` / `LicenseInfo::fromJson()`. `ArcGISRuntimeEnvironment::license()` returns a `License*` (`licenseLevel()`, `licenseStatus()`, `expiry()`).
- Call `setLicense` early in `main()`, before creating maps or loading QML. The template's commented `setLicense("...")` line discards the result; assign it and check it:
```cpp
#include "ArcGISRuntimeEnvironment.h"
#include "CoreTypes.h"      // LicenseStatus, LicenseLevel
#include "Error.h"
#include "LicenseResult.h"

QObject::connect(ArcGISRuntimeEnvironment::instance(), &ArcGISRuntimeEnvironment::errorOccurred,
                 [](const Error& e) { qWarning() << "Licensing:" << e.message() << e.additionalMessage(); });
const LicenseResult result = ArcGISRuntimeEnvironment::setLicense(licenseString);
if (result.licenseStatus() != LicenseStatus::Valid)
  qWarning() << "License status" << static_cast<int>(result.licenseStatus());
```
- An invalid string returns `LicenseStatus::Invalid` and nothing is thrown. The level stays `Developer` and the app keeps running with the watermark (verified), so always check the result.

## 8. Deploy
- **Desktop:** build Release in its own build dir. Run Qt's deployment tool for your platform, giving it the QML source dir so QML imports are collected. Add the SDK shared libraries (already next to the executable after the build). The template has no `install()` rules; packaging is up to you.
- **Shaders:** when the view renders with Direct3D or Metal (Qt Quick views on those platforms), copy the SDK's `sdk/<platform>/<arch>/shaders` folder into the app's `shaders` folder; the Deployment page gives the per-platform location. Qt Widgets (OpenGL) views and OpenGL/GL ES renderers need no shaders.
  - A developer machine hides a missing folder: the runtime falls back to the registered SDK install. Verified: a copied app without shaders still logged `Shaders found: <sdk>/.../shaders`. Check that the logged path is inside your deployment, or test on a machine without the SDK.
- **Android:**
  - The template adds `${ArcGISRuntime_LIBRARIES}` to `QT_ANDROID_EXTRA_LIBS` and copies `MapsSDKNative.jar` into `android-build-<target>/libs`.
  - You supply OpenSSL: uncomment the template's `include(<android_openssl>/CMakeLists.txt)` line (KDAB android_openssl) or add `libssl`/`libcrypto` to `ANDROID_EXTRA_LIBS`. Until then, configure warns `openssl libraries are missing ...`.
  - `FindArcGISRuntime.cmake` sets `QT_PROMOTE_TO_GLOBAL_TARGETS` on Android so the toolkit's WebView plugin deploys.
  - Package with `androiddeployqt` (APK/AAB). Use the NDK/JDK versions from the system requirements.
- **iOS:**
  - The SDK links statically, plus the `Runtimecore` framework, which carries the shaders. The template embeds that framework (`XCODE_EMBED_FRAMEWORKS`, code-sign on copy, rpath `@executable_path/Frameworks`), links `CoreLocation`, calls `qt_add_ios_ffmpeg_libraries`, and sets `CMAKE_OSX_DEPLOYMENT_TARGET` (iOS 18.0, macOS 15.0 in 300.2).
  - Build with the Xcode generator, then archive in Xcode.
- Esri and data attribution is required in every deployed app.

## 9. Links
- System requirements (choose your SDK version): https://developers.arcgis.com/qt/system-requirements/
- Install and set up: https://developers.arcgis.com/qt/install-and-set-up/
- License and deployment: https://developers.arcgis.com/qt/license-and-deployment/ — [license levels](https://developers.arcgis.com/qt/license-and-deployment/license-levels-and-capabilities/), [get a license](https://developers.arcgis.com/qt/license-and-deployment/get-a-license/), [use a license in your app](https://developers.arcgis.com/qt/license-and-deployment/use-a-license-in-your-app/), [deployment](https://developers.arcgis.com/qt/license-and-deployment/deployment/)
- Qt deployment: https://doc.qt.io/qt-6/deployment.html · Android OpenSSL: https://doc.qt.io/qt-6/android-openssl-support.html
