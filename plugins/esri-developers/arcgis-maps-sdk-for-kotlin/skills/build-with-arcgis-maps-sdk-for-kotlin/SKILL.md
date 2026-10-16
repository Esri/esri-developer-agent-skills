---
name: build-with-arcgis-maps-sdk-for-kotlin
license: Apache-2.0
description: "Build, extend, debug, and explain Android apps with ArcGIS Maps SDK for Kotlin using official docs. Cover Gradle, SDK/Toolkit, Compose, authentication, starter maps/scenes, layers, graphics, queries, editing, location, geocoding, routing, offline workflows, and validation. Excludes Kotlin Multiplatform and other ArcGIS SDKs."
---

# Build with ArcGIS Maps SDK for Kotlin

Use this skill for native Android GIS starter apps, feature additions, and debugging.

## ArcGIS account requirements - [DO NOT EDIT]

Developers must have one of the following ArcGIS accounts to create applications with ArcGIS Maps SDK for Kotlin: ArcGIS Location Platform, ArcGIS Online, or ArcGIS Enterprise. The user type, role, and privileges for the account provides an application with access to different ArcGIS resources and operations. In general, the requirements to develop apps with these products are:

* ArcGIS Location Platform - Any ArcGIS Location Platform account can be used to develop applications with ArcGIS Maps SDK for Kotlin. Sign up for free at https://location.arcgis.com/.
* ArcGIS Online - A user type of "Creator" or higher is required to create developer credentials and set up authentication. To learn more, go to https://www.esri.com/en-us/arcgis/products/arcgis-online/overview.
* ArcGIS Enterprise - A user type of "Creator" or higher is required to create developer credentials and set up authentication. To learn more, go to https://www.esri.com/en-us/arcgis/products/arcgis-enterprise/overview.

## Authentication - [DO NOT EDIT]

ArcGIS is a secure system that requires token-based authentication to authorize access to secure resources. There are different types of authentication available. The one you use depends on the application's runtime environment, audience, use case, and level of access. Refer to the `follow-esri-authentication-patterns` skill to learn more about authentication in ArcGIS, including user authentication, API key authentication, and app authentication. The skill also shows how to select the appropriate type of authentication for an application and how to set it up correctly.
If this skill is not available, search the project workspace for existing authentication patterns. If the project has no authentication framework, query the documentation for authentication best practices using the process below and follow any SDK-specific authentication recommendations.

## Installation and setup

1. Inspect Gradle files/version catalog, Android manifest, SDK version, UI framework, and authentication. Match documentation to the installed version, including 200.x; never silently upgrade. For migrations, read version-specific release and migration guidance before changing dependencies or APIs.
2. Check release requirements for Android Studio, Android API levels, Gradle/Android Gradle Plugin, Kotlin/Compose, JDK, architectures, and graphics. Complete configuration and available command-line checks; report manual tool, emulator/device, and account prerequisites. Request credentials through secure local configuration, not chat.
3. For a new Compose app, start with **Display a map**, Android Studio's Compose Empty Activity template, and Kotlin DSL. In existing apps, preserve the UI framework, architecture, and working map/authentication flows; merge configuration rather than replacing files with tutorial files.
4. Add Esri Maven `https://esri.jfrog.io/artifactory/arcgis` and SDK dependency `com.esri:arcgis-maps-kotlin`. Use the Toolkit compatibility table to select SDK/Toolkit versions and its bill of materials (BOM) to align modules. Add only needed modules: `geoview-compose` for Compose views and `authentication` when user-authentication UI is needed. Follow the selected release's setup, not current version numbers in older apps.
5. Configure `INTERNET` permission and required view graphics features. Request location permissions only for location features; handle denial/restrictions. Use Android scoped storage for offline files, not obsolete or unrelated permissions.
6. Follow the authentication guidance above and Kotlin-specific docs. Configure API keys and licensing with documented Kotlin APIs, not another SDK's initialization methods. Never commit/log credentials or embed client secrets. APK configuration, including build-generated values, is not secret storage.
7. Sync Gradle, build, and verify a starter map on a supported emulator/device. Build success does not prove rendering or authorized resource access.

## How to query documentation - [DO NOT EDIT]

Documentation can be queried using the MCP for Esri Developers server:
```
https://developers-mcp.arcgis.com/mcp
```
Use the `search_esri_developer_docs` tool to query authoritative documentation with `kotlin-sdk` as the `focus_area` parameter in addition to the `search_term`.

## Documentation links

- [Kotlin guide](https://developers.arcgis.com/kotlin/) - capabilities, release notes, migrations; [200.x guide](https://developers.arcgis.com/kotlin/v200/) for existing 200.x apps.
- [Install and set up](https://developers.arcgis.com/kotlin/install-and-set-up/) - dependencies, manifest, system requirements.
- [Toolkit](https://developers.arcgis.com/kotlin/toolkit/) - components, modules, SDK compatibility.
- [SDK API](https://developers.arcgis.com/kotlin/api-reference/) and [Toolkit API](https://developers.arcgis.com/kotlin/toolkit-api-reference/) - imports, signatures, version availability.
- [How to authenticate](https://developers.arcgis.com/kotlin/security-and-authentication/how-to-authenticate/) - Kotlin implementation of the selected authentication model.
- [Display a map](https://developers.arcgis.com/kotlin/maps-2d/tutorials/display-a-map/) - starter project; [tutorials](https://developers.arcgis.com/kotlin/tutorials/) for other features.
- [Layer types](https://developers.arcgis.com/kotlin/layers/layer-types/) - data sources, view support, query/edit/offline capabilities.
- [Samples](https://developers.arcgis.com/kotlin/sample-code/) and [Kotlin samples repository](https://github.com/Esri/arcgis-maps-sdk-kotlin-samples/tree/main) - match the app's SDK version.
- [GeoView patterns with Jetpack Compose](https://developers.arcgis.com/kotlin/programming-patterns/geoview-patterns-with-jetpack-compose/) - state, view proxies, concurrency.
- [Loading resources asynchronously](https://developers.arcgis.com/kotlin/programming-patterns/loading-resources-asynchronously/) - loading, failures, retries.
- [Offline maps, scenes, and data](https://developers.arcgis.com/kotlin/offline-maps-scenes-and-data/) - downloads, packages, synchronization.
- [License and deployment](https://developers.arcgis.com/kotlin/license-and-deployment/), [license levels and capabilities](https://developers.arcgis.com/kotlin/license-and-deployment/license-levels-and-capabilities/), and [license by API](https://developers.arcgis.com/kotlin/license-and-deployment/license-by-api/) - requirements for the operations and data used.

## Patterns and guidelines

Follow the [Programming patterns](https://developers.arcgis.com/kotlin/programming-patterns/) chapter for the SDK version in use. Read the relevant subpages before implementing a pattern; version-matched official documentation takes precedence over the reminders below.

- Verify Kotlin APIs with `kotlin-sdk` queries that include the symbol, feature, and SDK version. Without MCP, use official documentation and disclose uncertainty. Never invent APIs or assume another SDK's names or behavior translate directly; verify a Kotlin equivalent before recommending it.
- Adapt official samples and suitable Toolkit components to the existing app. Preserve its UI framework, styling, architecture, dependency management, and working map/authentication flows; do not introduce a new framework solely to match a sample.
- Keep Compose map/scene models stable, collect state lifecycle-aware, and scope asynchronous work to the owning lifecycle. Avoid blocking the UI or repeating work during recomposition. Handle failures and empty results explicitly, preserve coroutine cancellation, and surface loading/error states; request or job completion alone does not prove success.

## Validation process

Validate for the app's SDK version, build variant, and supported Android target. Report unavailable tooling, device, credentials, account, network, or data and the checks still needed; never claim unperformed checks passed. Keep all credentials, tokens, and secrets out of source, logs, and validation output.

- [ ] **Dependencies and build:** Verify toolchain, SDK/Toolkit compatibility, dependencies/imports, manifest, and device graphics/API support. Run the Gradle wrapper's `assembleDebug` or appropriate variant task, relevant tests, and lint. Compare warnings with the baseline; report new errors/warnings and skipped checks.
- [ ] **Authentication and access:** Check audience/resource fit, portal/item/service privileges, and applicable OAuth redirects. Access an intended resource; for secured resources, verify unauthenticated rejection and authorized success. Test sign-in cancellation/denial where applicable.
- [ ] **Runtime behavior:** On a supported emulator/device, exercise changed success/failure paths. Check map/scene content, individual layers, rendering, pan/zoom, relevant GeoView interactions, and Logcat. Loading/errors must be visible without freezing the UI; a build alone proves no runtime behavior.
- [ ] **Lifecycle and workflow edges:** Test rotation, background/resume, and navigation away/back for lost state, repeated work, and coroutine cancellation. For features used, test permission denial, network loss/retry, empty results, editing results, and job failures. For offline work, test local content without connectivity and requested synchronization after reconnecting.
- [ ] **Patterns and regressions:** Review the guardrails above, including coroutine/`Result` handling and Toolkit reuse. Preserve existing architecture/dependency management; run relevant existing tests and check adjacent map/layer/workflow behavior. A starter map is not a full regression pass.
- [ ] **Production readiness:** Verify attribution and required license levels/extensions for actual operations/data. Authentication success is not licensing compliance; distinguish expected developer-use watermarks from production issues.
