//
//  LSPFoldingRange.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

public struct FoldingRangeParams: Codable {
    /// The text document.
    let textDocument: TextDocumentIdentifier

    let workDoneProgressParams: WorkDoneProgressParams

    let partialResultParams: PartialResultParams
}

enum FoldingRangeProviderCapability: Codable {
    case simple(Bool)
    case foldingProvider(FoldingProviderOptions)
    case options(StaticTextDocumentColorProviderOptions)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) {
            self = .simple(value)
        } else if let value = try? container.decode(FoldingProviderOptions.self) {
            self = .foldingProvider(value)
        } else if let value = try? container.decode(StaticTextDocumentColorProviderOptions.self) {
            self = .options(value)
        } else {
            throw DecodingError.typeMismatch(FoldingRangeProviderCapability.self,
                                             DecodingError.Context(codingPath: decoder.codingPath,
                                                                   debugDescription: "Invalid FoldingRangeProviderCapability"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .simple(let value):
            try container.encode(value)
        case .foldingProvider(let value):
            try container.encode(value)
        case .options(let value):
            try container.encode(value)
        }
    }
}

extension StaticTextDocumentColorProviderOptions {
    func asFoldingRangeProviderCapability() -> FoldingRangeProviderCapability {
        return .options(self)
    }
}

extension FoldingProviderOptions {
    func asFoldingRangeProviderCapability() -> FoldingRangeProviderCapability {
        return .foldingProvider(self)
    }
}

extension Bool {
    func asFoldingRangeProviderCapability() -> FoldingRangeProviderCapability {
        return .simple(self)
    }
}

public struct FoldingProviderOptions: Codable {}

public struct FoldingRangeKindCapability: Codable {
    /// The folding range kind values the client supports. When this
    /// property exists the client also guarantees that it will
    /// handle values outside its set gracefully and falls back
    /// to a default value when unknown.
    let valueSet: [FoldingRangeKind]?

    enum CodingKeys: String, CodingKey {
        case valueSet
    }
}

public struct FoldingRangeCapability: Codable {
    /// If set, the client signals that it supports setting collapsedText on
    /// folding ranges to display custom labels instead of the default text.
    ///
    /// @since 3.17.0
    let collapsedText: Bool?

    enum CodingKeys: String, CodingKey {
        case collapsedText
    }
}

public struct FoldingRangeClientCapabilities: Codable {
    /// Whether implementation supports dynamic registration for folding range providers. If this is set to `true`
    /// the client supports the new `(FoldingRangeProviderOptions & TextDocumentRegistrationOptions & StaticRegistrationOptions)`
    /// return value for the corresponding server capability as well.
    let dynamicRegistration: Bool?

    /// The maximum number of folding ranges that the client prefers to receive per document. The value serves as a
    /// hint, servers are free to follow the limit.
    let rangeLimit: UInt32?

    /// If set, the client signals that it only supports folding complete lines. If set, client will
    /// ignore specified `startCharacter` and `endCharacter` properties in a FoldingRange.
    let lineFoldingOnly: Bool?

    /// Specific options for the folding range kind.
    ///
    /// @since 3.17.0
    let foldingRangeKind: FoldingRangeKindCapability?

    /// Specific options for the folding range.
    ///
    /// @since 3.17.0
    let foldingRange: FoldingRangeCapability?

    enum CodingKeys: String, CodingKey {
        case dynamicRegistration
        case rangeLimit
        case lineFoldingOnly
        case foldingRangeKind
        case foldingRange
    }
}

/// Enum of known range kinds
enum FoldingRangeKind: String, Codable {
    /// Folding range for a comment
    case comment

    /// Folding range for a imports or includes
    case imports

    /// Folding range for a region (e.g. `#region`)
    case region
}

/// Represents a folding range.
public struct FoldingRange: Codable {
    /// The zero-based line number from where the folded range starts.
    let startLine: UInt32

    /// The zero-based character offset from where the folded range starts. If not defined, defaults to the length of the start line.
    let startCharacter: UInt32?

    /// The zero-based line number where the folded range ends.
    let endLine: UInt32

    /// The zero-based character offset before the folded range ends. If not defined, defaults to the length of the end line.
    let endCharacter: UInt32?

    /// Describes the kind of the folding range such as `comment' or 'region'. The kind
    /// is used to categorize folding ranges and used by commands like 'Fold all comments'. See
    /// [FoldingRangeKind](#FoldingRangeKind) for an enumeration of standardized kinds.
    let kind: FoldingRangeKind?

    /// The text that the client should show when the specified range is
    /// collapsed. If not defined or not supported by the client, a default
    /// will be chosen by the client.
    ///
    /// @since 3.17.0
    let collapsedText: String?

    enum CodingKeys: String, CodingKey {
        case startLine
        case startCharacter
        case endLine
        case endCharacter
        case kind
        case collapsedText
    }
}
