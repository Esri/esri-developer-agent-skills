---
name: build-with-arcgis-leaflet
license: Apache-2.0
description: "Use to build browser apps with Leaflet, Esri Leaflet plugins, and ArcGIS basemaps/data services. Covers how to combine Leaflet with vector basemaps, static basemaps, feature layers, vector tiles, raster tiles, geocoding, clusters, and heatmap, queries, styling, routing, places, GeoEnrichment, elevation, and places. Includes install, setup, debug, documentation, best practices, guidelines, explanations, and validation."
---

# Build with Leaflet and ArcGIS

Esri Leaflet is an open-source Leaflet plugin suite for ArcGIS services. Use `esri-leaflet` for core layers and add Esri Leaflet Vector, Static Basemap Tile, Geocoder, Cluster, or Heatmap as needed. Leaflet renders the map; Esri Leaflet provides data services and core ArcGIS functionality, and ArcGIS REST JS supplies other Location Services and authentication. This is not the ArcGIS Maps SDK for JavaScript.

## ArcGIS account requirements

Developers must have one of the following ArcGIS accounts to create applications with ArcGIS: ArcGIS Location Platform (free), or ArcGIS Online or ArcGIS Enterprise with a Creator, Professional, or Professional Plus user type. The account's user type, role, and privileges provide access to different resources and operations.

## Authentication

DO NOT SKIP: Refer to the `follow-esri-authentication-patterns` skill for ArcGIS authentication requirements, including the appropriate type of authentication for different audiences, use cases, and types of application. If the skill is not available, search the project for any existing authentication patterns, and if none are found, query the documentation MCP for authentication best practices.

## Installation and setup

Use the [Esri Leaflet API reference](https://developers.arcgis.com/esri-leaflet/api-reference/) for APIs/options. Use `esri-leaflet-geocoder` for geocoding; use  use [ArcGIS REST JS](https://developers.arcgis.com/arcgis-rest-js/) for routing, places, elevation, GeoEnrichment, and other Location Services. Use the existing toolchain and pin versions. Apply the [patterns and guidelines](#patterns-and-guidelines) while implementing and the [validation process](#validation-process) after setup.

### Package selection matrix

Choose packages related to user task:

- `leaflet` - core mapping library. Always include.
- `esri-leaflet` - Esri integration for Leaflet. Always include.
- `esri-leaflet-vector` - vector tile and basemap services.
- `esri-leaflet-geocoder` - geocoding plugin.
- `esri-leaflet-static-basemap-tile` - static basemap tile service.
- `esri-leaflet-cluster` - clustered rendering plugin for feature layers.
- `esri-leaflet-heatmap` - heatmap rendering plugin for feature layers.
- `@esri/arcgis-rest-js` - ArcGIS REST JS for routing, places, elevation, GeoEnrichment, and other Location Services.

### New application

Pick one of the following paths based on inferred requirements. If uncertain, ask for clarification before proceeding.

#### New application with CDN

Load Leaflet CSS/JS, Esri Leaflet, and only required plugin scripts/styles from current CDN URLs. Query the Esri Developer MCP for current examples/versions. Most documentation uses CDN scripts; use this for testing, debugging, demos, tutorials, samples, and lightweight quickstarts. Keep the container non-zero and load plugin CSS when needed.

#### New application with npm

Recommend Vite with vanilla JavaScript/HTML/CSS. `npm`, `yarn`, and other CLIs are supported; install `leaflet`, `esri-leaflet`, and required plugins, import Leaflet CSS, and use ESM. Use this method for actual development, larger projects, and production builds. React, Angular, Vue, and Svelte are supported frameworks.

### Existing application

Before installing, identify package manager/lockfile, framework, bundler (webpack/Vite), TypeScript/ESLint configs, and CDN versus Node-module imports. Conform; install Leaflet, `esri-leaflet`, and plugins only as required. Use REST JS and preserve environment/credential conventions. CommonJS: synchronous native `require` on Node 22+ or asynchronous dynamic `import()` on Node 12+; Node <12 unsupported.

## How to query documentation

Documentation can be queried using the MCP for Esri Developers server:
```
https://developers-mcp.arcgis.com/mcp
```
Use the `search_esri_developer_docs` tool to query authorative documentation with the `esri-leaflet` as the `focus_area` parameter in addition to the `search_term`; use the `arcgis-rest-js` focus area for REST JS. Clearly indicate any recommendations and assumptions that are not grounded in the linked official documentation. If MCP is unavailable, consult official documentation links below. 

## Documentation links

Official references - prefer the MCP for Esri Developers for all page lookups and fall back to URLs if not available.

- [Guide](https://developers.arcgis.com/esri-leaflet/), [overview](https://developers.arcgis.com/esri-leaflet/esri-leaflet-plugin/), [API reference](https://developers.arcgis.com/esri-leaflet/api-reference/), and [GitHub](https://github.com/esri/esri-leaflet) - core Esri Leaflet documentation.
- [Leaflet API reference](https://leafletjs.com/reference.html) and [GitHub](https://github.com/Leaflet/Leaflet) - core Leaflet documentation.
- [browser support](https://developers.arcgis.com/esri-leaflet/browser-support/) and [FAQ](https://developers.arcgis.com/esri-leaflet/faq/) - compatibility and limitations.
- [vector basemaps](https://developers.arcgis.com/esri-leaflet/maps/vector-tile-basemaps/display-a-map/), [static raster basemaps](https://developers.arcgis.com/esri-leaflet/maps/raster-tile-basemaps/display-a-map/), [features](https://developers.arcgis.com/esri-leaflet/layers/add-a-feature-layer/), [vector tiles](https://developers.arcgis.com/esri-leaflet/layers/add-a-vector-tile-layer/), and [image/map tiles](https://developers.arcgis.com/esri-leaflet/layers/add-a-map-tile-layer/)  - basemaps and data services.
- [ArcGIS REST JS](https://developers.arcgis.com/arcgis-rest-js/) and [Leaflet](https://leafletjs.com/) - Location Services and renderer behavior. Query optional plugin references from the API.

## Patterns and guidelines

- Identify product, service URL, layer type, build tool, and auth. Use Esri MCP for current claims and Leaflet docs for renderer behavior.
- Create the map after its container exists, give it non-zero dimensions, add the appropriate Esri layers, and await dependent async work. Preserve Esri/data attribution. Use OAuth PKCE with an exact redirect URI; keep app-auth secrets/exchange server-side.
- Select packages by capability: core; Vector for vector basemaps/layers; Static Basemap Tile for raster basemaps; Geocoder for address/place UI; Cluster/Heatmap for feature visualization.
- Use `L.esri.featureLayer` for feature services/queries, `tiledMapLayer` for raster tiles, `dynamicMapLayer` for map services, and `L.esri.Vector.vectorTileLayer`/`vectorBasemapLayer` for vector data. Use REST JS for Location Services.
- Add layers after the map/container and required async data are ready. Preserve Esri/data attribution, use supported service URLs/items, and keep operational layers distinct.
- Query only needed fields; bind popups from known attributes and sanitize before HTML. Use documented vector style callbacks and valid fields; do not apply feature-service query assumptions to vector tiles.
- Restrict browser keys; match portal/token/redirect URI to the owning product; handle empty/auth/network/rate-limit errors; never expose credentials.
- Core Esri Leaflet targets modern browsers with `fetch`/ES2017; Vector targets ES2019. Default tiles are Web Mercator Auxiliary Sphere (WKID 102100/3857); non-Mercator needs Proj4Leaflet and validation. Do not assume web-map or 3D support.
- Avoid duplicate maps/layers, clean up controls/listeners, pin versions, smoke-test upgrades, and re-query MCP when behavior is version-dependent.
- Do not use the archived `esri-leaflet-renderers` plugin.
- Use ArcGIS REST JS for routing, places, elevation, and user authentication; Do not install REST JS if those features are not required. If using REST JS for authentication, acquire access tokens as strings from the `AuthenticationManager` and pass to Esri Leaflet. Reference the `build-with-arcgis-rest-js` skill for guidance as applicable.
- Authentication: Use API keys only for location services; avoid using them to authenticate feature layers or vector tile layers and recommend user authentication as an alternative. Keep app-auth credentials/secrets server-side if using.

## Validation process

Validate that:

- [ ] Check manifest/lockfile/dependencies, versions, imports, CSS, container, credentials, attribution, and console/network errors. Verify the intended plugin/layer, feature queries/popups, vector style callbacks, service URLs, Web Mercator compatibility, and REST JS failure handling. Do not expose credentials.
- [ ] Credentials/portal/redirect URI have required access.
- [ ] Browser smoke test covers reload, multiple zooms, and console/network errors; re-query MCP for version-dependent behavior.
