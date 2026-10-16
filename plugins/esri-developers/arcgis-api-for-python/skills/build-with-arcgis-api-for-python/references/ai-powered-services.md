# AI-Powered Services (`arcgis.ai`)

Use `arcgis.ai` for ArcGIS Online AI-powered image analysis, text analysis and translation. This is a documented ArcGIS API for Python module; do not infer that it does not exist from older API knowledge. Do not substitute `arcgis.learn` deep-learning workflows for these service calls.

## Authoritative documentation

- [arcgis.ai module API reference](https://developers.arcgis.com/python/latest/api-reference/arcgis.ai.html): supported functions, parameters, response types and service requirements.
- [Introduction to AI-Powered services in ArcGIS Online](https://developers.arcgis.com/python/latest/guide/introduction-to-ai-powered-services/): end-to-end examples and response access patterns.

For Esri documentation MCP searches, use `focus_area="python-api"` and `arcgis.ai` or a function name.

## Choose the function

| Task | API |
| --- | --- |
| Analyze an image | `arcgis.ai.analyze_image()` |
| Analyze text | `arcgis.ai.analyze_text()` |
| Translate text into one or more languages | `arcgis.ai.translate()` |

## Important limits

- These functions depend on ArcGIS Online AI-powered services. Reuse an authenticated `GIS` connection to an organization with AI assistants enabled; supply `gis=` where documented. Do not assume anonymous, API-key or ArcGIS Enterprise access is supported merely because other `arcgis` workflows support it.
- Check current service availability, organization settings, privileges and credit rules in the linked documentation before use; do not assume requests are free.
- Text and images are sent to online services. Confirm approval to transmit the data, minimize sensitive inputs and agree on spending limits before requests. Keep credentials out of source, chat and outputs.
- Consult the linked documentation for function-specific inputs and response handling, including errors and multiple results or target languages. Do not assume the functions share a response structure.
- Generated descriptions and text analysis are not verified GIS facts; validate outputs and do not automatically write them back to portal items or features.

Validate response handling locally where possible. Do not make billable service requests or portal writes solely for validation; report any service path that remains untested.