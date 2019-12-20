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

import Foundation
import Logging
import NIO
import NIOHTTP2
import NIOSSL

/// This is structure that provides the system with common configuration.
public struct APNSwiftConfiguration {
    public var keyIdentifier: String
    public var teamIdentifier: String
    public var signer: APNSwiftSigner
    public var topic: String
    public var environment: Environment
    public var tlsConfiguration: TLSConfiguration
    internal var logger: Logger?

    public var url: URL {
        switch environment {
        case .production:
            return URL(string: "https://api.push.apple.com")!
        case .sandbox:
            return URL(string: "https://api.development.push.apple.com")!
        }
    }

    /**
     Call this constructor to create a new Configuration.

     - Parameters:
       - keyIdentifier: The key identifier Apple gives you when you setup your APNS key.
       - teamIdentifier: The team identifier Apple assigned you when you created your developer team
       - signingMode: provides a method by which engineers can choose how their certificates are
     signed. Since security is important keeping we extracted this logic into three options.
     `file`, `data`, or `custom`.
       - topic: The bundle identifier for these push notifications.
       - environment: The environment to use, sandbox, or production.
       - logger: The logger you wish to use, if nil, one will be created

     ### Usage Example: ###
     ````
     let apnsConfig = try APNSwiftConfiguration(keyIdentifier: "9UC9ZLQ8YW",
         teamIdentifier: "ABBM6U9RM5",
         signingMode: .file(path: "/Users/kylebrowning/Downloads/AuthKey_9UC9ZLQ8YW.p8"),
         topic: "com.grasscove.Fern",
         environment: .sandbox,
         logger: logger)
     )
     ````
     */
    public init(keyIdentifier: String, teamIdentifier: String, signer: APNSwiftSigner, topic: String, environment: APNSwiftConfiguration.Environment) {
        self.init(keyIdentifier: keyIdentifier, teamIdentifier: teamIdentifier, signer: signer, topic: topic, environment: environment, logger: nil)
    }

    public init(keyIdentifier: String, teamIdentifier: String, signer: APNSwiftSigner, topic: String, environment: APNSwiftConfiguration.Environment, logger: Logger? = nil) {
        self.keyIdentifier = keyIdentifier
        self.teamIdentifier = teamIdentifier
        self.topic = topic
        self.signer = signer
        self.environment = environment
        self.tlsConfiguration = TLSConfiguration.forClient(applicationProtocols: ["h2"])

        if var logger = logger {
            logger[metadataKey: "origin"] = "APNSwift"
            self.logger = logger
        }
    }

    /**
        Call this constructor to create a new Configuration for APNSWift with a PEM Key. Warning it is blocking!

        - Parameters:
          - privateKeyPath: The path to your private key
          - pemPath: The path to pem file.
          - topic: The bundle identifier for these push notifications.
          - environment: The environment to use, sandbox, or production.
          - logger: The logger you wish to use, if nil, one will be created
          - pemPassword: The password for the PEM private key.

        ### Usage Example: ###
        ```
        var apnsConfig = try APNSwiftConfiguration(
           privateKeyPath: "/Users/kylebrowning/Projects/swift/Fern/development_com.grasscove.Fern.pkey",
           pemPath: "/Users/kylebrowning/Projects/swift/Fern/development_com.grasscove.Fern.pem",
           topic: "com.grasscove.Fern",
           environment: .sandbox
        )
        ```
    */
    public init(privateKeyPath: String, pemPath: String, topic: String, environment: APNSwiftConfiguration.Environment, logger: Logger? = nil, pemPassword: Data? = nil) throws {
        try self.init(keyIdentifier: "", teamIdentifier: "", signer: APNSwiftSigner(buffer: ByteBufferAllocator().buffer(capacity: 1024)), topic: topic, environment: environment, logger: logger)

        let key: NIOSSLPrivateKey
        if let pemPassword = pemPassword {
            key = try NIOSSLPrivateKey(file: privateKeyPath, format: .pem) { $0(pemPassword) }
        } else {
            key = try NIOSSLPrivateKey(file: privateKeyPath, format: .pem)
        }

        self.tlsConfiguration.privateKey = NIOSSLPrivateKeySource.privateKey(key)
        self.tlsConfiguration.certificateVerification = .noHostnameVerification
        self.tlsConfiguration.certificateChain = try [.certificate(.init(file: pemPath, format: .pem))]
    }

    /**
        Call this constructor to create a new Configuration for APNSWift with a PEM Key. Warning it is blocking!

        - Parameters:
          - privateKeyPath: The path to your private key
          - pemPath: The path to pem file.
          - topic: The bundle identifier for these push notifications.
          - environment: The environment to use, sandbox, or production.
          - logger: The logger you wish to use, if nil, one will be created
          - passphraseCallback: The callback which will generate the password for the keyfile


        ### Usage Example: ###
        ```
        let pwdCallback: NIOSSLPassphraseCallback = { callback in
          callback("your password here".utf8)
        }

        var apnsConfig = try APNSwiftConfiguration(
            privateKeyPath: "/Users/kylebrowning/Projects/swift/Fern/development_com.grasscove.Fern.pkey",
            pemPath: "/Users/kylebrowning/Projects/swift/Fern/development_com.grasscove.Fern.pem",
            topic: "com.grasscove.Fern",
            environment: .sandbox,
            passphraseCallback: pwdCallback
        )
        ```
    */
    public init<T: Collection>(privateKeyPath: String, pemPath: String, topic: String, environment: APNSwiftConfiguration.Environment,
                               logger: Logger? = nil, passphraseCallback: @escaping NIOSSLPassphraseCallback<T>) throws
        where T.Element == UInt8 {
            try self.init(keyIdentifier: "", teamIdentifier: "", signer: APNSwiftSigner(buffer: ByteBufferAllocator().buffer(capacity: 1024)), topic: topic, environment: environment, logger: logger)
            let key = try NIOSSLPrivateKey(file: privateKeyPath, format: .pem, passphraseCallback: passphraseCallback)
            self.tlsConfiguration.privateKey = NIOSSLPrivateKeySource.privateKey(key)
            self.tlsConfiguration.certificateVerification = .noHostnameVerification
            self.tlsConfiguration.certificateChain = try [.certificate(.init(file: pemPath, format: .pem))]
    }
}

extension APNSwiftConfiguration {
    public enum Environment {
        case production
        case sandbox
    }
}

extension APNSwiftConnection {
    public enum PushType: String {
        case alert
        case background
    }
}
