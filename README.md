# Esri agent skills

Install **Esri agent skills** and **MCP servers** to enhance your AI workflows via [Agent Plugins](https://agent-plugins.org/specification/). This repository packages technology-specific guidance and access to Esri documentation.

## What's Included

- **Esri agent skills:** Skills for ArcGIS development, including account requirements, authentication guidance, and instructions for querying official documentation with technology-specific focus areas.
- **MCP servers:** The current server integration is **MCP for Esri Developers**, which lets agents search Esri developer documentation.

## Installation

1. Follow your client's installation documentation below to add plugins from this repository.
2. Install [general-esri-development](plugins/esri-developers/general-esri-development) for the shared development skills.
3. Install the technology-specific plugins you need from the catalog below.

For example, a web mapping project can use `general-esri-development`, `arcgis-maps-sdk-for-javascript`, and `calcite-design-system` together.

### Client Documentation

- [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/plugins-finding-installing)
- [VS Code](https://code.visualstudio.com/docs/agent-customization/agent-plugins#_install-a-plugin-from-source)
- [Claude Code](https://code.claude.com/docs/en/discover-plugins#add-from-github)
- [Cursor](https://cursor.com/docs/plugins#installing-plugins)
- [Xcode](https://developer.apple.com/documentation/xcode/extending-and-customizing-agents#Install-agentic-coding-plug-ins)
- [Kiro](https://kiro.dev/docs/powers/installation/#from-public-github-url)

Installation steps and support for skills, MCP servers, and agent extensions vary by client. These links describe each client's installation or extension workflow.

## Plugin Catalog

- [general-esri-development](plugins/esri-developers/general-esri-development): Shared development skill and MCP for Esri Developers connection
- [arcgis-api-for-python](plugins/esri-developers/arcgis-api-for-python): ArcGIS API for Python
- [arcgis-rest-js](plugins/esri-developers/arcgis-rest-js): ArcGIS REST JS
- [calcite-design-system](plugins/esri-developers/calcite-design-system): Calcite Design System
- [arcgis-and-cesiumjs](plugins/esri-developers/arcgis-and-cesiumjs): CesiumJS with ArcGIS services
- [arcgis-maps-sdk-for-dotnet](plugins/esri-developers/arcgis-maps-sdk-for-dotnet): ArcGIS Maps SDK for .NET
- [arcgis-leaflet](plugins/esri-developers/arcgis-leaflet): ArcGIS plugin for Leaflet
- [arcgis-maps-sdk-for-flutter](plugins/esri-developers/arcgis-maps-sdk-for-flutter): ArcGIS Maps SDK for Flutter
- [arcgis-maps-sdk-for-javascript](plugins/esri-developers/arcgis-maps-sdk-for-javascript): ArcGIS Maps SDK for JavaScript
- [arcgis-maps-sdk-for-kotlin](plugins/esri-developers/arcgis-maps-sdk-for-kotlin): ArcGIS Maps SDK for Kotlin
- [arcgis-maplibre](plugins/esri-developers/arcgis-maplibre): ArcGIS plugin for MapLibre GL JS
- [arcgis-and-openlayers](plugins/esri-developers/arcgis-and-openlayers): OpenLayers with ArcGIS services
- [arcgis-maps-sdk-for-qt](plugins/esri-developers/arcgis-maps-sdk-for-qt): ArcGIS Maps SDK for Qt
- [arcgis-maps-sdk-for-swift](plugins/esri-developers/arcgis-maps-sdk-for-swift): ArcGIS Maps SDK for Swift
- [arcgis-maps-sdk-for-unity](plugins/esri-developers/arcgis-maps-sdk-for-unity): ArcGIS Maps SDK for Unity
- [arcgis-maps-sdk-for-unreal-engine](plugins/esri-developers/arcgis-maps-sdk-for-unreal-engine): ArcGIS Maps SDK for Unreal Engine

## Verification

After installation, verify that:

- The skills from each installed plugin are discoverable.
- **MCP for Esri Developers** is connected through `general-esri-development`, with no duplicate server connections.

When editing packages, validate manifests against the official [Agent Plugins 1.0 plugin schema](https://agent-plugins.org/schemas/1.0.0/plugin.schema.json) and [MCP schema](https://agent-plugins.org/schemas/1.0.0/mcp.schema.json).

## Issues

Find a bug or want to request a new feature?  Please let us know by [submitting an issue](https://github.com/Esri/esri-agent-skills/issues/new).

## Contributing

Esri welcomes contributions from anyone and everyone. Before you [file an issue](https://github.com/Esri/esri-agent-skills/issues/new) or issue a [pull request](https://github.com/Esri/esri-agent-skills/pulls), please read our **[Contributing Guidelines](CONTRIBUTING.md)** to learn about our process and how to request new features, propose bug fixes or improvements.

Please also note that this project is governed by our **[Code of Conduct](CODE_OF_CONDUCT.md)**. By participating, you are expected to uphold this code.

## License

Copyright 2026 Esri

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

A copy of the license is available in the repository's [LICENSE](./LICENSE?raw=true) file.
