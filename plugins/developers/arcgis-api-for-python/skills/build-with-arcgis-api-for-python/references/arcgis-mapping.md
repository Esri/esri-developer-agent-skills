# Mapping with arcgis-mapping (`arcgis.map`)

Load this reference for authoring, editing or visualizing Web Maps and Web Scenes, including their layers and presentation. Other ArcGIS workflows do not need these APIs. Keep installation, authentication and environment setup in the main skill.

The distribution is **`arcgis-mapping`**; its Python import namespace is always **`arcgis.map`**, including its submodules:

```python
from arcgis.map import Map, Scene
```

Do not use `arcgis.mapping`, `arcgis_mapping`, or the distribution name as an import. As noted in the [deprecation notices](https://developers.arcgis.com/python/latest/guide/deprecation-notices/), `arcgis.mapping` was deprecated in 2.4.0 and removed in 2.4.2. Use `Map`/`Scene`, not legacy `WebMap`/`WebScene` examples. Follow the main skill's version-aware documentation policy; check both installed distributions rather than assuming their version numbers match.

## Documentation by task

| Task | Documentation |
| --- | --- |
| Choose Map or Scene and inspect methods/properties | [arcgis.map API reference](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html) |
| Open, modify and persist Web Maps/Web Scenes | [Working with web maps and web scenes](https://developers.arcgis.com/python/latest/guide/working-with-web-maps-and-web-scenes/) |
| Understand notebook visualization | [Introduction to the map module](https://developers.arcgis.com/python/latest/guide/part1-introduction-to-using-the-map-widget/) |
| Add services, local data and geometries | [Visualizing spatial data on the map](https://developers.arcgis.com/python/latest/guide/part3-visualizing-spatial-data-on-the-map-widget/) |
| Build model-based symbology | [Advanced cartography, part 2](https://developers.arcgis.com/python/latest/guide/advanced-cartography-part2/) |
| Configure renderers, symbols, popups and Field Maps forms | [Model and manager APIs](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html) |
| Follow a complete Map and Scene publishing example | [Publishing web maps and web scenes sample](https://developers.arcgis.com/python/latest/samples/publishing-web-maps-and-web-scenes/) |

Use the API reference for parameter contracts and the guides/samples for workflows. Some guide prose retains legacy names or differs from current signatures; verify against the installed version before copying a call.

## Open and visualize

Create new content with `m=Map(gis=gis)` or `s=Scene(gis=gis)`. Use portal `Item` objects in these examples; do not assume `item.get_data()` dictionaries are accepted as constructor inputs. A complete web-map/scene JSON document, a layer dictionary and a Pydantic model are not interchangeable.

Evaluate `m` or `s` in a supported notebook cell to display the interactive widget. Scripts can author/manage content without displaying a widget. Use the current [notebook architecture guidance](https://developers.arcgis.com/python/latest/guide/part1-introduction-to-using-the-map-widget/) for JupyterLab/Notebook compatibility. `gis.map(..., mode="2D")` and `gis.map(..., mode="3D")` select Map and Scene respectively; do not treat `mode` as a mutable Map property.

The `Map` and `Scene` constructors take in existing WebMap or WebScene Items but do not accept any widget parameters such as basemap, zoom, extent, or scale. These must be set after initialization. 

## Manage data through content managers

Use `m.content` ([MapContent](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.map_widget.MapContent)) and `s.content` ([SceneContent](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.scene_widget.SceneContent)); do not construct these managers yourself.

### Adding data: Map and Scene have different contracts

| Parameter | MapContent.add | SceneContent.add |
| --- | --- | --- |
| `item` | Documented union: `Item`, `Layer`, `Table`, `FeatureCollection`, `DataFrame`, `list`, `str` | `Item` or `Layer`; do not assume Map's broader inputs work |
| `drawing_info` | Dictionary | Dictionary |
| `popup_info` | `PopupInfo` model | Dictionary |
| `index` | Optional integer insertion index | Optional integer insertion index |
| `options` | Dictionary or `LayerOptions` | Not in the documented signature |

See [MapContent.add](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.map_widget.MapContent.add) and [SceneContent.add](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.scene_widget.SceneContent.add) for the installed version's exact contracts and supported layer types. Both return `None`; inspect the manager afterward rather than treating the return value as a layer.

- A single-layer service Item becomes the appropriate layer. A multi-layer service Item becomes a **GroupLayer**, occupying one top-level index. A list of layers also creates a GroupLayer in Map. To keep service layers separate, add each member of `service_item.layers` individually, as in the publishing sample.
- Use a **spatially enabled** DataFrame, not an arbitrary nonspatial pandas DataFrame. The visualization guide also demonstrates `sdf.spatial.plot(map_widget=m)`.
- For queried features, an explicitly typed route is `FeatureCollection.from_featureset(feature_set)` from `arcgis.features`, followed by `m.content.add(collection)`. The guide demonstrates direct FeatureSet addition, but the published `add` union omits it; verify that path for the installed version.
- For geometry/graphics use [MapContent.draw](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.map_widget.MapContent.draw), which creates a FeatureCollection layer. Match the geometry's spatial reference to the map. Do not assume SceneContent has a corresponding `draw` method.
- The map's spatial reference derives from its basemap; verify layer rendering/projection. Local Raster inputs may render as MediaLayer but cannot be saved into a Web Map.
- A `str` in the Map signature is not a guarantee that arbitrary URLs, paths or JSON strings are valid. Check the specific data source's documented workflow. Scene's supported 3D layers/symbols also need separate verification.

### Inspect, edit and remove

Inspect `.content.layers` and `.content.tables`. Layer indices are zero-based; inspect the actual order and grouping before changing anything. `get_layer(title)` returns the first matching layer, so titles are not reliable unique identifiers.

| Operation | Map | Scene |
| --- | --- | --- |
| Inspect layer index metadata | `m.content.layer_info` property (DataFrame) | `s.content.layer_info()` method (list of dictionaries) |
| Look up a table | `m.content.get_table(title)`; inspect `table_info` | Do not assume these Map-only helpers exist |
| Remove a layer | `m.content.remove(index=i)` | `s.content.remove(index=i)` |
| Remove a table | `m.content.remove(index=i, is_layer=False)` | `s.content.remove(index=i, is_layer=False)` |
| Edit layer presentation | `m.content.update_layer(index=i, ...)` | `s.content.update_layer(index=i, ...)` with a narrower parameter set |
| Reorder or group | `reposition`, `reposition_to_top`, `move` | Do not assume Map's methods exist |

Check removal's boolean result. Use `index=`, not legacy examples passing an undocumented `layer=` argument. Reinspect indices after additions, moves or removals.

Both [MapContent.update_layer](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.map_widget.MapContent.update_layer) and [SceneContent.update_layer](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.scene_widget.SceneContent.update_layer) accept renderer models, labeling dictionaries, `scale_symbols`, and `transparency` (0-100). Map additionally accepts `options` (dictionary or `LayerOptions`) and `form` (`FormInfo`). Scene does not document those two parameters. Fractional layer `opacity` is not the same scale as `transparency`.

Map's `update_layer` does not handle GroupLayer indices; use the [GroupLayer API](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.layers.GroupLayer) for child-layer changes. Editing map presentation does not edit source feature records; use the feature editing APIs for data changes.

## Pydantic v2 models: renderers, symbols, popups and forms

These interfaces use **Pydantic v2 models**, not just untyped JSON. Import models from the public `arcgis.map.renderers`, `arcgis.map.symbols`, `arcgis.map.popups` and `arcgis.map.forms` namespaces, not internal `dataclasses.models` paths shown in some outputs.

### Choose the type at each boundary

| Boundary | What to pass |
| --- | --- |
| `m.content.add(..., drawing_info=...)` | A dictionary wrapper such as `{"renderer": renderer_model}`; the reference explicitly describes a renderer model as the value |
| `s.content.add(..., drawing_info=...)` | A dictionary wrapper containing a renderer dictionary, as documented in the Scene examples |
| `m.content.add(..., popup_info=...)` | A `PopupInfo` model |
| `s.content.add(..., popup_info=...)` | A popup dictionary with web-specification keys |
| Either manager's `update_layer(..., renderer=...)` | A supported renderer model, not a generic renderer dictionary |
| `m.content.draw(..., symbol=..., popup=..., attributes=...)` | A symbol model, a `PopupInfo` model, and an attributes dictionary respectively |
| `m.content.popup_manager(index=i).info = ...` | A `PopupInfo` model; `PopupManager.edit` also takes typed field/expression/element lists |
| `m.content.update_layer(..., form=...)` | A `FormInfo` model; dictionary acceptance is not documented |
| Service-layer `FeatureLayer.renderer` or supported `arcgis.layers` renderer setters | A dictionary; this is a different interface from `content.update_layer` |

The current `update_layer(renderer=...)` union is `SimpleRenderer`, `HeatmapRenderer`, `PieChartRenderer`, `ClassBreaksRenderer`, `UniqueValueRenderer`, `DotDensityRenderer`, or `DictionaryRenderer`. Do not infer that every renderer listed elsewhere is accepted by that method, or that every renderer/symbol combination works for every geometry or 3D layer.

Sources: the two content-manager `add`/`update_layer` references above, [draw](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.map_widget.MapContent.draw), [PopupManager.info](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.popups.PopupManager.info), [PopupManager.edit](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.popups.PopupManager.edit), and [FeatureLayer.renderer](https://developers.arcgis.com/python/latest/api-reference/arcgis.features.toc.html#arcgis.features.FeatureLayer.renderer). For other layer classes, verify their own setter contracts in the [arcgis.layers reference](https://developers.arcgis.com/python/latest/api-reference/arcgis.layers.toc.html).

### Build and apply models

For an existing polygon layer at a verified index, this pattern follows the [advanced cartography guide](https://developers.arcgis.com/python/latest/guide/advanced-cartography-part2/):

```python
from arcgis.map.renderers import SimpleRenderer
from arcgis.map.symbols import (
    SimpleFillSymbolEsriSFS,
    SimpleFillSymbolStyle,
    SimpleLineSymbolStyle,
)
from arcgis.map.popups import PopupInfo

renderer = SimpleRenderer(
    symbol=SimpleFillSymbolEsriSFS(
        color=[211, 84, 0, 175],
        outline={
            "type": "esriSLS",
            "style": SimpleLineSymbolStyle.esri_sls_dash_dot_dot,
            "color": [255, 255, 255, 255],
            "width": 0.75,
        },
        style=SimpleFillSymbolStyle.esri_sfs_solid,
    )
)
m.content.renderer_manager(index=0).renderer = renderer
popup = PopupInfo(title="{NAME}", show_attachments=True)
m.content.popup_manager(index=0).info = popup
```

Replace `NAME` with an actual field and choose symbols for the layer's geometry. Nested model instances, dictionaries and enums can be combined **where the model schema accepts them**; this does not mean all API parameters accept arbitrary dictionaries. See [SimpleRenderer](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.renderers.SimpleRenderer), [symbols](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.symbols.SimpleFillSymbolEsriSFS), and [PopupInfo](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.popups.PopupInfo) for fields, discriminators and defaults.

For additional popup editing, use typed models such as `FieldInfo` and `PopupElementText`. Map's older `content.renderer()`, `content.popup()` and `content.form()` accessors are deprecated from 2.4.3; prefer `renderer_manager()`, `popup_manager()` and `form_manager()`. Scene's reference separately documents `s.content.popup(index=i).info` for model-based popup editing; verify its version-specific accessor rather than assuming Map/Scene naming parity.

### Validate and serialize only when required

- Construct with `Model(...)`, validate a Python dictionary with `Model.model_validate(data)`, or validate JSON text with `Model.model_validate_json(text)`. Surface validation errors and correct the input; do not bypass them with `model_construct()`.
- Use `model.model_dump(mode="json", by_alias=True, exclude_none=True)` when a boundary requires a JSON-compatible **dictionary**, for example a documented service-layer renderer setter or Scene's dictionary-based addition parameters.
- Use `model.model_dump_json(...)` only when the target requires a JSON **string**. It is not interchangeable with a dictionary.
- Pass model instances directly where required; indiscriminately dumping every model loses the documented contract. Conversely, do not send a model to a dictionary-only interface.
- `model_copy(update=...)` does not validate update values. Revalidate changed data if validation is required.

The [API's inherited Pydantic v2 methods](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.popups.AssociationType.model_validate) document validation and serialization. Older guide examples use `.dict()` and sometimes serialize a renderer even where the newer Map reference accepts a model. Prefer v2 `model_dump` for dictionary boundaries; do not treat those examples as a universal conversion requirement.

### Field Maps forms

Configure web-map form presentation with `arcgis.map.forms`; this does not create fields or change a service's schema, permissions or editing capabilities. Verify the target field names, types, domains and Field Maps support before authoring:

```python
from arcgis.map.forms import FormInfo, FormFieldElement, FormTextBoxInput

form = FormInfo(
    title="Inspection",
    form_elements=[
        FormFieldElement(
            field_name="COMMENTS",
            label="Comments",
            input_type=FormTextBoxInput(),
        )
    ],
)
m.content.form_manager(index=0).form_info = form
current_form = m.content.form_manager(index=0).form_info
```

This assumes an existing editable text field `COMMENTS` on the selected feature layer. `FormInfo.form_elements` and `FormFieldElement.input_type` are required constructor fields. For groups, Arcade expressions, visibility, required/editable rules and other inputs, consult [FormInfo](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.forms.FormInfo), [FormFieldElement](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.forms.FormFieldElement) and [FormTextBoxInput](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.forms.FormTextBoxInput).

Forms are documented for Feature Layers, Tables and Oriented Imagery Layers; check the target-specific manager methods. [FormManager.form_info](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.forms.FormManager.form_info) documents retrieval, not a dictionary assignment contract. For layer updates use the explicit `update_layer(form=FormInfo(...))` interface. SceneContent does not document a `form` parameter; do not transfer this workflow to Web Scenes.

## Persist changes deliberately

For both Map and Scene:

- **`save(item_properties=...)` creates a new portal item**, including when the object was opened from an existing item. Supply `title`, `tags` and `snippet`; capture the returned `Item`.
- **`update(item_properties=...)` writes to the existing source item** and returns a boolean. It requires an object associated with an existing item. Metadata changes can be partial; check the result explicitly.
- Adding layers or changing presentation in memory is not a portal save. Neither saving nor updating the map copies its referenced services or changes their sharing.

After authoring a new `m` and confirming write scope:

```python
saved_item = m.save(item_properties={
    "title": "Reviewed web map",
    "tags": ["mapping"],
    "snippet": "Map authored with ArcGIS API for Python",
})
reopened = Map(item=saved_item, gis=gis)
```

For an authorized edit to an existing `m`, call `m.update()` instead and raise/report an error if it returns false. Reopen the target item and verify layers, renderer, popup/form configuration, view state and intended sharing. For scenes, use `Scene` and its save/update methods in the same lifecycle.

See [Map.save](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.map_widget.Map.save), [Map.update](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.map_widget.Map.update), [Scene.save](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.scene_widget.Scene.save) and [Scene.update](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.scene_widget.Scene.update). The web-scene guide's "updating" example calls `save`; treat that call as creating a new item, not overwriting the source.

[Map.export_to_html(path_to_file, title=None)](https://developers.arcgis.com/python/latest/api-reference/arcgis.map.toc.html#arcgis.map.map_widget.Map.export_to_html) is a separate visualization export, not a portal save or a copy of service data. Verify access to all referenced layers; do not expose private data to make an export render. Some prose mentions `credentials_prompt`, but it is absent from the current published signature. Verify the installed API before using it, and do not assume Scene has the same export method.
