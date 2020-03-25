//===----------------------------------------------------------------------===//
//
// This source file is part of the APNSwift open source project
//
// Copyright (c) 2019 the APNSwift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of APNSwift project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import NIO
import NIOHTTP1
import NIOHTTP2

/// This is a protocol which allows developers to construct their own Notification payload
public protocol APNSwiftNotification: Encodable {
    var aps: APNSwiftPayload { get }
}

/// This structure provides the data structure for an APNS Payload
public struct APNSwiftPayload: Encodable {
    public let alert: APNSwiftAlert?
    public let badge: Int?
    public let sound: APNSwiftSoundType?
    public let contentAvailable: Int?
    public let mutableContent: Int?
    public let category: String?
    public let threadID: String?

    public init(alert: APNSwiftAlert? = nil, badge: Int? = nil, sound: APNSwiftSoundType? = nil, hasContentAvailable: Bool = false, hasMutableContent: Bool = false, category: String? = nil, threadID: String? = nil) {
        self.alert = alert
        self.badge = badge
        self.sound = sound
        self.contentAvailable = hasContentAvailable ? 1 : 0
        self.mutableContent = hasMutableContent ? 1 : 0
        self.category = category
        self.threadID = threadID
    }

    enum CodingKeys: String, CodingKey {
        case alert
        case badge
        case sound
        case contentAvailable = "content-available"
        case mutableContent = "mutable-content"
        case category
        case threadID = "thread-id"
    }
    /// This structure provides the data structure for an APNS Alert
    public struct APNSwiftAlert: Codable {
        public let title: String?
        public let subtitle: String?
        public let body: String?
        public let titleLocKey: String?
        public let titleLocArgs: [String]?
        public let actionLocKey: String?
        public let locKey: String?
        public let locArgs: [String]?
        public let launchImage: String?

        /**
         This structure provides the data structure for an APNS Alert
         - Parameter title: The title to be displayed to the user.
         - Parameter subtitle: The subtitle to be displayed to the user.
         - Parameter body: The body of the push notification.
         - Parameter titleLocKey: The key to a title string in the Localizable.strings file for the current
         localization.
         - Parameter titleLocArgs: Variable string values to appear in place of the format specifiers in
         title-loc-key.
         - Parameter actionLocKey: The string is used as a key to get a localized string in the current localization
         to use for the right button’s title instead of “View”.
         - Parameter locKey: A key to an alert-message string in a Localizable.strings file for the current
         localization (which is set by the user’s language preference).
         - Parameter locArgs: Variable string values to appear in place of the format specifiers in loc-key.
         - Parameter launchImage: The filename of an image file in the app bundle, with or without the filename
         extension.

         For more information see:
         [Payload Key Reference](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html#)
         ### Usage Example: ###
         ````
         let alert = Alert(title: "Hey There", subtitle: "Subtitle", body: "Body")
         ````
         */
        public init(title: String? = nil, subtitle: String? = nil, body: String? = nil,
                    titleLocKey: String? = nil, titleLocArgs: [String]? = nil, actionLocKey: String? = nil,
                    locKey: String? = nil, locArgs: [String]? = nil, launchImage: String? = nil) {
            self.title = title
            self.subtitle = subtitle
            self.body = body
            self.titleLocKey = titleLocKey
            self.titleLocArgs = titleLocArgs
            self.actionLocKey = actionLocKey
            self.locKey = locKey
            self.locArgs = locArgs
            self.launchImage = launchImage
        }

        enum CodingKeys: String, CodingKey {
            case title
            case subtitle
            case body
            case titleLocKey = "title-loc-key"
            case titleLocArgs = "title-loc-args"
            case actionLocKey = "action-loc-key"
            case locKey = "loc-key"
            case locArgs = "loc-args"
            case launchImage = "launch-image"
        }
    }
    public struct APNSSoundDictionary: Encodable {
        public let critical: Int
        public let name: String
        public let volume: Double

        /**
         Initialize an APNSSoundDictionary
         - Parameter critical: The critical alert flag. Set to true to enable the critical alert.
         - Parameter sound: The apps path to a sound file.
         - Parameter volume: The volume for the critical alert’s sound. Set this to a value between 0.0 (silent) and 1.0 (full volume).

         For more information see:
         [Payload Key Reference](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html#)
         ### Usage Example: ###
         ````
         let apsSound = APNSSoundDictionary(isCritical: true, name: "cow.wav", volume: 0.8)
         let aps = APNSwiftPayload(alert: alert, badge: 1, sound: .dictionary(apsSound))
         ````
         */
        public init(isCritical: Bool, name: String, volume: Double) {
            self.critical = isCritical ? 1 : 0
            self.name = name
            self.volume = volume
        }
    }
    /**
     An enum to define how to use sound.
     - Parameter string: use this for a normal alert sound
     - Parameter critical: use for a critical alert type
     */
    public enum APNSwiftSoundType: Encodable {
        case normal(String)
        case critical(APNSSoundDictionary)
    }
}

extension APNSwiftPayload.APNSwiftSoundType {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .normal(let string):
            try container.encode(string)
        case .critical(let dict):
            try container.encode(dict)
        }
    }
}
