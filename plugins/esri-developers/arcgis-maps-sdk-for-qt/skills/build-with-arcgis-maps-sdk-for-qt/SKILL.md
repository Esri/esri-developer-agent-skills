---
name: build-with-arcgis-maps-sdk-for-qt
license: Apache-2.0
description: "Use this skill when building or extending native GIS applications with ArcGIS Maps SDK for Qt. Choose it to build Qt/C++ apps for Windows, Linux, macOS, iOS, and Android devices. Follow its guidance to set up and license the SDK, configure authentication, display 2D maps and 3D scenes, use ArcGIS Online, ArcGIS Enterprise, or ArcGIS Location Platform maps and services, and implement location, offline workflows, geocoding, routing, spatial analysis, editing, and synchronization. Use it for SDK-specific architecture, toolkit integration, validation, and platform considerations; consult follow-esri-authentication-patterns to select an authentication model."

---

# Build with ArcGIS Maps SDK for Qt

ArcGIS Maps SDK for Qt allows developers to build native mapping and GIS applications. It provides APIs and UI components for displaying maps and scenes, working with geographic data, performing spatial analysis, and integrating with the ArcGIS platform. The Qt Maps SDK supports building native desktop and mobile applications using the Qt/C++ frameworks, for deployment on Windows, Linux, macOS, iOS and Android devices. It is well-suited for implementing mobile workflows, especially those that require device location, editing, and offline capabilities.

## ArcGIS account requirements

Developers must have one of the following ArcGIS accounts to create applications with ArcGIS Maps SDK for Qt: ArcGIS Location Platform, ArcGIS Online, or ArcGIS Enterprise. The user type, role, and privileges for the account provides an application with access to different ArcGIS resources and operations. In general, the requirements to develop apps with these products are:

* ArcGIS Location Platform - Any ArcGIS Location Platform account can be used to develop applications with ArcGIS Maps SDK for Qt. Sign up for free at https://location.arcgis.com/.
* ArcGIS Online - A user type of "Creator" or higher is required to create developer credentials and set up authentication. To learn more, go to https://www.esri.com/en-us/arcgis/products/arcgis-online/overview.
* ArcGIS Enterprise - A user type of "Creator" or higher is required to create developer credentials and set up authentication. To learn more, go to https://www.esri.com/en-us/arcgis/products/arcgis-enterprise/overview.

## Authentication

ArcGIS is a secure system that requires token-based authentication to authorize access to secure resources. There are different types of authentication available. The one you use depends on the application's runtime environment, audience, use case, and level of access. Refer to the `follow-esri-authentication-patterns` skill to learn more about authentication in ArcGIS, including user authentication, API key authentication, and app authentication. The skill also shows how to select the appropriate type of authentication for an application and how to set it up correctly.
If this skill is not available, search the project workspace for existing authentication patterns. If the project has no authentication framework, query the documentation for authentication best practices using the process below and follow any SDK-specific authentication recommendations.

## Installation and setup

ArcGIS Maps SDK for Qt can be installed and set up in your development environment by following these key steps:
- Ensure your development environment meets the [system requirements](https://developers.arcgis.com/qt/system-requirements/). The system requirements also describe deployment requirements and recommended hardware.
- [Install and set up](https://developers.arcgis.com/qt/install-and-set-up/) provides detailed instructions for installing and configuring the ArcGIS Maps SDK for Qt on the development environments of Windows, macOS, and Linux.
- [Additional downloads](https://developers.arcgis.com/qt/install-and-set-up/#additional-downloads) for any supplementary tools or resources required for development including SDK extensions, sample data, and documentation.
- [Downloads](https://developers.arcgis.com/qt/downloads/) provides the authoritative source for the latest version of the ArcGIS Maps SDK for Qt and any additional resources.
- [Qt Toolkit](https://developers.arcgis.com/qt/toolkit/) provides additional UI components and tools for building applications with the ArcGIS Maps SDK for Qt.
- [Release notes](https://developers.arcgis.com/qt/release-notes/) provides information about the latest updates, bug fixes, and new features in the ArcGIS Maps SDK for Qt.

## How to query documentation

Documentation can be queried using the MCP for Esri Developers server:
```
https://developers-mcp.arcgis.com/mcp
```
Use the `search_esri_developer_docs` tool to query authoritative documentation with `qt-sdk` as the `focus_area` parameter in addition to the `search_term`.

## Documentation links

- [Maps SDK for Qt Guide](https://developers.arcgis.com/qt/) - Main entry point to the Qt Maps SDK documentation.
- [Maps SDK for Qt API Reference](https://developers.arcgis.com/qt/api-reference/) - Contains detailed API documentation for all classes, methods, and properties in the Qt Maps SDK.
- [Topic: How to authenticate](https://developers.arcgis.com/qt/security-and-authentication/how-to-authenticate/) - Describes the authentication methods supported by the Qt Maps SDK. The type of authentication you use depends on the security and access requirements of your app.
- [Topic: Implement user authentication](https://developers.arcgis.com/qt/security-and-authentication/implement-authentication/) - Provides guidance on how to implement user authentication (such as OAuth 2.0) in the Qt Maps SDK.
- [Tutorial: Display a map](https://developers.arcgis.com/qt/maps-2d/tutorials/display-a-map/) - A simple, entry-level tutorial for displaying a map in a Qt app using the Qt Maps SDK.
- [Topic: Layer types](https://developers.arcgis.com/qt/layers/layer-types/) - Describes the different types of layers available in the Qt Maps SDK and their capabilities.
- [Topic: Offline maps, scenes, and data](https://developers.arcgis.com/qt/offline-maps-scenes-and-data/) - Entry page for content that describes how to prepare and work with offline content in the Qt Maps SDK.

## Licensing

The ArcGIS Maps SDK for Qt requires a valid license to use. License levels include Lite, Basic, Standard, and Advanced, each providing different capabilities. Explicitly distinguish ArcGIS account privileges and authentication from the SDK license level required by an API. The AI agent should check License by API and License levels and capabilities rather than infer requirements from the account type alone. 

- Refer to the [License levels and capabilities](https://developers.arcgis.com/qt/license-and-deployment/license-levels-and-capabilities/) topic for detailed information on what each license level offers.
- Some parts of the API require a license other than Lite. See the [License by API](https://developers.arcgis.com/qt/license-and-deployment/license-by-api/) topic for details on which operations require which license level.

## Patterns and guidelines

- Where possible, use the [ArcGIS Maps SDK Toolkit](https://developers.arcgis.com/qt/toolkit/) for UI components and functionality rather than creating custom implementations from scratch.
- When possible, use styles and resources from the [Esri Calcite Style in the Qt Toolkit](https://github.com/Esri/arcgis-maps-sdk-toolkit-qt/tree/main/calcite) for styling UI elements.
- Use [tasks and jobs](https://developers.arcgis.com/qt/programming-patterns/tasks-and-jobs/) to manage asynchronous operations and handle long-running processes efficiently in Qt applications using the Qt Maps SDK.
- [Performance considerations](https://developers.arcgis.com/qt/programming-patterns/performance-considerations/) - Provides guidance on optimizing the performance of Qt applications using the Qt Maps SDK.
- [Best practices](https://developers.arcgis.com/qt/programming-patterns/best-practices/) - Provides general best practices for developing Qt applications using the Qt Maps SDK.
- Supports qmake and CMake build systems. Prefer CMake over qmake by default. [300.x Tutorials](https://developers.arcgis.com/qt/tutorials/) are good references for CMake and [200.x Tutorials](https://developers.arcgis.com/qt/v200/tutorials/) are good references for qmake.
- If building a new application from scratch, reference the [display a map tutorial solution project](https://developers.arcgis.com/qt/zips/display-a-map.zip) as a starting point. Do not use the templates provided in the ideintegration folder of the SDK, as those templates are wizards with special formatting for Qt Creator only.

## Code examples

These code example links provide the best authoritative source for learning how to implement various features and use cases in the Qt Maps SDK. Use these code examples as a basis for the AI agent to educate and guide users effectively.

- [ArcGIS Maps SDK for Qt Samples](https://github.com/Esri/arcgis-maps-sdk-qt-samples) - A collection of various sample applications demonstrating different features and use cases of the Qt Maps SDK.
- [Dynamic Situational Awareness Qt Sample App](https://github.com/Esri/dynamic-situational-awareness-qt) - A sample application demonstrating dynamic situational awareness capabilities using the Qt Maps SDK.
- [Qt Maps SDK Tutorials](https://developers.arcgis.com/qt/tutorials/) - A collection of tutorials for learning how to use the Qt Maps SDK in various scenarios. This is the gateway page for accessing all available tutorials.
- [ArcGIS Maps SDK Toolkit API Reference](https://developers.arcgis.com/qt/toolkit/api-reference/) - The official API reference for the ArcGIS Maps SDK Toolkit in Qt. It provides code examples interspersed in the docs.

## Troubleshooting and current announcements

The following links provide resources for troubleshooting common issues and staying updated with the latest announcements related to the Qt Maps SDK.

- [Release notes](https://developers.arcgis.com/qt/release-notes/) provides information about the latest updates, bug fixes, and new features in the ArcGIS Maps SDK for Qt.
- [Esri Community - Qt](https://community.esri.com/en/search?domain=all_content&query=qt&scope=site&source=community) - A community forum for discussing issues, asking questions, and sharing knowledge related to the Qt Maps SDK.
- [Esri ArcGIS Blog - Qt](https://www.esri.com/arcgis-blog/?s=qt) - Blog posts and articles related to using Qt with ArcGIS Maps SDK.

## The Qt Framework and Compatibility

The ArcGIS Maps SDK for Qt is built upon the Qt framework and coded in the C++ programming language, and it is designed to be compatible with specific versions of Qt. The Qt framework provides the underlying infrastructure and tools necessary for developing cross-platform applications, and the ArcGIS Maps SDK leverages these capabilities to deliver rich mapping and geospatial functionality within Qt applications. The following links should be used by the AI agent to help users be successful understanding Qt core concepts, writing code, and educating users.

- [Qt Documentation](https://doc.qt.io/) - The official documentation for the Qt framework, providing comprehensive information on Qt modules, classes, and functions.
- [Qt C++ API Reference](https://doc.qt.io/qt-6/classes.html) - The official C++ API reference for the Qt framework, detailing all available classes and their members.
- [Qt Tutorials](https://doc.qt.io/qt-6/qtexamplesandtutorials.html) - A collection of tutorials and examples for learning how to use the Qt framework effectively. 
- [Qt Creator IDE](https://www.qt.io/development/tools/qt-creator-ide) - The official integrated development environment (IDE) for developing Qt applications, providing tools for coding, debugging, and project management.
- [MCP Documentation](https://doc.qt.io/agentictools/mcp/) - Documentation for the MCP (Modular C++ Project) tools used in conjunction with Qt development.

## Validation process

Validate against the application's SDK version, Qt version, build system, and target platform. Do not report a check as passed unless it was actually run. If a required SDK, device, credential, network connection, or ArcGIS account is unavailable, state the limitation and what remains to be checked.

- [ ] **Environment and build:** Check the [system requirements](https://developers.arcgis.com/qt/system-requirements/) for the target platform. Confirm the installed ArcGIS Maps SDK for Qt, Qt version, compiler, and Qt Creator kit are compatible. Build with the project's existing build system (qmake or CMake) and the configuration for the intended target. Resolve new configuration, dependency, and compile errors; do not migrate build systems as part of an unrelated change.
- [ ] **SDK setup smoke test:** When setup or SDK integration changed, build and run the [Display a map tutorial](https://developers.arcgis.com/qt/maps-2d/tutorials/display-a-map/) or an equivalent minimal project. Confirm the app starts and displays the expected map content. Consult the [installation and setup guide](https://developers.arcgis.com/qt/install-and-set-up/) if SDK discovery, linking, or deployment fails.
- [ ] **Authentication and licensing:** Confirm the authentication method fits the resources and user experience, and that the configured credentials have the required privileges. Run the app against an intended resource and verify the expected access or sign-in flow. Check that the license level covers the APIs used. Never commit, print, or expose API keys, tokens, client secrets, or user credentials. If credentials or a suitable account are unavailable, report that runtime authentication was not verified. See [how to authenticate](https://developers.arcgis.com/qt/security-and-authentication/how-to-authenticate/) and [license levels and capabilities](https://developers.arcgis.com/qt/license-and-deployment/license-levels-and-capabilities/).
- [ ] **Feature behavior:** Run the app on at least one intended target and exercise the changed workflow, including its relevant success and failure paths. Verify expected map, scene, layer, or analysis results; for workflows involving network access, location, offline data, or editing, check the relevant permission, connectivity, and error states. Confirm loading and errors are handled without making the UI unresponsive. Use the [Qt tutorials](https://developers.arcgis.com/qt/tutorials/) or [sample code](https://developers.arcgis.com/qt/cpp/sample-code/) as a reference where useful.
- [ ] **Code and regression review:** Check the changes against this skill and the applicable Qt SDK guidance. Verify asynchronous work and UI updates follow the SDK's recommended patterns, resources and errors are handled appropriately, and credentials are not embedded. Run relevant existing tests and check for regressions in adjacent workflows.
- [ ] **Skill behavior:** Test the skill in a new and an existing Qt project when available. Try a straightforward request, a more complex request, an underspecified request, and a failure or constraint scenario. Confirm the agent consults the MCP documentation, asks for missing platform or version details when needed, produces buildable guidance for the project's Qt/C++ and qmake/CMake setup, and does not claim unperformed validation. Where practical, use an official Qt tutorial as an end-to-end test.