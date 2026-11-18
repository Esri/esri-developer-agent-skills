# C++ / QML app patterns (ArcGIS Maps SDK for Qt 300.x)

How to structure app code: a C++ model owns the map, QML owns the view; QFuture async, Loadable, ownership.
Contents: 1 Architecture · 2 Ownership · 3 Loadable · 4 QFuture async · 5 Worked example · 6 QML exposure · 7 Widgets · 8 WRONG/RIGHT

## 1. Architecture (the template and the samples)

- **C++ only.** The QML API (`import Esri.ArcGISRuntime 100.x`, `Map { BasemapTopographic {} }`) was removed at 200.0.
  QML holds only the view item plus your UI; all SDK objects live in C++.
- **View in QML, model in C++.** `main.cpp` registers the view and your model under one URI (no `QML_ELEMENT` on SDK types):
  `qmlRegisterType<MapQuickView>("Esri.<Project>", 1, 0, "MapView");` and `qmlRegisterType<<Project>>("Esri.<Project>", 1, 0, "<Project>");`
  Scenes: `SceneQuickView` as `SceneView`; local scenes (300.x only): `LocalSceneQuickView` as `LocalSceneView`.
- **Hand the view to the model** through a `Q_PROPERTY` setter; the setter calls `setMap()` and wires view signals.
  The pointer type is forward-declared, so moc needs `Q_MOC_INCLUDE("MapQuickView.h")` (or `SceneQuickView.h` …).
- **State to QML:** `Q_PROPERTY(... NOTIFY ...)`. **Actions from QML:** `Q_INVOKABLE` methods. No SDK calls from JS.
- Many samples derive from `QQuickItem` and `findChild<MapQuickView*>("mapView")` instead; prefer the template pattern.

```qml
MapView { id: view; anchors.fill: parent; focus: true }   // focus: keyboard navigation
MyApp   { id: app; mapView: view }   // template names this id "model": rename it, see §8
```

## 2. Object ownership

| Object | Owner / rule |
|---|---|
| `Map`, `Scene`, layers, tables, overlays, symbols, renderers, tasks | Create with a QObject parent (`this`), as all samples do; do not rely on the list you append them to (`operationalLayers()`, `graphicsOverlays()`, `graphics()`) for lifetime. |
| View (`MapQuickView`) | Owned by QML. Never `delete` it; never `new` it in C++ for a Quick UI. |
| Pointer results of `...Async()` (`IdentifyLayerResult*`, `FeatureQueryResult*`, `QList<...Result*>`) | Unparented: **you delete them**. Samples: `std::unique_ptr<T> r(raw);` or `qDeleteAll(results);` (use `QScopeGuard` for lists). Many such methods take an optional `QObject* parent`: pass one only for results you keep, or per-click results pile up until the parent dies. |
| `GeoElement`s / `Feature`s inside a result | Children of the result: they die with it. To keep one: `feature->setParent(this);` before the result is deleted. |
| `FeatureIterator::next(QObject* parent = nullptr)` | Unparented feature: parent it or delete it. |
| Graphics removed with `graphics()->clear()` / `removeOne()` | Removed, **not deleted**. Samples parent graphics to a throwaway `QObject* m_graphicParent` and `delete` it after `clear()`. |
| Value types (`Point`, `Geometry`, `Viewpoint`, `Error`, `QueryParameters`) | Plain values; copy freely; no parent. |

## 3. Loadable lifecycle (`Map`, `Scene`, layers, tables, portal items, tasks …)

- API: `load()`, `retryLoad()`, `cancelLoad()`, `loadStatus()`, `loadError()`; signals `doneLoading(const Error&)`,
  `loadStatusChanged(LoadStatus)`. `LoadStatus` is defined in `MapTypes.h` (`Loaded`, `Loading`, `FailedToLoad`, `NotLoaded`, `Unknown`).
- `setMap()` on a view loads the map and its layers; you do not call `load()` for those. A table or task used **outside**
  a map (a standalone `ServiceFeatureTable`, a `LocatorTask`) has nobody to load it: call `load()` before reading its metadata.
- `load()` is idempotent (a second call joins the same attempt and never retries a failure); `retryLoad()` retries
  after `FailedToLoad`; `cancelLoad()` moves a `Loading` resource to `FailedToLoad`.
- **Connect before loading**, then check the error. Gate work that needs metadata (`fullExtent()`, fields) on `Loaded`:

```cpp
connect(layer, &FeatureLayer::doneLoading, this, [this](const Error& e) {
  if (!e.isEmpty()) { qWarning() << e.message() << e.additionalMessage(); return; }   // #include "Error.h"
  /* layer metadata is valid here */ });
```
- A failed operational layer does not fail the map: check each layer. Most SDK objects (and the view) emit `errorOccurred(const Error&)`.

## 4. Async with QFuture (300.x)

- Every `...Async()` returns `QFuture<T>`; `#include <QFuture>` (forward-declared in SDK headers: C2027 otherwise).
- Continue with a **context object**: `.then(this, [this](T result){...})` runs on `this`'s (GUI) thread; the chain
  is canceled if `this` is destroyed (without a context the lambda may run on a dead object).
- Errors arrive as an exception: `.onFailed(this, [](const ErrorException& e){ e.error().message(); })`
  (`#include "ErrorException.h"`). Attach `onFailed` to every chain (Esri's best-practices guidance).
  Some result types also carry an `error()` (e.g. `IdentifyLayerResult::error()`): check both.
- Never `waitForFinished()` / `result()` on the GUI thread: it freezes the UI; continuations are the supported pattern.
- Overlapping requests (typing, repeated clicks): keep the `QFuture` member, `cancel()` the old one before starting a
  new one (toolkit `LocatorSearchSource`), use `isRunning()` for a busy flag; `.onCanceled(this, ...)` if you must react.
- Long-running work (offline map, export tiles, geoprocessing) is a `Job`: connect `statusChanged(JobStatus)` (`TaskTypes.h`),
  then `start()`; cancel with `cancelJobAsync()`. See https://developers.arcgis.com/qt/programming-patterns/tasks-and-jobs/.

## 5. Worked example: feature layer + identify on click + graphic (compiled against 300.2)

Header: forward-declare the SDK classes **and `class QMouseEvent;`**; `Q_MOC_INCLUDE("MapQuickView.h")`; `#include <QFuture>` for the
`QFuture<IdentifyLayerResult*> m_identifyFuture` member; `Q_PROPERTY(QStringList attributeLines ... NOTIFY ...)`; `Q_INVOKABLE void zoomToLayer();`.

```cpp
#include "AttributeListModel.h"  // Feature::attributes() return type
#include "Envelope.h"            // Layer::fullExtent() return type
#include "ErrorException.h"
#include "Feature.h"
#include "FeatureLayer.h"
#include "Graphic.h"
#include "GraphicListModel.h"
#include "GraphicsOverlay.h"
#include "GraphicsOverlayListModel.h"
#include "IdentifyLayerResult.h"
#include "LayerListModel.h"
#include "Map.h"
#include "MapQuickView.h"
#include "MapTypes.h"            // BasemapStyle, LoadStatus
#include "Point.h"
#include "ServiceFeatureTable.h"
#include "SimpleMarkerSymbol.h"
#include "SymbolTypes.h"         // SimpleMarkerSymbolStyle
#include "Viewpoint.h"
#include <QFuture>
#include <QMouseEvent>
#include <memory>
using namespace Esri::ArcGISRuntime;

MyApp::MyApp(QObject* parent) : QObject(parent), m_map(new Map(BasemapStyle::ArcGISTopographic, this)) {
  auto* table = new ServiceFeatureTable(QUrl("https://.../FeatureServer/0"), this);
  m_featureLayer = new FeatureLayer(table, this);
  m_map->operationalLayers()->append(m_featureLayer);
  m_map->setInitialViewpoint(Viewpoint(34.05, -118.25, 500000));   // latitude first
  m_overlay = new GraphicsOverlay(this);
  m_symbol = new SimpleMarkerSymbol(SimpleMarkerSymbolStyle::Circle, Qt::red, 10.0f, this);
  m_graphicParent = new QObject(this);                               // owns the click graphics
}
void MyApp::setMapView(MapQuickView* view) {
  if (!view || view == m_mapView) return;
  m_mapView = view;
  m_mapView->setMap(m_map);                                          // starts loading map + layers
  m_mapView->graphicsOverlays()->append(m_overlay);
  connect(m_mapView, &MapQuickView::mouseClicked, this, &MyApp::onMouseClicked);
  emit mapViewChanged();
}
void MyApp::onMouseClicked(QMouseEvent& event) {
  const Point p = m_mapView->screenToLocation(event.position().x(), event.position().y());
  m_overlay->graphics()->append(new Graphic(p, m_symbol, m_graphicParent));
  if (m_featureLayer->loadStatus() != LoadStatus::Loaded) return;
  m_identifyFuture.cancel();
  m_identifyFuture = m_mapView->identifyLayerAsync(m_featureLayer, event.position(), 12.0, false, 1);
  m_identifyFuture.then(this, [this](IdentifyLayerResult* raw) {
    std::unique_ptr<IdentifyLayerResult> result(raw);                // we own it
    m_attributeLines.clear();
    if (result && result->error().isEmpty() && !result->geoElements().isEmpty()) {
      auto* feature = static_cast<Feature*>(result->geoElements().constFirst());
      for (const QString& name : feature->attributes()->attributeNames())
        m_attributeLines << name + ": " + feature->attributes()->attributeValue(name).toString();
      m_featureLayer->clearSelection();
      m_featureLayer->selectFeature(feature);
    }
    emit attributeLinesChanged();
  }).onFailed(this, [this](const ErrorException& e) { setStatus(e.error().message()); });
}
void MyApp::zoomToLayer() {
  if (m_mapView && m_featureLayer->loadStatus() == LoadStatus::Loaded)
    m_mapView->setViewpointGeometryAsync(m_featureLayer->fullExtent(), 20.0);
}
```
- Other identify forms: `identifyLayersAsync` (all layers, `QList<IdentifyLayerResult*>`, sublayer results nested),
  `identifyGraphicsOverlayAsync(overlay, pos, tol, false, max)` → `IdentifyGraphicsOverlayResult*` with `graphics()`.
- Scenes: `SceneView::screenToLocationAsync(x, y)` returns `QFuture<Point>`; `screenToBaseSurface(x, y)` is synchronous.
- Graphic rendering: per-graphic symbol (above) or one `SimpleRenderer` via `GraphicsOverlay::setRenderer()`.
  Polylines/polygons: `PolylineBuilder` / `PolygonBuilder` + `toGeometry()` (`#include "Geometry.h"`).

## 6. Exposing results to QML

- Flat data: `QString` / `QStringList` / `QVariantList` / `bool` properties with NOTIFY (emit after mutating); a busy flag
  backed by `m_future.isRunning()`. Never hand QML a `Feature*` / result pointer that is deleted after the continuation.
- Row-wise lists: `Q_PROPERTY(QAbstractListModel* ...)` (your model, or an SDK model such as `LayerListModel*` whose owner lives on).

## 7. Widgets note

300.2 adds `MapViewWidget` / `SceneViewWidget` / `LocalSceneViewWidget` (same `setMap()`, `mouseClicked`, identify API); `MapGraphicsView` /
`SceneGraphicsView` (200.x–300.1) are deprecated in 300.2, removal announced for 300.4. Create the widget in C++ with a parent
(`new MapViewWidget(this)`, `setCentralWidget(...)`): no `Q_PROPERTY` hand-off, no `qmlRegisterType`. Everything else here applies.

## 8. WRONG / RIGHT

| WRONG | RIGHT (why) |
|---|---|
| `connect(view, &MapQuickView::identifyLayerCompleted, …); view->identifyLayer(…)` | `view->identifyLayerAsync(…).then(this, …)` (`…Completed(QUuid, …)` signals and `TaskWatcher`: deprecated in 200.x, gone in 300.x) |
| `.then([this](auto r){…})` | `.then(this, [this](auto r){…})` (GUI thread; chain canceled if `this` dies) |
| `.then(this, …)` with no failure path | add `.onFailed(this, [](const ErrorException& e){…})` |
| raw `IdentifyLayerResult*` never deleted / `qDeleteAll` forgotten | `std::unique_ptr` or `qDeleteAll` (leak per click) |
| keep `result->geoElements()[0]` in a member | `feature->setParent(this)` first (dies with the result) |
| `graphics()->clear()` to free graphics | `clear()` then delete their parent (clear only removes) |
| `layer->fullExtent()` right after `append()` | wait for `doneLoading` / `LoadStatus::Loaded` (empty until loaded) |
| `void onClick(QMouseEvent&);` in a header with no declaration | add `class QMouseEvent;` (SDK headers do not provide it) |
| only `FeatureLayer.h` included, using `fullExtent()` / `attributes()` | include `Envelope.h` / `AttributeListModel.h` (return types are forward-declared: C2027) |
| delegate calls `model.zoomToLayer()` (template's `id: model`) | rename the id (`id: app`): inside a delegate `model` is the delegate's model data |
| `new MapQuickView()` in C++, or `setMap()` before QML set the view | view comes from QML via the property setter; call `setMap()` there |
