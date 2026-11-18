# API quick map (C++ API, 300.x)

Purpose: look up which classes, calls and headers a common app task needs. Every name below was checked against
the 300.2 headers. For depth, see the API reference at developers.arcgis.com/qt/cpp/api-reference/.

**Contents:** [Conventions](#conventions) · [Maps and scenes](#maps-and-scenes) · [Layers and data](#layers-and-data) ·
[Query and edit](#query-and-edit) · [Graphics and symbols](#graphics-and-symbols) · [Identify and popups](#identify-and-popups) ·
[Geometry](#geometry) · [Geocoding and routing](#geocoding-and-routing) · [Offline](#offline) ·
[Environment and auth](#environment-and-auth) · [Snippets](#snippets)

## Conventions

- Namespace `Esri::ArcGISRuntime` (auth: `Esri::ArcGISRuntime::Authentication`). Each class has its own header, `#include "ClassName.h"`.
  Auth classes are in `"Authentication/<Name>.h"`.
- **Enums are only forward-declared in class headers.** Include the `*Types.h` header named in the Headers column
  whenever you write an enum value, or the build fails.
- **Every `...Async()` returns `QFuture<T>` → `#include <QFuture>`**, even if you ignore the result.
  Continue with `.then(this, [](T r){…})`. Handle errors with `.onFailed(this, [](const ErrorException& e){…})`
  (`ErrorException.h`, `e.error().message()`).
- Results returned as raw pointers (`FeatureQueryResult*`, `IdentifyLayerResult*`, `QList<…Result*>`) belong to you:
  wrap in `std::unique_ptr` or `qDeleteAll`. Pass a `parent` where the signature has one.
- **Loadable** (layers, tables, maps, portal items, packages, geodatabases): call `load()`, or add it to a map/view,
  which loads it. Then react to `doneLoading(const Error&)` (`Error.h`, `error.isEmpty()` means success) or
  `loadStatusChanged(LoadStatus)` (`MapTypes.h`).
- **Tasks and jobs:** a *Task* (`OfflineMapTask`, `GeodatabaseSyncTask`, …) creates default parameters with
  `create…ParametersAsync()`, then a factory method returns a `Job*` (not a future). Connect `Job::statusChanged(JobStatus)`
  and `progressChanged()`, then call `job->start()`. Read `jobStatus()`, `progress()`, `error()`; `result()` is on the concrete job class (e.g. `GenerateOfflineMapJob`).
  `JobStatus` is in `TaskTypes.h`.
- These old (100.x) names no longer exist: `Basemap::topographic()` and other static basemap factories, and the
  signal-based `queryFeatures()`, `identifyLayer()`, `geocode()`. `PopupManager` was removed in 300.x (it exists in 200.x).

## Maps and scenes

| Task | Classes | Key calls | Headers |
|---|---|---|---|
| 2D map with basemap | `Map`, `Basemap` | `new Map(BasemapStyle::ArcGISTopographic, this)`; `Map(Basemap*)`; `mapView->setMap(map)` | `Map.h`, `Basemap.h`, `MapQuickView.h` (Widgets: `MapViewWidget.h`, 300.2+), **`MapTypes.h`** |
| Initial / programmatic view | `Viewpoint`, `Point`, `SpatialReference` | `Viewpoint(lat, lon, scale)` (**latitude first**); `Point(x=lon, y=lat, SpatialReference::wgs84())`; `map->setInitialViewpoint(vp)` | `Viewpoint.h`, `Point.h`, `SpatialReference.h` |
| Move the map view | `MapView` (base of `MapQuickView`) | `setViewpointAsync(vp[, seconds])`, `setViewpointCenterAsync(pt[, scale])`, `setViewpointGeometryAsync(geom[, paddingDips])`, `setViewpointScaleAsync`, `setViewpointRotationAsync` → `QFuture<bool>` | `MapView.h`, `<QFuture>`; `AnimationCurve` in `MapViewTypes.h` |
| 3D global scene + terrain | `Scene`, `Surface`, `ArcGISTiledElevationSource` | `new Scene(BasemapStyle::ArcGISImagery, this)`; `scene->baseSurface()->elevationSources()->append(new ArcGISTiledElevationSource(url, this))`; `sceneView->setArcGISScene(scene)` | `Scene.h`, `Surface.h`, `ElevationSourceListModel.h`, `ArcGISTiledElevationSource.h`, `SceneQuickView.h`, `MapTypes.h` |
| Scene camera | `Camera` | `Camera(lat, lon, altitude, heading, pitch, roll)`; `sceneView->setViewpointCameraAsync(cam)` → `QFuture<bool>` | `Camera.h`, `SceneView.h` |
| Local scene (300.x only) | `LocalSceneQuickView`, `Scene` | `Scene(SceneViewingMode::Local, …)` | `LocalSceneQuickView.h`, **`SceneViewTypes.h`**, **`MapTypes.h`** (`BasemapStyle`) |
| Screen ↔ map point | `MapView` | `screenToLocation(x, y)` → `Point`; `locationToScreen(pt)`; scene: `screenToLocationAsync(x, y)` → `QFuture<Point>` | `MapView.h`, `SceneView.h` |
| Show device location | `LocationDisplay` | `mapView->locationDisplay()->start()` / `stop()`; `setAutoPanMode(LocationDisplayAutoPanMode::Recenter)`; signal `statusChanged(bool)` | `LocationDisplay.h`, **`MapViewTypes.h`**. Request location permission first (`QLocationPermission` + `qApp->requestPermission`, see sample *DisplayDeviceLocation*). |

## Layers and data

| Task | Classes | Key calls | Headers |
|---|---|---|---|
| Feature service layer | `ServiceFeatureTable`, `FeatureLayer` | `new FeatureLayer(new ServiceFeatureTable(QUrl(".../FeatureServer/0"), this), this)`; `map->operationalLayers()->append(layer)` | `ServiceFeatureTable.h`, `FeatureLayer.h`, `LayerListModel.h` |
| Zoom to a layer | `Layer` | after `doneLoading`: `mapView->setViewpointGeometryAsync(layer->fullExtent(), 20)` | `Layer.h`, `Envelope.h`, `<QFuture>` |
| Tiled / vector tile / map image | `ArcGISTiledLayer`, `ArcGISVectorTiledLayer`, `ArcGISMapImageLayer` | ctor `(QUrl, parent)` or `(Item*, parent)`; append to `operationalLayers()` or use in `Basemap(Layer*)` | same-name `.h` |
| Scene layers (3D) | `ArcGISSceneLayer`, `IntegratedMeshLayer`, `Ogc3dTilesLayer`, `PointCloudLayer` | `scene->operationalLayers()->append(new ArcGISSceneLayer(url, this))` | same-name `.h` |
| Web map / item from a portal | `Portal`, `PortalItem` | `new PortalItem(new Portal(QUrl("https://www.arcgis.com"), this), itemId, this)`; `new Map(item, this)`; `FeatureLayer(item, layerId)` | `Portal.h`, `PortalItem.h`; `PortalItemType`, `PortalAccess` in `PortalTypes.h` |
| Shared service edits | `ServiceGeodatabase` | `new ServiceGeodatabase(url, this)` → `load()` → `table(layerId)` | `ServiceGeodatabase.h` |
| Layer list / order | `LayerListModel` | `operationalLayers()->append / insert / removeAt / clear` | `LayerListModel.h` |

## Query and edit

| Task | Classes | Key calls | Headers |
|---|---|---|---|
| Query features | `QueryParameters`, `FeatureTable`, `FeatureQueryResult` | `setWhereClause`, `setGeometry`, `setSpatialRelationship(SpatialRelationship::Intersects)`, `setReturnGeometry`, `setMaxFeatures`; `table->queryFeaturesAsync(qp, parent)` → `QFuture<FeatureQueryResult*>`; for a service table: `queryFeaturesAsync(qp, QueryFeatureFields::LoadAll, parent)` | `QueryParameters.h`, `FeatureQueryResult.h`, `FeatureIterator.h`, `ServiceFeatureTable.h`, **`GeodatabaseTypes.h`** (`QueryFeatureFields`), **`CoreTypes.h`** (`SpatialRelationship`) |
| Iterate results | `FeatureIterator` | `auto it = result->iterator(); while (it.hasNext()) { Feature* f = it.next(parent); }` (no range-for) | `FeatureIterator.h`, `Feature.h` |
| Count / extent | `FeatureTable` | `queryFeatureCountAsync(qp)` → `QFuture<quint64>`; `queryExtentAsync(qp)` → `QFuture<Envelope>` | `FeatureTable.h`, `QueryParameters.h`, `Envelope.h`, `<QFuture>` |
| Read / write attributes | `AttributeListModel` | `f->attributes()->attributeValue("NAME")`, `attributesMap()`, `replaceAttribute(name, value)`, `attributeNames()` | `AttributeListModel.h` |
| Add / update / delete | `FeatureTable` | `createFeature(QVariantMap, Geometry, parent)`; `addFeatureAsync(f)`, `updateFeatureAsync(f)`, `deleteFeatureAsync(f)` → `QFuture<void>`; check `canAdd()`, `canUpdate(f)`, `canDelete(f)` | `FeatureTable.h`, `Feature.h` |
| Push edits to the service | `ServiceFeatureTable`, `ServiceGeodatabase` | `table->applyEditsAsync()` → `QFuture<QList<FeatureEditResult*>>`; or `table->serviceGeodatabase()->applyEditsAsync()` → `QFuture<QList<FeatureTableEditResult*>>`; `undoLocalEditsAsync()` | `FeatureEditResult.h`, `FeatureTableEditResult.h`, `ServiceGeodatabase.h` |
| Select on map | `FeatureLayer` | `selectFeature(f)`, `selectFeaturesAsync(qp, SelectionMode::New)` → `QFuture<FeatureQueryResult*>` (caller deletes the result), `clearSelection()` | `FeatureLayer.h`, `MapTypes.h`, `<QFuture>` |

## Graphics and symbols

| Task | Classes | Key calls | Headers |
|---|---|---|---|
| Overlay for app graphics | `GraphicsOverlay` | `mapView->graphicsOverlays()->append(new GraphicsOverlay(this))` | `GraphicsOverlay.h`, `GraphicsOverlayListModel.h` |
| Add a graphic | `Graphic` | `overlay->graphics()->append(new Graphic(geometry, symbol, this))`; `setGeometry`, `setSymbol`, `attributes()` | `Graphic.h`, `GraphicListModel.h` |
| Point / line / fill symbols | `SimpleMarkerSymbol`, `SimpleLineSymbol`, `SimpleFillSymbol` | `(SimpleMarkerSymbolStyle::Circle, QColor, size, parent)`; `(SimpleLineSymbolStyle::Solid, QColor, width, parent)`; `(SimpleFillSymbolStyle::Solid, QColor, outlineLineSymbol, parent)` | same-name `.h` + **`SymbolTypes.h`** |
| Image / text symbol | `PictureMarkerSymbol`, `TextSymbol` | `PictureMarkerSymbol(QUrl or QImage, parent)`; `TextSymbol(text, QColor, size, HorizontalAlignment::Center, VerticalAlignment::Bottom, parent)` | same-name `.h` + **`SymbolTypes.h`** |
| Renderers (layer or overlay) | `SimpleRenderer`, `UniqueValueRenderer`, `UniqueValue` | `layer->setRenderer(new SimpleRenderer(symbol, this))`; `uvr->setFieldNames({"type"})`, `uvr->uniqueValues()->append(new UniqueValue(label, desc, QVariantList{v}, symbol, this))`, `setDefaultSymbol` | `SimpleRenderer.h`, `UniqueValueRenderer.h`, `UniqueValue.h`, `UniqueValueListModel.h` |

## Identify and popups

| Task | Classes | Key calls | Headers |
|---|---|---|---|
| Tap → screen point | `MapQuickView` | signal `mouseClicked(QMouseEvent&)`; use `e.position()` | `MapQuickView.h`, `<QMouseEvent>` |
| Identify one layer | `IdentifyLayerResult` | `identifyLayerAsync(layer, e.position(), tolerancePx, returnPopupsOnly, [maxResults,] parent)` → `QFuture<IdentifyLayerResult*>`; `result->geoElements()`, `popups()`, `sublayerResults()` | `GeoView.h`, `IdentifyLayerResult.h`, `<QFuture>` |
| Identify all layers | | `identifyLayersAsync(pt, tol, popupsOnly, parent)` → `QFuture<QList<IdentifyLayerResult*>>` | same |
| Identify graphics | `IdentifyGraphicsOverlayResult` | `identifyGraphicsOverlayAsync(overlay, pt, tol, popupsOnly, parent)`; `identifyGraphicsOverlaysAsync(...)` | `IdentifyGraphicsOverlayResult.h` |
| Read attributes | `GeoElement` | `ge->attributes()->attributesMap()`; cast to `Feature*` / `Graphic*` if needed | `GeoElement.h`, `AttributeListModel.h` |
| Popups | `Popup`, `PopupDefinition` | `result->popups()`, `popup->title()`, `evaluateExpressionsAsync()`, `evaluatedElements()`; for UI use the toolkit `PopupView` | `Popup.h`, `PopupDefinition.h`, `PopupTypes.h` |

## Geometry

| Task | Classes | Key calls | Headers |
|---|---|---|---|
| Project | `GeometryEngine` (static) | `GeometryEngine::project(geom, SpatialReference::webMercator())`; `geometry_cast<Point>(g)` | `GeometryEngine.h`, `SpatialReference.h` |
| Buffer | | `buffer(geom, distanceInSrUnits)` (planar); `bufferGeodetic(geom, dist, LinearUnit::meters(), NAN, GeodeticCurveType::Geodesic)` | `LinearUnit.h`, **`GeometryTypes.h`**, `<cmath>` (`NAN`) |
| Measure | | `distance(g1, g2)`; `lengthGeodetic(g, unit, curve)`; `areaGeodetic(g, AreaUnit, curve)`; `distanceGeodetic(p1, p2, LinearUnit, AngularUnit, curve)` | `LinearUnit.h`, `AreaUnit.h`, `AngularUnit.h`, `GeodeticDistanceResult.h`, **`GeometryTypes.h`** (`GeodeticCurveType`) |
| Relations / overlay | | `intersects`, `contains`, `intersection`, `unionOf`, `difference`, `simplify`, `nearestCoordinate` (→ `ProximityResult`) | `GeometryEngine.h`, `ProximityResult.h` |
| Build geometry | `PolylineBuilder`, `PolygonBuilder`, `Envelope` | `PolygonBuilder b(SpatialReference::wgs84()); b.addPoint(x, y); b.toPolygon()` (`toPolyline()` for lines); `Envelope(xmin, ymin, xmax, ymax, sr)` | `PolylineBuilder.h`, `PolygonBuilder.h`, `Envelope.h` |
| Interactive sketch | `GeometryEditor` | `mapView->setGeometryEditor(editor)`; `editor->start(GeometryType::Polygon)` | `GeometryEditor.h`, `GeometryEditorTypes.h`, `GeometryTypes.h` |

## Geocoding and routing

| Task | Classes | Key calls | Headers |
|---|---|---|---|
| Address → location | `LocatorTask`, `GeocodeParameters`, `GeocodeResult` | `new LocatorTask(QUrl("https://geocode-api.arcgis.com/arcgis/rest/services/World/GeocodeServer"), this)`; `geocodeAsync(text)` or **`geocodeWithParametersAsync(text, params)`** → `QFuture<QList<GeocodeResult>>` (there is no `geocodeAsync(text, params)` overload); `r.displayLocation()`, `label()`, `score()`, `extent()` | `LocatorTask.h`, `GeocodeParameters.h`, `GeocodeResult.h` |
| Location → address | `ReverseGeocodeParameters` | `reverseGeocodeAsync(pt)` / `reverseGeocodeWithParametersAsync(pt, params)` | `ReverseGeocodeParameters.h` |
| Autocomplete | `SuggestResult` | `suggestAsync(text)` → `geocodeWithSuggestResultAsync(s)` | `SuggestResult.h`, `SuggestParameters.h` |
| Route between stops | `RouteTask`, `RouteParameters`, `Stop`, `RouteResult`, `Route` | `createDefaultParametersAsync()` → `QFuture<RouteParameters>`; `params.setStops({Stop(pt1), Stop(pt2)})`, `setReturnDirections(true)`; `solveRouteAsync(params)` → `QFuture<RouteResult>`; `rr.routes().first().routeGeometry()`, `totalTime()`, `totalLength()`, `directionManeuvers()` | `RouteTask.h`, `RouteParameters.h`, `Stop.h`, `RouteResult.h`, `Route.h`, `NetworkAnalystTypes.h` |

Service URLs need an access token with the matching privileges (location services). See `authentication.md`.

## Offline

| Task | Classes | Key calls | Headers |
|---|---|---|---|
| On-demand offline map | `OfflineMapTask`, `GenerateOfflineMapParameters`, `GenerateOfflineMapJob` | `createDefaultGenerateOfflineMapParametersAsync(areaOfInterest)` → `QFuture<GenerateOfflineMapParameters>`; `generateOfflineMap(params, dir)` → `GenerateOfflineMapJob*`; on success `job->result()->offlineMap(parent)` | `OfflineMapTask.h`, `GenerateOfflineMapParameters.h`, `GenerateOfflineMapJob.h`, `GenerateOfflineMapResult.h`, `TaskTypes.h` |
| Preplanned offline map | `PreplannedMapArea`, `DownloadPreplannedOfflineMapJob` | `preplannedMapAreasAsync(parent)`; `createDefaultDownloadPreplannedOfflineMapParametersAsync(area)`; `downloadPreplannedOfflineMap(params, dir)`; `job->result()->offlineMap()` | `PreplannedMapArea.h`, `DownloadPreplannedOfflineMapParameters.h`, `DownloadPreplannedOfflineMapJob.h`, `DownloadPreplannedOfflineMapResult.h` |
| Open a mobile map package | `MobileMapPackage` | `new MobileMapPackage(path, this)` → `load()` → `doneLoading` → `maps().first()` | `MobileMapPackage.h` |
| Local geodatabase | `Geodatabase`, `GeodatabaseFeatureTable` | `new Geodatabase(path, this)` → `load()` → `geodatabaseFeatureTable(layerId or name)` → `FeatureLayer` | `Geodatabase.h`, `GeodatabaseFeatureTable.h` |
| Generate / sync geodatabase | `GeodatabaseSyncTask` | `createDefaultGenerateGeodatabaseParametersAsync(extent)`; `generateGeodatabase(params, file)` → `GenerateGeodatabaseJob*`; `syncGeodatabase(SyncDirection::Bidirectional, rollbackOnFailure, gdb)` → `SyncGeodatabaseJob*` | `GeodatabaseSyncTask.h`, `GenerateGeodatabaseJob.h`, `SyncGeodatabaseJob.h`, **`TaskTypes.h`** |
| Job lifecycle | `Job` | `statusChanged(JobStatus)`, `progressChanged()`, `jobStatus()` (not `status()`), `progress()`, `error()`, `start()`, `cancelJobAsync()` | `Job.h`, **`TaskTypes.h`** |

## Environment and auth

| Task | Classes | Key calls | Headers |
|---|---|---|---|
| Access token (API key) | `ArcGISRuntimeEnvironment` | `ArcGISRuntimeEnvironment::setApiKey(qEnvironmentVariable("ARCGIS_RUNTIME_API_KEY"))` before creating maps. Don't hard-code keys. | `ArcGISRuntimeEnvironment.h` |
| Production license | | `setLicense(licenseKey[, extensions])` → `LicenseResult` (`[[nodiscard]]`); check `licenseStatus()` | `ArcGISRuntimeEnvironment.h`, `LicenseResult.h`, `License.h`, **`CoreTypes.h`** (`LicenseStatus`) |
| User login / challenges | `Authentication::AuthenticationManager` | `ArcGISRuntimeEnvironment::authenticationManager()->setArcGISAuthenticationChallengeHandler(h)`; `OAuthUserConfiguration`, `OAuthUserCredential` (or the toolkit `Authenticator`) | `Authentication/AuthenticationManager.h`, `Authentication/ArcGISAuthenticationChallengeHandler.h`. See `authentication.md` |

## Snippets

These snippets compiled against 300.2. `this` is the app's QObject and `m_mapView` is its `MapQuickView*`.

```cpp
// Query. Needs QueryParameters.h, FeatureQueryResult.h, FeatureIterator.h, Feature.h, AttributeListModel.h,
// ServiceFeatureTable.h, GeodatabaseTypes.h, ErrorException.h, <QFuture>, <memory>.
QueryParameters qp;
qp.setWhereClause("POP2000 > 1000000");
m_table->queryFeaturesAsync(qp, QueryFeatureFields::LoadAll, this)
  .then(this, [](FeatureQueryResult* raw) {
    std::unique_ptr<FeatureQueryResult> result(raw);
    FeatureIterator it = result->iterator();
    while (it.hasNext())
      qDebug() << it.next(result.get())->attributes()->attributeValue("STATE_NAME");
  })
  .onFailed(this, [](const ErrorException& e) { qWarning() << e.error().message(); });

// Geocode and zoom. Needs LocatorTask.h, GeocodeParameters.h, GeocodeResult.h, Point.h, MapQuickView.h, <QFuture>.
GeocodeParameters gp;
gp.setMaxResults(1);
m_locator->geocodeWithParametersAsync("380 New York St, Redlands, CA", gp)
  .then(this, [this](const QList<GeocodeResult>& results) {
    if (!results.isEmpty()) m_mapView->setViewpointCenterAsync(results.first().displayLocation(), 10000);
  });

// Point graphic. Needs GraphicsOverlay(ListModel).h, Graphic(ListModel).h, SimpleMarkerSymbol.h, SymbolTypes.h, Point.h, SpatialReference.h, MapQuickView.h.
auto* overlay = new GraphicsOverlay(this);
m_mapView->graphicsOverlays()->append(overlay);
auto* sym = new SimpleMarkerSymbol(SimpleMarkerSymbolStyle::Circle, QColor(Qt::red), 12, this);
overlay->graphics()->append(new Graphic(Point(-117.19, 34.05, SpatialReference::wgs84()), sym, this));

// Job pattern. Needs OfflineMapTask.h, GenerateOfflineMap{Parameters,Job,Result}.h, TaskTypes.h, Error.h, ErrorException.h, MapQuickView.h, <QFuture>, <QDebug>.
task->createDefaultGenerateOfflineMapParametersAsync(area).then(this, [=](const GenerateOfflineMapParameters& p) {
  GenerateOfflineMapJob* job = task->generateOfflineMap(p, downloadDir);
  connect(job, &Job::statusChanged, this, [=](JobStatus s) {
    if (s == JobStatus::Succeeded) m_mapView->setMap(job->result()->offlineMap(this));
    else if (s == JobStatus::Failed) qWarning() << job->error().message();
  });
  job->start();
}).onFailed(this, [](const ErrorException& e) { qWarning() << e.error().message(); });
```
