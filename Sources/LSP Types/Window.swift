//
//  Window.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

public struct MessageType: RawRepresentable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// An error message.
    static let error = MessageType(rawValue: 1)
    /// A warning message.
    static let warning = MessageType(rawValue: 2)
    /// An information message.
    static let info = MessageType(rawValue: 3)
    /// A log message.
    static let log = MessageType(rawValue: 4)
}

/// Window specific client capabilities.
public struct WindowClientCapabilities: Codable {
    /// Whether client supports handling progress notifications. If set
    /// servers are allowed to report in `workDoneProgress` property in the
    /// request specific server capabilities.
    ///
    /// @since 3.15.0
    let workDoneProgress: Bool?

    /// Capabilities specific to the showMessage request.
    ///
    /// @since 3.16.0
    let showMessage: ShowMessageRequestClientCapabilities?

    /// Client capabilities for the show document request.
    ///
    /// @since 3.16.0
    let showDocument: ShowDocumentClientCapabilities?

    enum CodingKeys: String, CodingKey {
        case workDoneProgress
        case showMessage
        case showDocument
    }
}

/// Show message request client capabilities
public struct ShowMessageRequestClientCapabilities: Codable {
    /// Capabilities specific to the `MessageActionItem` type.
    let messageActionItem: MessageActionItemCapabilities?

    enum CodingKeys: String, CodingKey {
        case messageActionItem
    }
}

public struct MessageActionItemCapabilities: Codable {
    /// Whether the client supports additional attributes which
    /// are preserved and send back to the server in the
    /// request's response.
    let additionalPropertiesSupport: Bool?

    enum CodingKeys: String, CodingKey {
        case additionalPropertiesSupport
    }
}

public struct MessageActionItem: Codable {
    /// A short title like 'Retry', 'Open Log' etc.
    let title: String

    /// Additional attributes that the client preserves and
    /// sends back to the server. This depends on the client
    /// capability window.messageActionItem.additionalPropertiesSupport
    let properties: [String: MessageActionItemProperty]
}

enum MessageActionItemProperty: Codable {
    case string(String)
    case boolean(Bool)
    case integer(Int)
    case double(Double)
    case array([MessageActionItemProperty])
    case dictionary([String: MessageActionItemProperty])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .boolean(value)
        } else if let value = try? container.decode(Int.self) {
            self = .integer(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode([MessageActionItemProperty].self) {
            self = .array(value)
        } else if let value = try? container.decode([String: MessageActionItemProperty].self) {
            self = .dictionary(value)
        } else {
            throw DecodingError.typeMismatch(
                MessageActionItemProperty.self,
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unsupported type"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .string(let value):
            try container.encode(value)
        case .boolean(let value):
            try container.encode(value)
        case .integer(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .dictionary(let value):
            try container.encode(value)
        }
    }
}

public struct LogMessageParams: Codable {
    /// The message type. See {@link MessageType}
    let type: MessageType

    /// The actual message
    let message: String

    enum CodingKeys: String, CodingKey {
        case type
        case message
    }
}

public struct ShowMessageParams: Codable {
    /// The message type. See {@link MessageType}.
    let type: MessageType

    /// The actual message.
    let message: String

    enum CodingKeys: String, CodingKey {
        case type
        case message
    }
}

public struct ShowMessageRequestParams: Codable {
    /// The message type. See {@link MessageType}
    let type: MessageType

    /// The actual message
    let message: String

    /// The message action items to present.
    let actions: [MessageActionItem]?

    enum CodingKeys: String, CodingKey {
        case type
        case message
        case actions
    }
}

/// Client capabilities for the show document request.
public struct ShowDocumentClientCapabilities: Codable {
    /// The client has support for the show document request.
    let support: Bool
}

/// Params to show a document.
///
/// @since 3.16.0
public struct ShowDocumentParams: Codable {
    /// The document uri to show.
    let uri: URL

    /// Indicates to show the resource in an external program.
    /// To show for example `https://docs.auroraeditor.com/`
    /// in the default WEB browser set `external` to `true`.
    let external: Bool?

    /// An optional property to indicate whether the editor
    /// showing the document should take focus or not.
    /// Clients might ignore this property if an external
    /// program in started.
    let takeFocus: Bool?

    /// An optional selection range if the document is a text
    /// document. Clients might ignore the property if an
    /// external program is started or the file is not a text
    /// file.
    let selection: LSPRange?

    enum CodingKeys: String, CodingKey {
        case uri
        case external
        case takeFocus
        case selection
    }
}

/// The result of an show document request.
///
/// @since 3.16.0
public struct ShowDocumentResult: Codable {
    /// A boolean indicating if the show was successful.
    let success: Bool
}
