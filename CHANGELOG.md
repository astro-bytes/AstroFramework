# Changelog

Notable changes to AstroFramework. Versions follow [Semantic Versioning](https://semver.org),
where a pre-1.0 minor bump may carry breaking changes.

## Unreleased

Breaking throughout. The package moves to the Swift 6 language mode, and several APIs change shape
to be honest about what they do.

### Fixed

- **`Repository.get()` waited out its full timeout before returning a value it already held.**
  `AnyPublisher.first(timeoutAfter:where:)` was implemented with Combine's `last(where:)`, which
  holds values until the upstream finishes — and a repository's publisher never finishes. Measured
  at 5.001s against a repository holding `.success`. The test suite drops from 67s to 15s.
- **A successful refresh threw `CoreError.notFound`.** The uninitialized branch of
  `Repository.get` guarded on `error.isNotNil` where it meant `isNil`, so a success failed the
  guard and fell through to the not-found path.
- **`OnDiskCache` renewed its own expiry on every construction.** Loading a cache routed through
  `set`, which stamps the write date, so a cache re-created more often than its lifetime never went
  stale and never refetched.
- **`Color(hex:)` returned black for any unsupported length**, including `#FFF` — the fallback
  branch was missing a `return` and initialized twice. It also parsed partly-hex strings as
  silently wrong colours; `"FFZZZZ"` became `0x0000FF`.
- **`Logger` was an unsynchronised global.** Registration appended to an array on the caller's
  thread while a detached task iterated it. Logs also arrived out of order, one detached task each.
- **Five reachable crashes**: two `as!` casts in `Bundle`, `fatalError` in `Color.hexValue` on
  every platform but iOS, and two in `OnDiskCache`.
- **The error alert changed its own view identity** on every present and dismiss, by branching its
  body on whether the error was nil.
- **`AsyncButton` stayed tappable while its action ran**, so two taps ran it twice.
- **`OnDiskCache.set` swallowed write failures**, logging a warning and returning as though the
  write had succeeded.

### Added

- `Logger.minimumLevel` filters by severity before delivery. `Level` is `Comparable`.
- `Logger.apply` returns a token; `Logger.remove(_:)`, `removeAllInterceptors()` and `reset()`.
- `CustomTestSetting` lets an app draw its own Test Settings row.
- `Mocks` is a product, so apps can build against the same fakes the package tests with. Its spy
  flags are publicly readable.
- `Color(hex:)` accepts three- and four-digit shorthand.
- CI builds the package for iOS, builds `TestSettingFoundation`, runs on pushes to `main`, and
  rebuilds with warnings as errors.

### Changed

- **Swift 6 language mode**, `swift-tools-version: 6.2`. `Entity`, repository payloads and data
  store elements require `Sendable`; `Interceptor` requires `Sendable`.
- `Bundle.appVersion`, `buildVersion` and `fullAppVersion` return `String?`.
- `Color(hex:)` is failable rather than substituting a fallback colour.
- `Color.hexValue` returns `String?` and works on every platform.
- `DataStore` refines `Repository`, and `KeyedDataStore` refines `KeyedRepository`, instead of
  restating their requirements.
- `DestinationTestSetting.destination` is an `associatedtype` rather than `AnyView`.
- `OSLogInterceptor` writes structured fields through `os.Logger`, with the error and data
  dictionary marked private so they are redacted in release builds.
- `Logger.log` defaults `file:` to `#fileID`, not `#file`.
- Every source file in `TestSettingFoundation` loses its `-test.swift` suffix.

### Removed

- **`OnDiskCache`'s `encrypted` parameter**, which defaulted to `true` and encrypted nothing. Every
  path it guarded was a `// TODO`. Payloads were, and still are, plaintext JSON.
- `errorAlert(error:retry:)` and `errorAlert(error:asyncRetry:)`, which took a closure and
  forwarded it nowhere.
- `CollectionDataStore`, which restated `KeyedDataStore` and had no conformers.
- `.swiftpm/PackageDeal-Package.xctestplan`, which named six targets that no longer exist.

### Tests

172 tests, up from 84. UIFoundation had 0% line coverage and TestSettingFoundation 8.7%; both are
covered now. The placeholder tests are gone — `testExample()` bodies that asserted nothing, an
`XCTAssertTrue(true)`, and three tests that asserted only inside `catch` and so passed when nothing
was thrown. The suite is clean under `--sanitize=thread`.

## 0.3.0 and earlier

See the commit history.
