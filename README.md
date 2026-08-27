# AstroFramework

Reusable foundations for the layers of an app: entities, use cases, gateways, UI, logging, and a
debug settings screen. Seven independent library products, no third-party dependencies — depend on
the ones you want.

## Requirements

| | |
|---|---|
| Swift | 6.2 (the package builds in the Swift 6 language mode) |
| Platforms | iOS 26, macOS 26, watchOS 26, tvOS 26, visionOS 26, Mac Catalyst 26 |

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/astro-bytes/AstroFramework.git", from: "0.4.0")
]
```

Then take only the products a target needs:

```swift
.target(
    name: "MyFeature",
    dependencies: [
        .product(name: "UseCaseFoundation", package: "AstroFramework"),
        .product(name: "UIFoundation", package: "AstroFramework"),
    ]
)
```

## Modules

| Product | What it holds | Depends on |
|---|---|---|
| [`EntityFoundation`](#entityfoundation) | The `Entity` protocol | — |
| [`UtilityFoundation`](#utilityfoundation) | Errors, and extensions to the standard library | `LoggerFoundation` |
| [`LoggerFoundation`](#loggerfoundation) | Logging with pluggable interceptors | — |
| [`UseCaseFoundation`](#usecasefoundation) | `DataResult`, the repository ports, use-case protocols | `EntityFoundation`, `UtilityFoundation` |
| [`GatewayFoundation`](#gatewayfoundation) | Caches, data sources, data stores | `LoggerFoundation`, `UtilityFoundation`, `UseCaseFoundation` |
| [`UIFoundation`](#uifoundation) | SwiftUI helpers and error presentation | `LoggerFoundation`, `UtilityFoundation` |
| [`TestSettingFoundation`](TestSettingFoundation/README.md) | A debug settings screen | — |
| `Mocks` | Fakes for the protocols above, for your tests | `GatewayFoundation`, `UseCaseFoundation` |

### EntityFoundation

`Entity` marks a domain type: `Identifiable`, `Equatable`, `Hashable` and `Sendable`, with a
`Sendable` ID. An entity moves off a background task and into a view as a matter of course, which
is what the `Sendable` requirement is for. For the value types that conform, it costs nothing.

```swift
struct User: Entity, Codable {
    let id: UUID
    var name: String
}
```

### UtilityFoundation

`CoreError` (`notFound`, `timeout`), `EquatableError` for comparing errors that are not themselves
`Equatable`, and extensions: async `map`/`compactMap`/`reduce` on `Collection`, `TimeInterval`
constants, `Result.value`/`.error`, `Optional.isNil`, `URL.isDirectory`/`.isFile`, and
`Bundle.appVersion`.

`AnyPublisher.first(timeoutAfter:where:)` awaits the first value matching a predicate, throwing
`CoreError.timeout` if none arrives in time.

### LoggerFoundation

```swift
Logger.log(.info, msg: "Signed in.")
Logger.log(.warning, error: error, data: ["endpoint": url.absoluteString])
```

Logs go to every registered interceptor, on one serial queue, in the order the calls were made. A
`DEBUG` build gets an interceptor writing to the unified logging system; any other build starts
empty, so an app chooses where its logs go.

```swift
let token = Logger.apply(interceptor: MyInterceptor())
Logger.remove(token)

Logger.minimumLevel = .warning   // drops anything less severe before delivery
```

Levels are values, so an app can add its own — a level's `priority` decides where it sorts against
the built-in four.

### UseCaseFoundation

`DataResult` is what a repository publishes: `uninitialized`, `loading`, `success`, or `failure` —
with the last two able to carry a cached payload, so a view can keep showing something usable while
a refresh is in flight or after one fails.

`Repository` is the port a use case reads through, and `KeyedRepository` its by-identifier
counterpart. `get(within:)` awaits the first non-loading result and unwraps it.

`UseCase` and `AsyncUseCase` are one-method protocols for a unit of application logic.

### GatewayFoundation

The implementation side. `DataStore` refines `Repository`, adding a synchronous accessor for a
store that already holds its value; `KeyedDataStore` does the same for `KeyedRepository`.

`InMemoryCache` and `OnDiskCache` are expirable caches. The on-disk one keeps the payload and the
date it was written together in one file under the caches directory.

> **Note**
> Cached payloads are stored as plaintext JSON. Do not put credentials or personal data in one.

The `DataSource` family — `DataSource`, `DynamicDataSource`, `MutableDataSource`,
`PublishableDataSource`, `IdentifiablePublishableDataSource` — describes where a store gets its
data from. These are protocols only; the concrete repositories that would tie a cache to a data
source are not written yet.

### UIFoundation

`AsyncButton` runs an async action, disables itself and shows a progress indicator while it does,
and presents anything thrown.

```swift
AsyncButton("Save") { try await store.save(draft) }
```

`.errorAlert(error:)` presents an optional error. Conform an error to `DisplayableError` to choose
its wording, `ActionableError` to offer a recovery button, `AsyncActionableError` when that
recovery is asynchronous. `.reportError { }` supplies the Report button's action.

Also `Color(hex:)`, `Color.hexValue`, colour lightening and darkening, `View.isHidden(_:)` and
`View.if`.

### Type erasure

Some components erase types, because Swift still cannot express certain constraints when values
have to be `Equatable` or `Hashable` —
[background](https://stackoverflow.com/questions/76449655/swift-is-there-still-a-use-case-for-type-erasure-since-the-introduction-of-prim).

## What is not built yet

The gateway layer is protocols and two caches. The concrete repositories — polling on an interval,
subscribing to a remote source, write-through that survives a failed remote update — are described
in earlier versions of this README but were never written, and the note is here rather than there
so nobody plans around them.

## Contributing

Every pull request builds each module, builds the package for iOS, runs the tests, and rebuilds
with warnings as errors. The package is warning-free in the Swift 6 language mode and with
`-strict-concurrency=complete`; please keep it that way.

```bash
swift test
```
