# ``APNS``

A non-blocking Swift module for sending remote Apple Push Notification requests to APNS built on AsyncHttpClient.

## Installation

To install `APNSwift`, just add the package as a dependency in your [**Package.swift**](https://github.com/apple/swift-package-manager/blob/master/Documentation/PackageDescriptionV4.md#dependencies).

```swift
dependencies: [
    .package(url: "https://github.com/swift-server-community/APNSwift.git", from: "6.0.0"),
]
```

## Getting Started
APNSwift aims to provide semantically correct structures to sending push notifications. You first need to setup a [`APNSClient`](https://github.com/swift-server-community/APNSwift/blob/main/Sources/APNS/APNSClient.swift). To do that youll need to know your authentication method 

```swift
let client = APNSClient(
    configuration: .init(
        authenticationMethod: .jwt(
            privateKey: try .init(pemRepresentation: privateKey),
            keyIdentifier: keyIdentifier,
            teamIdentifier: teamIdentifier
        ),
        environment: .development
    ),
    eventLoopGroupProvider: .createNew,
    responseDecoder: JSONDecoder(),
    requestEncoder: JSONEncoder()
)

// Shutdown the client when done
try await client.shutdown()
```

## Sending a simple notification
All notifications require a payload, but that payload can be empty. Payload just needs to conform to `Encodable`

```swift
struct Payload: Codable {}

try await client.sendAlertNotification(
    .init(
        alert: .init(
            title: .raw("Simple Alert"),
            subtitle: .raw("Subtitle"),
            body: .raw("Body"),
            launchImage: nil
        ),
        expiration: .immediately,
        priority: .immediately,
        topic: "com.app.bundle",
        payload: Payload()
    ),
    deviceToken: "device-token"
)
```

## Authentication
`APNSwift` provides two authentication methods. `jwt`, and `TLS`. 

**`jwt` is preferred and recommend by Apple** 
These can be configured when created your `APNSClientConfiguration`

*Notes: `jwt` requires an encrypted version of your .p8 file from Apple which comes in a `pem` format. If you're having trouble with your key being invalid please confirm it is a PEM file*
```
openssl pkcs8 -nocrypt -in /path/to/my/key.p8 -out ~/Downloads/key.pem
```

## Logging
By default APNSwift has a no-op logger which will not log anything. However if you pass a logger in, you will see logs.

There are currently two kinds of loggers.
#### **Background Activity Logger**
This logger can be passed into the `APNSClient` and will log background things like connection pooling, auth token refreshes, etc. 

#### **Notification Send Logger**
This logger can be passed into any of the `send:` methods and will log everything related to a single send request. 

## Server Example
Take a look at [Program.swift](https://github.com/swift-server-community/APNSwift/blob/main/Sources/APNSwiftExample/Program.swift)

## iOS Examples

For an iOS example, open the example project within this repo. 

Once inside configure your App Bundle ID and assign your development team. Build and run the ExampleApp to iOS Simulator, grab your device token, and plug it in to server example above. Background the app and run Program.swift

## Original pitch and discussion on API

* Pitch discussion: [Swift Server Forums](https://forums.swift.org/t/apple-push-notification-service-implementation-pitch/20193)
* Proposal: [SSWG-0006](https://forums.swift.org/t/feedback-nioapns-nio-based-apple-push-notification-service/24393)
* 5.0 breaking changings: [Swift Server Forums]([Blog post here on breaking changing](https://forums.swift.org/t/apnswift-5-0-0-beta-release/60075/3))
