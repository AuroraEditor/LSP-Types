//
//  LSPFormatting.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

typealias DocumentFormattingClientCapabilities = DynamicRegistrationClientCapabilities
typealias DocumentRangeFormattingClientCapabilities = DynamicRegistrationClientCapabilities
typealias DocumentOnTypeFormattingClientCapabilities = DynamicRegistrationClientCapabilities

/// Format document on type options
public struct DocumentOnTypeFormattingOptions: Codable {
    /// A character on which formatting should be triggered, like `}`.
    let firstTriggerCharacter: String

    /// More trigger characters.
    let moreTriggerCharacter: [String]?

    enum CodingKeys: String, CodingKey {
        case firstTriggerCharacter
        case moreTriggerCharacter
    }
}

public struct DocumentFormattingParams: Codable {
    /// The document to format.
    let textDocument: TextDocumentIdentifier

    /// The format options.
    let options: FormattingOptions

    let workDoneProgressParams: WorkDoneProgressParams
}

/// Value-object describing what options formatting should use.
public struct FormattingOptions: Codable {
    /// Size of a tab in spaces.
    let tabSize: UInt32

    /// Prefer spaces over tabs.
    let insertSpaces: Bool

    /// Signature for further properties.
    let properties: [String: FormattingProperty]

    /// Trim trailing whitespace on a line.
    let trimTrailingWhitespace: Bool?

    /// Insert a newline character at the end of the file if one does not exist.
    let insertFinalNewline: Bool?

    /// Trim all newlines after the final newline at the end of the file.
    let trimFinalNewlines: Bool?

    enum CodingKeys: String, CodingKey {
        case tabSize
        case insertSpaces
        case properties
        case trimTrailingWhitespace
        case insertFinalNewline
        case trimFinalNewlines
    }
}

enum FormattingProperty: Codable {
    case bool(Bool)
    case number(Int32)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int32.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            throw DecodingError.typeMismatch(FormattingProperty.self,
                                             DecodingError.Context(codingPath: decoder.codingPath,
                                                                   debugDescription: "Invalid FormattingProperty"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        }
    }
}

public struct DocumentRangeFormattingParams: Codable {
    /// The document to format.
    let textDocument: TextDocumentIdentifier

    /// The range to format
    let range: LSPRange

    /// The format options
    let options: FormattingOptions

    let workDoneProgressParams: WorkDoneProgressParams
}

public struct DocumentOnTypeFormattingParams: Codable {
    /// Text Document and Position fields.
    let textDocumentPosition: TextDocumentPositionParams

    /// The character that has been typed.
    let ch: String

    /// The format options.
    let options: FormattingOptions
}

/// Extends TextDocumentRegistrationOptions
public struct DocumentOnTypeFormattingRegistrationOptions: Codable {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    let documentSelector: DocumentSelector?

    /// A character on which formatting should be triggered, like `}`.
    let firstTriggerCharacter: String

    /// More trigger characters.
    let moreTriggerCharacter: [String]?

    enum CodingKeys: String, CodingKey {
        case documentSelector
        case firstTriggerCharacter
        case moreTriggerCharacter
    }
}
