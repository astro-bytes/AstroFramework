# TestSettingFoundation

A debug settings screen you assemble from small pieces, one per thing you want to inspect or flip
at runtime. No dependencies beyond SwiftUI and Foundation.

## Describing a setting

Conform to ``TestSetting`` for a read-only row, or to one of the specialised protocols for one that
does something:

| Protocol | Row |
|---|---|
| `TestSetting` | Title and detail, read-only |
| `ToggleTestSetting` | A switch |
| `PickerTestSetting` | A menu of `PickerOption`s |
| `ActionTestSetting` | A button, optionally behind a confirmation |
| `InputTestSetting` | A button opening a text prompt |
| `DestinationTestSetting` | A row pushing a screen of your own |
| `CustomTestSetting` | A row you draw yourself |

```swift
struct WebsiteEnvironmentSetting: PickerTestSetting {
    let urls: URLConstructor

    let title = "Website Environment"
    let section = TestSettingSection.environment

    var detail: String? { "Links open \(urls.endpoint.origin)" }
    var initialSelection: String? { urls.environment.label }
    var options: [any PickerOption] { URLEnvironment.allCases }

    func onUpdate(_ selection: String?) {
        // nil is the picker's own placeholder row, not an environment.
        guard let environment = URLEnvironment.allCases.first(where: { $0.label == selection })
        else { return }
        urls.select(environment)
    }
}
```

Only `title` is required. `detail`, `section`, `priority`, `hidden` and `id` all have defaults.

## Drawing your own row

The six built-in row types cover most debug screens. For the ones they do not — a slider, a colour
well, a live readout — conform to `CustomTestSetting` and return whatever you want:

```swift
struct RenderScaleSetting: CustomTestSetting {
    let title = "Render Scale"
    @Bindable var renderer: Renderer

    func makeRow() -> some View {
        VStack(alignment: .leading) {
            Text(title)
            Slider(value: $renderer.scale, in: 0.5 ... 2)
        }
    }
}
```

A custom row is checked for before any built-in conformance, so a setting that is both this and a
`ToggleTestSetting` draws what `makeRow()` returns. It is placed in the list and decorated like any
other row, so it picks up your row decorator and the section it named.

Precedence among the built-ins is a fixed order — destination, picker, toggle, action, input — not
a judgement about specificity. A setting conforming to two of them draws the first in that list.

`id` defaults to a value derived from the row's own content, so resolving the same setting twice
yields the same row identity and SwiftUI keeps the row's state across a re-render. Override it only
if a row's content changes while its identity should not.

## Sections

A section is a value — a label and a rank — and settings name the one they belong to:

```swift
extension TestSettingSection {
    static let user = TestSettingSection(label: "User", priority: 1)
    static let configuration = TestSettingSection(label: "Configuration", priority: 2)
    static let environment = TestSettingSection(label: "Environment")
}
```

Lower `priority` sorts first; ties break alphabetically. The default is `.max`, so an unranked
section sits in the alphabetical crowd at the bottom and only rises when you say so. The same is
true of `priority` on a setting, within its section.

A section earns its existence by having something to group. One-of-a-kind settings belong in
`.general` — a section of one is a heading that costs a row and says nothing.

## Presenting

```swift
content.testSettings(settings.grouped())
```

`grouped()` buckets a `[any TestSetting]` into the sections they name. That is the whole assembly
step — how you collect the settings in the first place is yours. Nothing here knows about any
particular DI container.

## Configuration

The framework owns the structure. `TestSettingsConfiguration` is everything else — the parts an app
would otherwise have to fork the module to change:

| | |
|---|---|
| `isEnabled` | `false` adds no toolbar button at all — for screenshot and demo runs |
| `title` | Navigation title |
| `tint` | Applied to the presented list and everything in it |
| `dynamicTypeSizes` | Clamp for the whole screen |
| `usesZoomTransition` | Whether the list animates out of its toolbar button |
| `toolbar` | Placement, label, symbol, trailing spacer |
| `emptyState` | Copy for "nothing registered" |
| `root` / `destination` / `row` | View decorators — see below |

The three decorators are the escape hatch for the places the framework builds the view and an app
cannot otherwise get a modifier onto it: the list itself, a screen pushed from a
`DestinationTestSetting`, and an individual row.

```swift
let configuration = TestSettingsConfiguration(
    isEnabled: !AppEnvironment.isScreenshot,
    tint: theme.tint,
    toolbar: .init(placement: .primaryAction),
    root: TestSettingDecorator { content in
        content
            .themeTint()
            .toast(isPresenting: $isCopied) { AlertToast(title: "Copied") }
    },
    destination: TestSettingDecorator { $0.themeTint() }
)

content.testSettings(settings.grouped(), configuration: configuration)
```

Resolve the configuration however you resolve anything else and pass it in; it is written into the
SwiftUI environment from there, so rows and pushed destinations pick it up without being threaded
through.

## Migrating from 0.2.2

The module was unreleased in practice, so these changes are breaking without a deprecation path.

| Change | What to do |
|---|---|
| `TestSetting` no longer conforms to `Identifiable, Hashable` | Delete any `id: UUID` and hand-written `==` from your settings |
| `id` is now `String`, derived from content | Nothing, unless you were relying on per-instance identity |
| `priority` default is `.max`, was `0` | An unranked setting now sorts last instead of first; rank the ones you want first |
| `TestSettingSection.id` is derived, `Hashable` is synthesized | Nothing. Previously, two equal sections could hash apart and draw the same heading twice |
| `TestSettingSection.priority` default is `.max`, was `0` | As above |
| `PickerOption.name` is `String`, was `String?` | Drop the optionality |
| `PickerTestSetting.initialSelection` is no longer `async` | Cache anything you were awaiting before the setting is registered |
| `TestSettingsView` takes a `configuration` | Optional — it defaults |
| `TestSettingsViewModifier` takes a `configuration` | Optional — it defaults |
| `InputTestSettingRow` reports its value on confirm only | Previously it reported once per keystroke, and reported `""` on Cancel |
| `DestinationTestSetting.destination` is an `associatedtype`, was `AnyView` | Return `some View` and drop the `AnyView(...)` wrapper |
