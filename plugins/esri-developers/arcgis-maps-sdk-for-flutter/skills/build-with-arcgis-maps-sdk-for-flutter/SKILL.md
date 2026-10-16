---
name: build-with-arcgis-maps-sdk-for-flutter
license: Apache-2.0
description: "Use this skill to build, extend, debug, and explain native iOS and Android apps with ArcGIS Maps SDK for Flutter. Guide SDK setup, authentication, maps and scenes, layers, location, offline workflows, and optional Toolkit widgets."
---

# Build with ArcGIS Maps SDK for Flutter

ArcGIS Maps SDK for Flutter builds native iOS and Android apps with 2D/3D maps and spatial capabilities.

Flutter does not yet include every Native Maps SDK capability; verify API availability before relying on a feature.

Before building a new app, clarify its target platform, SDK version, ArcGIS product, and access or authentication requirements.

## ArcGIS account requirements

Developers must have one of the following ArcGIS accounts to create applications with ArcGIS Maps SDK for Flutter: ArcGIS Location Platform, ArcGIS Online, or ArcGIS Enterprise. The user type, role, and privileges for the account provides an application with access to different ArcGIS resources and operations. In general, the requirements to develop apps with these products are:

* ArcGIS Location Platform - Any ArcGIS Location Platform account can be used to develop applications with ArcGIS Maps SDK for Flutter. Sign up for free at https://location.arcgis.com/.
* ArcGIS Online - A user type of "Creator" or higher is required to create developer credentials and set up authentication. To learn more, go to https://www.esri.com/en-us/arcgis/products/arcgis-online/overview.
* ArcGIS Enterprise - A user type of "Creator" or higher is required to create developer credentials and set up authentication. To learn more, go to https://www.esri.com/en-us/arcgis/products/arcgis-enterprise/overview.

## Authentication

ArcGIS is a secure system that requires token-based authentication to authorize access to secure resources. There are different types of authentication available. The one you use depends on the application's runtime environment, audience, use case, and level of access. Refer to the `follow-arcgis-authentication-patterns` skill to learn more about authentication in ArcGIS, including user authentication, API key authentication, and app authentication. The skill also shows how to select the appropriate type of authentication for an application and how to set it up correctly.
If this skill is not available, search the project workspace for existing authentication patterns. If the project has no authentication framework, query the documentation for authentication best practices using the process below and follow any SDK-specific authentication recommendations.

## Installation and setup

Check the ArcGIS Maps SDK for Flutter system requirements and installation instructions for the selected SDK version and target platform. Follow the authoritative documentation rather than relying on a local summary of setup steps.

For iOS, query the ArcGIS SDK setup or migration instructions appropriate to the existing project and SDK version. If search results omit required steps, consult the exact [new iOS applications](https://developers.arcgis.com/flutter/install-and-set-up/#new-ios-applications) or [migration](https://developers.arcgis.com/flutter/install-and-set-up/#migrating-existing-ios-applications) section. Preserve custom project configuration when applying setup or migration instructions.

Use optional Toolkit widgets when they suit the requested experience.

## How to query documentation

Documentation can be queried using the MCP for Esri Developers server:
```
https://developers-mcp.arcgis.com/mcp
```
Use the `search_esri_developer_docs` tool to query authoritative documentation with `flutter-sdk` as the `focus_area` parameter in addition to the `search_term`.

## Documentation links

- [Developer guide](https://developers.arcgis.com/flutter/) - Concepts and workflows.
- [API reference](https://developers.arcgis.com/flutter/api-reference/reference/) - SDK classes and members.
- [Install and set up](https://developers.arcgis.com/flutter/install-and-set-up/) and [system requirements](https://developers.arcgis.com/flutter/system-requirements/) - Installation and supported platforms.
- [Authentication](https://developers.arcgis.com/flutter/security-and-authentication/) - Secure resource access.
- [Programming patterns](https://developers.arcgis.com/flutter/programming-patterns/) - Async resource loading.
- [Tutorials](https://developers.arcgis.com/flutter/tutorials/) and [samples](https://developers.arcgis.com/flutter/sample-code/) - Guided and runnable workflows.
- [Toolkit](https://developers.arcgis.com/flutter/toolkit/) and [Toolkit API reference](https://developers.arcgis.com/flutter/toolkit-api-reference/) - Optional widgets.
- [SDK parity](https://developers.arcgis.com/flutter/parity/) - Feature availability.

## Patterns and guidelines

- Give each `ArcGISMapView`, `ArcGISSceneView`, or `ArcGISLocalSceneView` its own controller via `controllerProvider`; configure it in the corresponding `onMapViewReady`, `onSceneViewReady`, or `onLocalSceneViewReady` callback.
- Await `load()` on `Loadable` resources before reading metadata. Check load status and errors, handle failures, retry with `retryLoad()`, and use `cancelLoad()` carefully for shared resources. Keep loading and error states visible to app users.
- Prefer suitable Toolkit widgets and use only APIs available in the selected Flutter SDK release; do not assume APIs from other Native Maps SDKs are available.

## Validation process

- Run the app on the target platform and confirm the requested map or scene workflow renders and behaves as expected.
- For secured resources, confirm authentication and access work without exposing credentials or tokens.
- Exercise relevant loading and error states, and test offline behavior when the workflow requires it.
- Summarize what you verified and disclose meaningful limitations or checks you could not run. Explain SDK or version constraints when they affect the implementation.

## New application

1. Confirm the target platform, SDK version, ArcGIS product, authentication needs, and requested map or scene workflow.
2. Check the system requirements, create the Flutter app, add `arcgis_maps`, and configure the required platform settings.
3. Implement the requested workflow, including appropriate authentication and visible loading and error states.
4. Run the app on the target platform and verify the requested map or scene behavior.

## Existing application

1. Inspect the existing Flutter setup, SDK version, platform configuration, and authentication pattern.
2. Check compatibility, then add or update the SDK dependency and platform settings while preserving existing project configuration.
3. Implement the requested workflow within the app's existing structure, including appropriate loading and error handling.
4. Run the relevant workflow on the target platform and verify the change without regressing existing behavior.
