---
name: confirm-user-intent
description: Confirm the user's intent when building new ArcGIS applications.
license: Apache-2.0
---

Before building a new ArcGIS application, you should understand the user's intent. Make sure you have answers to the following questions, either from the user directly or from your context window:

1. Which ArcGIS Maps SDK, API, or developer technology would you like to build with (.NET Maps SDK, Swift Maps SDK, Kotlin Maps SDK, Qt Maps SDK, Flutter Maps SDK, Unreal Engine Maps SDK, Unity Maps SDK, JavaScript Maps SDK, Calcite Design System, ArcGIS Pro SDK, ArcGIS API or Python, ArcGIS plugin for Leaflet, CesiumJS, MapLibre ArcGIS, OpenLayers)?
2. Can you specify the {sdk_or_api} version you are using?
3. What products are you building with (ArcGIS Location Platform, ArcGIS Online, ArcGIS Pro, or ArcGIS Enterprise)?
4. Is there a specific product version you are using or just the latest?
5. What is the access level for the application (Personal, Private, or Public)?
6. What type of authentication do you want to implement (API key, User authentication, or App authentication)?

If available in your harness, use the ask questions or Q&A tool. Else, manually ask the user these questions in one turn. Only ask questions you need answers to - you might already have the answers in your context window.
