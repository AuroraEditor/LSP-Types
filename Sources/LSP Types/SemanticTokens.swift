//
//  SemanticTokens.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

/// A set of predefined token types. This set is not fixed
/// and clients can specify additional token types via the
/// corresponding client capabilities.
///
/// @since 3.16.0
public struct SemanticTokenType: RawRepresentable, Codable, Hashable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    static let namespace = SemanticTokenType(rawValue: "namespace")
    static let type = SemanticTokenType(rawValue: "type")
    static let `class` = SemanticTokenType(rawValue: "class")
    static let `enum` = SemanticTokenType(rawValue: "enum")
    static let `interface` = SemanticTokenType(rawValue: "interface")
    static let `struct` = SemanticTokenType(rawValue: "public struct")
    static let typeParameter = SemanticTokenType(rawValue: "typeParameter")
    static let parameter = SemanticTokenType(rawValue: "parameter")
    static let variable = SemanticTokenType(rawValue: "variable")
    static let property = SemanticTokenType(rawValue: "property")
    static let enumMember = SemanticTokenType(rawValue: "enumMember")
    static let event = SemanticTokenType(rawValue: "event")
    static let function = SemanticTokenType(rawValue: "function")
    static let method = SemanticTokenType(rawValue: "method")
    static let macro = SemanticTokenType(rawValue: "macro")
    static let keyword = SemanticTokenType(rawValue: "keyword")
    static let modifier = SemanticTokenType(rawValue: "modifier")
    static let comment = SemanticTokenType(rawValue: "comment")
    static let string = SemanticTokenType(rawValue: "string")
    static let number = SemanticTokenType(rawValue: "number")
    static let regexp = SemanticTokenType(rawValue: "regexp")
    static let `operator` = SemanticTokenType(rawValue: "operator")

    /// @since 3.17.0
    static let decorator = SemanticTokenType(rawValue: "decorator")
}

/// A set of predefined token modifiers. This set is not fixed
/// and clients can specify additional token types via the
/// corresponding client capabilities.
///
/// @since 3.16.0
public struct SemanticTokenModifier: RawRepresentable, Codable, Hashable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    static let declaration = SemanticTokenModifier(rawValue: "declaration")
    static let definition = SemanticTokenModifier(rawValue: "definition")
    static let readonly = SemanticTokenModifier(rawValue: "readonly")
    static let `static` = SemanticTokenModifier(rawValue: "static")
    static let deprecated = SemanticTokenModifier(rawValue: "deprecated")
    static let `abstract` = SemanticTokenModifier(rawValue: "abstract")
    static let async = SemanticTokenModifier(rawValue: "async")
    static let modification = SemanticTokenModifier(rawValue: "modification")
    static let documentation = SemanticTokenModifier(rawValue: "documentation")
    static let defaultLibrary = SemanticTokenModifier(rawValue: "defaultLibrary")
}

public struct TokenFormat: RawRepresentable, Codable, Hashable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    static let relative = TokenFormat(rawValue: "relative")
}

/// @since 3.16.0
public struct SemanticTokensLegend: Codable {
    /// The token types a server uses.
    let tokenTypes: [SemanticTokenType]

    /// The token modifiers a server uses.
    let tokenModifiers: [SemanticTokenModifier]
}

/// The actual tokens.
public struct SemanticToken {
    let deltaLine: UInt32
    let deltaStart: UInt32
    let length: UInt32
    let tokenType: UInt32
    let tokenModifiersBitset: UInt32
}

/// @since 3.16.0
public struct SemanticTokens: Codable {
    /// An optional result id. If provided and clients support delta updating
    /// the client will include the result id in the next semantic token request.
    /// A server can then instead of computing all semantic tokens again simply
    /// send a delta.
    let resultId: String?

    /// The actual tokens. For a detailed description about how the data is
    /// public structured please see
    /// <https://github.com/microsoft/vscode-extension-samples/blob/5ae1f7787122812dcc84e37427ca90af5ee09f14/semantic-tokens-sample/vscode.proposed.d.ts#L71>
    let data: [UInt32]

    enum CodingKeys: String, CodingKey {
        case resultId
        case data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        resultId = try container.decodeIfPresent(String.self, forKey: .resultId)
        data = try SemanticToken.deserializeTokens(container: container, forKey: .data)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(resultId, forKey: .resultId)
        try SemanticToken.serializeTokens(data, container: &container, forKey: .data)
    }
}

/// @since 3.16.0
public struct SemanticTokensPartialResult: Codable {
    let data: [UInt32]

    enum CodingKeys: String, CodingKey {
        case data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try SemanticToken.deserializeTokens(container: container, forKey: .data)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try SemanticToken.serializeTokens(data, container: &container, forKey: .data)
    }
}

enum SemanticTokensResult: Codable {
    case tokens(SemanticTokens)
    case partial(SemanticTokensPartialResult)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let tokens = try? container.decode(SemanticTokens.self) {
            self = .tokens(tokens)
        } else if let partial = try? container.decode(SemanticTokensPartialResult.self) {
            self = .partial(partial)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid SemanticTokensResult")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .tokens(let tokens):
            try container.encode(tokens)
        case .partial(let partial):
            try container.encode(partial)
        }
    }
}

/// @since 3.16.0
public struct SemanticTokensEdit: Codable {
    let start: UInt32
    let deleteCount: UInt32
    let data: [UInt32]?

    enum CodingKeys: String, CodingKey {
        case start
        case deleteCount
        case data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        start = try container.decode(UInt32.self, forKey: .start)
        deleteCount = try container.decode(UInt32.self, forKey: .deleteCount)
        data = try SemanticToken.deserializeTokensOptional(container: container, forKey: .data)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(start, forKey: .start)
        try container.encode(deleteCount, forKey: .deleteCount)
        try SemanticToken.serializeTokensOptional(data, container: &container, forKey: .data)
    }
}

enum SemanticTokensFullDeltaResult: Codable {
    case tokens(SemanticTokens)
    case tokensDelta(SemanticTokensDelta)
    case partialTokensDelta(PartialTokensDelta)

    public struct PartialTokensDelta: Codable {
        let edits: [SemanticTokensEdit]
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let tokens = try? container.decode(SemanticTokens.self) {
            self = .tokens(tokens)
        } else if let tokensDelta = try? container.decode(SemanticTokensDelta.self) {
            self = .tokensDelta(tokensDelta)
        } else if let partialTokensDelta = try? container.decode(PartialTokensDelta.self) {
            self = .partialTokensDelta(partialTokensDelta)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid SemanticTokensFullDeltaResult")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .tokens(let tokens):
            try container.encode(tokens)
        case .tokensDelta(let tokensDelta):
            try container.encode(tokensDelta)
        case .partialTokensDelta(let partialTokensDelta):
            try container.encode(partialTokensDelta)
        }
    }
}

/// @since 3.16.0
public struct SemanticTokensDelta: Codable {
    let resultId: String?
    /// For a detailed description how these edits are public structured please see
    /// <https://github.com/microsoft/vscode-extension-samples/blob/5ae1f7787122812dcc84e37427ca90af5ee09f14/semantic-tokens-sample/vscode.proposed.d.ts#L131>
    let edits: [SemanticTokensEdit]

    enum CodingKeys: String, CodingKey {
        case resultId
        case edits
    }
}

/// Capabilities specific to the `textDocument/semanticTokens/*` requests.
///
/// @since 3.16.0
public struct SemanticTokensClientCapabilities: Codable {
    /// Whether implementation supports dynamic registration. If this is set to `true`
    /// the client supports the new `(TextDocumentRegistrationOptions & StaticRegistrationOptions)`
    /// return value for the corresponding server capability as well.
    let dynamicRegistration: Bool?

    /// Which requests the client supports and might send to the server
    /// depending on the server's capability. Please note that clients might not
    /// show semantic tokens or degrade some of the user experience if a range
    /// or full request is advertised by the client but not provided by the
    /// server. If for example the client capability `requests.full` and
    /// `request.range` are both set to true but the server only provides a
    /// range provider the client might not render a minimap correctly or might
    /// even decide to not show any semantic tokens at all.
    let requests: SemanticTokensClientCapabilitiesRequests

    /// The token types that the client supports.
    let tokenTypes: [SemanticTokenType]

    /// The token modifiers that the client supports.
    let tokenModifiers: [SemanticTokenModifier]

    /// The token formats the clients supports.
    let formats: [TokenFormat]

    /// Whether the client supports tokens that can overlap each other.
    let overlappingTokenSupport: Bool?

    /// Whether the client supports tokens that can span multiple lines.
    let multilineTokenSupport: Bool?

    /// Whether the client allows the server to actively cancel a
    /// semantic token request, e.g. supports returning
    /// ErrorCodes.ServerCancelled. If a server does the client
    /// needs to retrigger the request.
    ///
    /// @since 3.17.0
    let serverCancelSupport: Bool?

    /// Whether the client uses semantic tokens to augment existing
    /// syntax tokens. If set to `true` client side created syntax
    /// tokens and semantic tokens are both used for colorization. If
    /// set to `false` the client only uses the returned semantic tokens
    /// for colorization.
    ///
    /// If the value is `undefined` then the client behavior is not
    /// specified.
    ///
    /// @since 3.17.0
    let augmentsSyntaxTokens: Bool?

    enum CodingKeys: String, CodingKey {
        case dynamicRegistration
        case requests
        case tokenTypes
        case tokenModifiers
        case formats
        case overlappingTokenSupport
        case multilineTokenSupport
        case serverCancelSupport
        case augmentsSyntaxTokens
    }
}

public struct SemanticTokensClientCapabilitiesRequests: Codable {
    /// The client will send the `textDocument/semanticTokens/range` request if the server provides a corresponding handler.
    let range: Bool?

    /// The client will send the `textDocument/semanticTokens/full` request if the server provides a corresponding handler.
    let full: SemanticTokensFullOptions?

    enum CodingKeys: String, CodingKey {
        case range
        case full
    }
}

enum SemanticTokensFullOptions: Codable {
    case bool(Bool)
    case delta(Delta)

    public struct Delta: Codable {
        /// The client will send the `textDocument/semanticTokens/full/delta` request if the server provides a corresponding handler.
        /// The server supports deltas for full documents.
        let delta: Bool?

        enum CodingKeys: String, CodingKey {
            case delta
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let delta = try? container.decode(Delta.self) {
            self = .delta(delta)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid SemanticTokensFullOptions")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let bool):
            try container.encode(bool)
        case .delta(let delta):
            try container.encode(delta)
        }
    }
}

/// @since 3.16.0
public struct SemanticTokensOptions: Codable {
    let workDoneProgressOptions: WorkDoneProgressOptions

    /// The legend used by the server
    let legend: SemanticTokensLegend

    /// Server supports providing semantic tokens for a specific range
    /// of a document.
    let range: Bool?

    /// Server supports providing semantic tokens for a full document.
    let full: SemanticTokensFullOptions?
}

public struct SemanticTokensRegistrationOptions: Codable {
    let textDocumentRegistrationOptions: TextDocumentRegistrationOptions
    let semanticTokensOptions: SemanticTokensOptions
    let staticRegistrationOptions: StaticRegistrationOptions
}

enum SemanticTokensServerCapabilities: Codable {
    case semanticTokensOptions(SemanticTokensOptions)
    case semanticTokensRegistrationOptions(SemanticTokensRegistrationOptions)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let semanticTokensOptions = try? container.decode(SemanticTokensOptions.self) {
            self = .semanticTokensOptions(semanticTokensOptions)
        } else if let semanticTokensRegistrationOptions = try? container.decode(SemanticTokensRegistrationOptions.self) {
            self = .semanticTokensRegistrationOptions(semanticTokensRegistrationOptions)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid SemanticTokensServerCapabilities")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .semanticTokensOptions(let semanticTokensOptions):
            try container.encode(semanticTokensOptions)
        case .semanticTokensRegistrationOptions(let semanticTokensRegistrationOptions):
            try container.encode(semanticTokensRegistrationOptions)
        }
    }
}
public struct SemanticTokensWorkspaceClientCapabilities: Codable {
    /// Whether the client implementation supports a refresh request sent from
    /// the server to the client.
    ///
    /// Note that this event is global and will force the client to refresh all
    /// semantic tokens currently shown. It should be used with absolute care
    /// and is useful for situation where a server for example detect a project
    /// wide change that requires such a calculation.
    let refreshSupport: Bool?
}
public struct SemanticTokensParams: Codable {
    let workDoneProgressParams: WorkDoneProgressParams
    let partialResultParams: PartialResultParams
    /// The text document.
    let textDocument: TextDocumentIdentifier
}
public struct SemanticTokensDeltaParams: Codable {
    let workDoneProgressParams: WorkDoneProgressParams
    let partialResultParams: PartialResultParams
    /// The text document.
    let textDocument: TextDocumentIdentifier
    /// The result id of a previous response. The result Id can either point to a full response
    /// or a delta response depending on what was received last.
    let previousResultId: String
}
public struct SemanticTokensRangeParams: Codable {
    let workDoneProgressParams: WorkDoneProgressParams
    let partialResultParams: PartialResultParams
    /// The text document.
    let textDocument: TextDocumentIdentifier
    /// The range the semantic tokens are requested for.
    let range: LSPRange
}
enum SemanticTokensRangeResult: Codable {
    case tokens(SemanticTokens)
    case partial(SemanticTokensPartialResult)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let tokens = try? container.decode(SemanticTokens.self) {
            self = .tokens(tokens)
        } else if let partial = try? container.decode(SemanticTokensPartialResult.self) {
            self = .partial(partial)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid SemanticTokensRangeResult")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .tokens(let tokens):
            try container.encode(tokens)
        case .partial(let partial):
            try container.encode(partial)
        }
    }
}
extension SemanticToken {
    static func deserializeTokens<Keys: CodingKey>(container: KeyedDecodingContainer<Keys>, forKey key: Keys) throws -> [UInt32] {
        let data = try container.decode([UInt32].self, forKey: key)
        guard data.count % 5 == 0 else {
            throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Invalid semantic token data")
        }
        return data
    }

    static func serializeTokens<Keys: CodingKey>(_ tokens: [UInt32], container: inout KeyedEncodingContainer<Keys>, forKey key: Keys) throws {
        try container.encode(tokens, forKey: key)
    }

    static func deserializeTokensOptional<Keys: CodingKey>(container: KeyedDecodingContainer<Keys>, forKey key: Keys) throws -> [UInt32]? {
        guard let data = try container.decodeIfPresent([UInt32].self, forKey: key) else {
            return nil
        }
        guard data.count % 5 == 0 else {
            throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Invalid semantic token data")
        }
        return data
    }

    static func serializeTokensOptional<Keys: CodingKey>(_ tokens: [UInt32]?, container: inout KeyedEncodingContainer<Keys>, forKey key: Keys) throws {
        try container.encodeIfPresent(tokens, forKey: key)
    }
}
