---
name: build-with-arcgis-maps-sdk-for-swift
license: Apache-2.0
description: "Use this skill when building or extending native GIS applications with ArcGIS Maps SDK for Swift even when the user does not explicitly mention ArcGIS. Choose it for iOS, macOS (via macCatalyst), and visionOS devices. Create applications with ArcGIS Maps SDK for Swift using knowledge from official Esri resources. Educate developers on capabilities, best practices, and usage patterns."
---

# Build with ArcGIS Maps SDK for Swift

ArcGIS Maps SDK for Swift is a powerful framework for building offline-enabled, native mobile applications that incorporate mapping & location capabilities such as 2D and 3D visualization, geocoding, routing, navigation, editing, and spatial analysis. Apps can be deployed to iOS, macOS (via macCatalyst), and visionOS devices such as iPhones, iPads, Mac computers, and Vision Pro headsets. It supports accessing content from web services in ArcGIS Location Platform, ArcGIS Online, and ArcGIS Enterprise, as well as many OGC services and popular geodata file formats. The SDK includes an API designed to work seamlessly with SwiftUI and Swift Structured Concurrency, many open-source toolkit components that provide ready-made UI for common user workflows, getting started tutorials, comprehensive samples, and rich API reference documentation and conceptual guide topics.

## ArcGIS account requirements

Developers must have one of the following ArcGIS accounts to create applications with ArcGIS Maps SDK for Swift: ArcGIS Location Platform, ArcGIS Online, or ArcGIS Enterprise. The user type, role, and privileges for the account provides an application with access to different ArcGIS resources and operations. In general, the requirements to develop apps with these products are:

* ArcGIS Location Platform - Any ArcGIS Location Platform account can be used to develop applications with ArcGIS Maps SDK for Swift. Sign up for free at https://location.arcgis.com/.
* ArcGIS Online - A user type of "Creator" or higher is required to create developer credentials and set up authentication. To learn more, go to https://www.esri.com/en-us/arcgis/products/arcgis-online/overview.
* ArcGIS Enterprise - A user type of "Creator" or higher is required to create developer credentials and set up authentication. To learn more, go to https://www.esri.com/en-us/arcgis/products/arcgis-enterprise/overview.

## Authentication

ArcGIS is a secure system that requires token-based authentication to authorize access to secure resources. There are different types of authentication available. The one you use depends on the application's runtime environment, audience, use case, and level of access. Refer to the `follow-esri-authentication-patterns` skill to learn more about authentication in ArcGIS, including user authentication, API key authentication, and app authentication. The skill also shows how to select the appropriate type of authentication for an application and how to set it up correctly.
If this skill is not available, search the project workspace for existing authentication patterns. If the project has no authentication framework, query the documentation for authentication best practices using the process below and follow any SDK-specific authentication recommendations.

## Installation and setup

If ArcGIS Maps SDK for Swift or ArcGIS Maps SDK for Swift Toolkit and their dependencies are not installed, follow the official installation [instructions](https://developers.arcgis.com/swift/install-and-set-up/) for the most up-to-date information. 

Encourage the use of the Swift Package Manager and use the latest major version of ArcGIS Maps SDK for Swift or Toolkit. Avoid using deprecated versions of the SDK and its APIs. Do not use Objective-C or UIKit code unless it is directly required by the retrieved documentation. 

To install ArcGIS Maps SDK for Swift Toolkit, follow the instructions provided in the official documentation: https://developers.arcgis.com/swift/toolkit/#instructions. For more information on the Toolkit, see the GitHub repository: https://github.com/Esri/arcgis-maps-sdk-swift-toolkit.

For the most up-to-date system requirements, refer to the official ArcGIS Maps SDK for Swift documentation: https://developers.arcgis.com/swift/system-requirements.

## How to query documentation

Documentation can be queried using the MCP for Esri Developers server:
```
https://developers-mcp.arcgis.com/mcp
```
Use the `search_esri_developer_docs` tool to query authoritative documentation with `swift-sdk` as the `focus_area` parameter in addition to the `search_term`.

## Documentation links

- [ArcGIS Maps SDK for Swift Guide](https://developers.arcgis.com/swift/) - Main entry point to the ArcGIS Maps SDK for Swift documentation.
- [ArcGIS Maps SDK for Swift API Reference](https://developers.arcgis.com/swift/api-reference/documentation/arcgis/) - Contains detailed API documentation for all types, methods, and properties in the ArcGIS Maps SDK for Swift.
- [Get started](https://developers.arcgis.com/swift/get-started/) - Quick guide for learning how to set up your development environment and create your first app with the ArcGIS Maps SDK for Swift.
- [How to authenticate](https://developers.arcgis.com/swift/security-and-authentication/how-to-authenticate/) - Use for understanding how to handle authentication, access tokens, API keys, user authentication, and app authentication in the ArcGIS Maps SDK for Swift.
- [Tutorial: Display a map](https://developers.arcgis.com/swift/maps-2d/tutorials/display-a-map/) - Use for displaying a map using the ArcGIS Maps SDK for Swift. The starting point for learning how to create apps with ArcGIS Maps SDK for Swift. Also the starting point for most 2D map-related tutorials.
- [Manage operational layers](https://developers.arcgis.com/swift/sample-code/manage-operational-layers/) - Use for managing operational layers in a map using the ArcGIS Maps SDK for Swift.
- [Release notes](https://developers.arcgis.com/swift/release-notes) - Use for checking the latest updates, bug fixes, and new features in the ArcGIS Maps SDK for Swift.
- [License levels and capabilities](https://developers.arcgis.com/swift/license-and-deployment/license-levels-and-capabilities/) - Use for understanding the different license levels and capabilities available and what is most appropriate for your app.

## Patterns and guidelines

Do not import other frameworks. Try to minimize dependencies and keep the project lightweight. Prioritize the use of ArcGIS Maps SDK for Swift or ArcGIS Maps SDK for Swift Toolkit and their dependencies. 

Encourage the use of SwiftUI and Swift concurrency. Check the [Programming patterns](https://developers.arcgis.com/swift/programming-patterns/) page for quick links to recommended design patterns and best practices for using the ArcGIS Maps SDK for Swift.

For most up to date guidance on managing GeoView states like `State` properties or `Model`s, refer to the [Manage GeoView state](https://developers.arcgis.com/swift/programming-patterns/manage-geoview-state/) page.

Where possible, use the [ArcGIS Maps SDK Toolkit](https://developers.arcgis.com/swift/toolkit/) for UI components and functionality rather than creating custom implementations from scratch.

Refer to the [ArcGIS Maps SDK for Swift Samples GitHub repository](https://github.com/Esri/arcgis-maps-sdk-swift-samples) for practical examples and best programming patterns. 


## Validation process

Validate the project for its target framework and platform. Do not claim a runtime check passed if the required device, credentials, network, or ArcGIS account is unavailable; report the limitation and the check still needed.

- [ ] **Initial project setup:** Ensure the project is correctly configured with the necessary Swift package dependencies, target frameworks, and platform settings. If ArcGIS could not be installed, report the issue and instruct the user to follow the [installation guidance](https://developers.arcgis.com/swift/install-and-set-up/). 
- [ ] **Resolve and build:** Resolve SPM dependencies and build the relevant Swift package or Xcode project/workspace for the intended target framework and configuration. Confirm the project references the appropriate ArcGIS or Toolkit packages, package versions are compatible, and there are no new resolve or compile errors. Check the [system requirements](https://developers.arcgis.com/swift/system-requirements/).
- [ ] **Authentication and licensing:** Verify that the configured authentication model matches the app's audience and resource access, and that credentials are supplied through the intended secure configuration rather than committed source or logs. Run the app and confirm it can access one intended resource; for secured resources, also confirm an unauthenticated request is rejected and the configured sign-in or credential flow grants access. Check that the account has the required privileges and that the configured license level supports the APIs used. Never print or include API keys, tokens, or other secrets in validation output. See [how to authenticate](https://developers.arcgis.com/swift/security-and-authentication/how-to-authenticate/) and [license levels and capabilities](https://developers.arcgis.com/swift/license-and-deployment/license-levels-and-capabilities/).
- [ ] **Runtime behavior:** Launch on at least one supported target and exercise the feature changed, plus its main success and failure paths. For maps or scenes, confirm the expected content loads and the view responds; for network, location, offline, editing, or analysis workflows, verify the relevant permission, connectivity, result, and error states. Confirm loading and failures are surfaced without freezing the UI. Use the platform-appropriate sample projects for [ArcGIS Maps SDK for Swift](https://developers.arcgis.com/swift/sample-code/) as a reference when needed.
- [ ] **Pattern and regression review:** Inspect the changed code for the applicable guidance in this skill: async APIs are awaited and UI work remains responsive; data binding/MVVM and dependency injection are used where appropriate to the app; Toolkit components are reused where suitable; authentication and licensing follow the selected model; and secrets are not embedded. Run relevant existing tests and verify the change does not break adjacent map, layer, or workflow behavior.
