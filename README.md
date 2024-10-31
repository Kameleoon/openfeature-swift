# Kameleoon OpenFeature provider for Swift

The Kameleoon OpenFeature provider for Swift allows you to connect your OpenFeature Swift implementation to Kameleoon without installing the Swift Kameleoon SDK.

> [!WARNING]
> This is a beta version. Breaking changes may be introduced before general release.

## Supported Swift sdk versions

This version of the SDK is built for the following targets:

* iOS 14 and above.

## Get started

This section explains how to install, configure, and customize the Kameleoon OpenFeature provider.

### Install dependencies

First, choose your preferred dependency manager from the following options and install the required dependencies in your application.

<details>
<summary>Swift Package Manager</summary>
<br/>
With <a href="https://github.com/apple/swift-package-manager">Swift Package Manager</a>, add a <a href="https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app">package dependency to your Xcode project</a>. Select **File > Swift Packages > Add Package Dependency** and enter the repository URL: `https://github.com/Kameleoon/openfeature-swift.git`.

Alternatively, you can modify your `Package.swift` file directly:

```swift
dependencies: [
  .package(url: "https://github.com/Kameleoon/openfeature-swift.git", from("0.0.1"))
]
```
</details>
<details>
<summary>Cocoapods</summary>
<br/>
With <a href="https://guides.cocoapods.org/using/using-cocoapods.html">CocoaPods</a>, paste the following code in your Podfile and replace `YOUR_TARGET_NAME` with the value for your app:

```swift
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
  pod 'KameleoonOpenfeature'
end
```

Then, in a command prompt, in the `Podfile` directory, run the install command:

```custom_code
pod install
```
</details>


### Usage

The following example shows how to use the Kameleoon provider with the OpenFeature SDK.

```swift
let siteCode = "siteCode"
let userId = "userId"
let featureKey = "featureKey"

let provider = try KameleoonProvider(siteCode: siteCode, visitorCode: userId)
// or if you want that visitor code will be generated automatically
let provider = try KameleoonProvider(siteCode: siteCode)
await OpenFeatureAPI.shared.setProviderAndWait(provider: provider)
client = OpenFeatureAPI.shared.getClient()

let evalContext = MutableContext(attributes: [DataType.variableKey: .string("stringKey")])
OpenFeatureAPI.shared.setEvaluationContext(evaluationContext: evalContext)

let numberOfRecommendedProducts = client.getIntegerValue(key: "featureKey", defaultValue: 5)
showRecommendedProducts(numberOfRecommendedProducts);
```

#### Customize the Kameleoon provider

You can customize the Kameleoon provider by changing the `KameleoonClientConfig` object that you passed to the constructor above. For example:

```swift
let config = KameleoonClientConfig(
    refreshIntervalMinute: 60, // in minutes. Optional field
    defaultTimeoutMillisecond: 10_000, // in milliseconds, 10 seconds by default, optional
    environment: "staging" // optional
)
let provider = try KameleoonProvider(siteCode: "siteCode", visitorCode: "userId", config: config);
```
</details>

> [!NOTE]
> For additional configuration options, see the [Kameleoon documentation](https://developers.kameleoon.com/feature-management-and-experimentation/mobile-sdks/ios-sdk/#create).

## EvaluationContext and Kameleoon Data

Kameleoon uses the concept of associating `Data` to users, while the OpenFeature SDK uses the concept of an `EvaluationContext`, which is a dictionary of string keys and values. The Kameleoon provider maps the `EvaluationContext` to the Kameleoon `Data`.


```swift
let evalContext = MutableContext(attributes: [:])
OpenFeatureAPI.shared.setEvaluationContext(evaluationContext: context);
```

The Kameleoon provider provides a few predefined parameters that you can use to target a visitor from a specific audience and track each conversion. These are:

| Parameter | Description |
| --------- | ----------- |
| `DataType.variableKey` | The parameter is used to set key of the variable you want to get a value. |
| `DataType.customData` | The parameter is used to set [`CustomData`](https://developers.kameleoon.com/feature-management-and-experimentation/mobile-sdks/ios-sdk/#customdata) for a visitor.     |
| `DataType.conversion`  | The parameter is used to track a [`Conversion`](https://developers.kameleoon.com/feature-management-and-experimentation/mobile-sdks/ios-sdk/#conversion) for a visitor. |

### DataType.variableKey

The `DataType.variableKey` field has the following parameter:

| Type | Description |
| ---- | ----------- |
| `Value.string` | Value of the key of the variable you want to get a value This field is mandatory. |


### DataType.customData

Use `DataType.customData` to set [`CustomData`](https://developers.kameleoon.com/feature-management-and-experimentation/mobile-sdks/ios-sdk/#customdata) for a visitor. For creation use `DataType.makeCustomData` method with the following parameters:

| Parameter | Type | Description |
|-----------| ---- | ----------- |
| id | `Int` | Index or ID of the custom data to store. This field is mandatory. |
| values | `String...` or `[String]` | Value(s) of the custom data to store. This field is optional. |

```swift
let customDataAttributes: [String: Value] = [
    DataType.customData: DataType.makeCustomData(id: 2, values: "true")
]

let evalContext = MutableContext(attributes: customDataAttributes)
OpenFeatureAPI.shared.setEvaluationContext(evaluationContext: context);
```

### DataType.conversion

Use `DataType.conversion` to track a [`Conversion`](https://developers.kameleoon.com/feature-management-and-experimentation/mobile-sdks/ios-sdk/#conversion) for a visitor. For creation use `DataType.makeConversion` method with the following parameters:

| Parameter | Type | Description |
|-----------| ---- | ----------- |
| goalId | `Int` | Identifier of the goal. This field is mandatory. |
| revenue | `Double` | Revenue associated with the conversion. This field is optional. |


```swift
let conversionAttributes: [String: Value] = [
    DataType.conversion: DataType.makeConverstion(goalId: 2, revenue: 10)
]

let evalContext = MutableContext(attributes: conversionAttributes)
OpenFeatureAPI.shared.setEvaluationContext(evaluationContext: context);
```

### Use multiple Kameleoon Data types

You can provide many different kinds of Kameleoon data within a single `EvaluationContext` instance.

For example, the following code provides one `DataType.conversion` instance and two `DataType.customData` instances.

```swift
let allTypesAttributes: [String: Value] = [
    DataType.variableKey: .string("variableKey"),
    DataType.conversion: DataType.makeConversion(goalId: 1, revenue: 200.5),
    DataType.conversion: .list([
        DataType.makeCustomData(id: 1, values: "10", "30"),
        DataType.makeCustomData(id: 2, values: "20")
    ])
]

let evalContext = MutableContext(attributes: customDataAttributes)
OpenFeatureAPI.shared.setEvaluationContext(evaluationContext: context);
```
