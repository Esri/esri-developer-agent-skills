# Authentication in Qt apps (ArcGIS Maps SDK for Qt 300.x)

How to implement API key and user (OAuth/token/network) authentication in a Qt app; choosing the type is out of scope.
Contents: 1 Choosing · 2 API key · 3 300.x auth classes · 4 User auth with the toolkit (OAuth) · 5 Own challenge handler · 6 Persisting and signing out · 7 Samples and docs

## 1. Choosing an auth type

If the `follow-arcgis-authentication-patterns` skill is available, use it to pick API key vs user vs app
authentication. Rule of thumb: API key for location services and public content without sign-in; user
authentication (OAuth) when the app accesses a user's or organization's private items, or bills usage to the user.
Both can coexist: the API key covers basemaps/geocoding, and challenges for secured items go to the handler.

## 2. API key

Set it once at startup, before any SDK object is created, from the environment (as the generated `main.cpp` does):

```cpp
#include "ArcGISRuntimeEnvironment.h"
const QString accessToken = qEnvironmentVariable("ARCGIS_RUNTIME_API_KEY");
if (accessToken.isEmpty())
  qWarning() << "ARCGIS_RUNTIME_API_KEY is not set: basemap styles and location services will fail.";
else
  Esri::ArcGISRuntime::ArcGISRuntimeEnvironment::setApiKey(accessToken);
```

- **Never hard-code or commit a key** (no string literals, no key in `CMakeLists.txt`, `.qrc`, QML, or test fixtures).
  Read it from the environment or a config file outside version control; ask the user to set the variable.
- **Least privilege:** create the API key credential with only the privileges the app uses (e.g. basemaps,
  geocoding) and an expiration date. https://developers.arcgis.com/documentation/security-and-authentication/api-key-authentication/
- Per-resource keys: classes implementing `ApiKeyResource` (`Basemap`, `LocatorTask`, `RouteTask`,
  `ServiceFeatureTable`, `ArcGISTiledLayer`, ...) have `setApiKey()` - use only when one resource needs a different key.
- **Without a key** (and no challenge handler), `Map(BasemapStyle::…)` stays blank and geocoding/routing/places
  fail. The log shows (verified, 300.2):
  `"An ArcGIS authentication error occurred when accessing https://www.arcgis.com. An API key or credential may be required. ..."`
  preceded by `qt.network.http2: stream 1 finished with error: "Host requires authentication"`.
  With a toolkit `Authenticator` installed, the same failure shows up as a sign-in dialog instead.
- 300.x removed `ArcGISRuntimeEnvironment::setUseLegacyAuthentication` (200.x templates called it) - delete such calls.

## 3. 300.x authentication classes

All in namespace `Esri::ArcGISRuntime::Authentication`, included as `"Authentication/<Name>.h"`
(the 100.x/200.x-legacy root headers `AuthenticationManager.h`, `Credential.h`, `AuthenticationChallenge.h` do not exist in 300.x).

| Class | Use |
|---|---|
| `AuthenticationManager` | Singleton via `ArcGISRuntimeEnvironment::authenticationManager()`; holds the challenge handlers and credential stores |
| `ArcGISAuthenticationChallengeHandler` | Abstract; override `handleArcGISAuthenticationChallenge(ArcGISAuthenticationChallenge*)` (ArcGIS token/OAuth) |
| `NetworkAuthenticationChallengeHandler` | Abstract; `handleNetworkAuthenticationChallenge(...)` (IWA, HTTP basic/digest, PKI, server trust) |
| `ArcGISAuthenticationChallenge` | `requestUrl()`, `previousFailureCount()`, `continueWithCredential()`, `continueWithError()`, `continueAndFail()`, `cancel()` |
| `OAuthUserConfiguration` | `(portalUrl, clientId, redirectUri, parent)`; `canBeUsedForUrl()` |
| `OAuthUserCredential` | `createAsync(config)`, `tokenInfoAsync()`, `revokeTokenAsync()` |
| `TokenCredential` | `createAsync(url, user, password, std::optional<int> expiration)`, `createWithChallengeAsync(challenge, ...)` |
| `ArcGISCredentialStore` | `add(cred[, url])`, `credential(url)`, `remove`, `removeAll()`; static `makePersistent()` → `QFuture` |
| `NetworkCredentialStore` | `credentialsForHost(host)`, `removeAllAsync()` → `QFuture<void>`; static `makePersistent()` → `QFuture` |

Every `...Async()` returns `QFuture<T>`: `#include <QFuture>` and chain `.then(context, ...)`.

## 4. User authentication with the toolkit (recommended; required for OAuth)

The OAuth sign-in UI is driven by internal SDK prompts (`OAuthUserLoginPrompt.h` warns it is "not intended to be
used directly") that the toolkit's `Authenticator` handles. So for OAuth: integrate the toolkit
(`project-integration.md` §4, version-matched to the SDK) and do three things:

```cpp
// main.cpp
QtWebView::initialize();                                    // before QGuiApplication: in-app OAuth web view
QGuiApplication app(argc, argv);
// ... setApiKey as in §2 (optional), then:
QQmlApplicationEngine engine;
Esri::ArcGISRuntime::Toolkit::registerComponents(engine);
```

```cpp
// in the app class constructor (e.g. <Name>.cpp)
#include "Authentication/OAuthUserConfiguration.h"
#include "OAuthUserConfigurationManager.h"   // toolkit (uitools/common/src)
#include <QUrl>
const QString clientId = qEnvironmentVariable("ARCGIS_OAUTH_CLIENT_ID");   // example name; client ID from your app registration
auto* config = new Esri::ArcGISRuntime::Authentication::OAuthUserConfiguration(
    QUrl("https://www.arcgis.com"), clientId, "urn:ietf:wg:oauth:2.0:oob", this);   // the manager takes ownership
Esri::ArcGISRuntime::Toolkit::OAuthUserConfigurationManager::addConfiguration(config);
```

```qml
import Esri.ArcGISRuntime.Toolkit
Authenticator { anchors.centerIn: parent }   // one per app, on top of the view
```

- Without an `OAuthUserConfiguration` matching the portal, ArcGIS-secured portals fall back to a username/password
  (token) dialog. IWA and PKI need no configuration; the `Authenticator` detects them.
- Redirect URI: `urn:ietf:wg:oauth:2.0:oob` = embedded web view (needs `QtWebView::initialize()`); any other
  URI (custom scheme such as `my-app://auth`) = system browser via Qt NetworkAuth - register the same URI in the
  app registration and with the OS. The redirect URI must match the registration exactly.
- Trigger a sign-in by loading something secured, e.g. `new Portal(true /*loginRequired*/, this)` then `load()`;
  a canceled login surfaces as `portal->loadError().errorType() == ErrorType::AuthenticationChallengeCanceled`
  (`Error.h` + `ErrorTypes.h`).
- 200.x toolkit used `AuthenticationView`; in 300.x it is `Authenticator`.
- Verified: template + toolkit 300.2 with this code builds and runs with no QML errors (Qt 6.8.3).

## 5. Your own challenge handler (no toolkit; token login from your own UI)

```cpp
// TokenChallengeHandler.h
class TokenChallengeHandler : public Esri::ArcGISRuntime::Authentication::ArcGISAuthenticationChallengeHandler
{
  Q_OBJECT
public:
  explicit TokenChallengeHandler(QObject* parent = nullptr);
protected:
  void handleArcGISAuthenticationChallenge(
      Esri::ArcGISRuntime::Authentication::ArcGISAuthenticationChallenge* challenge) override;
};

// TokenChallengeHandler.cpp (using namespace Esri::ArcGISRuntime; using namespace ...::Authentication;)
TokenChallengeHandler::TokenChallengeHandler(QObject* parent) : ArcGISAuthenticationChallengeHandler(parent)
{
  ArcGISRuntimeEnvironment::authenticationManager()->setArcGISAuthenticationChallengeHandler(this);
}
void TokenChallengeHandler::handleArcGISAuthenticationChallenge(ArcGISAuthenticationChallenge* challenge)
{
  if (challenge->previousFailureCount() > 2) { challenge->continueAndFail(); return; }
  // user/password come from your login UI - never from source code
  TokenCredential::createWithChallengeAsync(challenge, user, password, {}, this)
    .then(this, [challenge](TokenCredential* c) { challenge->continueWithCredential(c); })
    .onFailed(this, [challenge](const ErrorException& e) { challenge->continueWithError(e.error()); });
}
```

Headers: `ArcGISRuntimeEnvironment.h`, `Authentication/ArcGISAuthenticationChallengeHandler.h`,
`Authentication/ArcGISAuthenticationChallenge.h`, `Authentication/AuthenticationManager.h`,
`Authentication/TokenCredential.h`, `Error.h`, `ErrorException.h`, `<QFuture>`. Only one ArcGIS handler is active:
it replaces the toolkit's (do not combine with `Authenticator`). Compiled and run on 300.2.

## 6. Persisting credentials and signing out

Headers: `ArcGISRuntimeEnvironment.h`, `Authentication/ArcGISCredentialStore.h`, `Authentication/AuthenticationManager.h`, `<QFuture>`.

```cpp
Authentication::ArcGISCredentialStore::makePersistent(&app).then(&app, [](Authentication::ArcGISCredentialStore* store)
{ ArcGISRuntimeEnvironment::authenticationManager()->setArcGISCredentialStore(store); });   // compiled, 300.2
```

Sign out: `OAuthUserCredential::revokeTokenAsync()` for OAuth credentials, then
`authenticationManager()->arcGISCredentialStore()->removeAll()`, and `authenticationManager()->networkCredentialStore()->removeAllAsync()` (returns `QFuture<void>`).

## 7. Samples and docs

- Samples (`CppSamples/CloudAndPortal/`): `PortalUserInfo` (OAuth + `Authenticator` + `OAuthUserConfigurationManager`),
  `TokenAuthentication`, `IntegratedWindowsAuthentication`, `ShowOrgBasemaps`, `AddItemsToPortal`.
  Own handler: `CppSamples/EditData/EditWithBranchVersioning`.
- https://developers.arcgis.com/qt/security-and-authentication/how-to-authenticate/
- https://developers.arcgis.com/qt/security-and-authentication/implement-authentication/
- https://developers.arcgis.com/qt/security-and-authentication/tutorials/access-services-with-oauth-2-0/
- https://developers.arcgis.com/documentation/security-and-authentication/
