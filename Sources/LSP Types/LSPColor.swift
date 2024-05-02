//
//  LSPColor.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/04/28.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

public typealias DocumentColorClientCapabilities = DynamicRegistrationClientCapabilities

public struct ColorProviderOptions: Codable {}

public struct StaticTextDocumentColorProviderOptions: Codable {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    let documentSelector: DocumentSelector?

    let id: String?

    enum CodingKeys: String, CodingKey {
        case documentSelector
        case id
    }
}

enum ColorProviderCapability: Codable {
    case simple(Bool)
    case colorProvider(ColorProviderOptions)
    case options(StaticTextDocumentColorProviderOptions)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) {
            self = .simple(value)
        } else if let value = try? container.decode(ColorProviderOptions.self) {
            self = .colorProvider(value)
        } else if let value = try? container.decode(StaticTextDocumentColorProviderOptions.self) {
            self = .options(value)
        } else {
            throw DecodingError.typeMismatch(ColorProviderCapability.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ColorProviderCapability"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .simple(let value):
            try container.encode(value)
        case .colorProvider(let value):
            try container.encode(value)
        case .options(let value):
            try container.encode(value)
        }
    }
}

public struct DocumentColorParams: Codable {
    /// The text document
    let textDocument: TextDocumentIdentifier

    let workDoneProgressParams: WorkDoneProgressParams

    let partialResultParams: PartialResultParams

    enum CodingKeys: String, CodingKey {
        case textDocument
        case workDoneProgressParams
        case partialResultParams
    }
}

public struct ColorInformation: Codable {
    /// The range in the document where this color appears.
    let range: LSPRange
    /// The actual color value for this color range.
    let color: LSPColor
}

public struct LSPColor: Codable {
    /// The red component of this color in the range [0-1].
    let red: Float
    /// The green component of this color in the range [0-1].
    let green: Float
    /// The blue component of this color in the range [0-1].
    let blue: Float
    /// The alpha component of this color in the range [0-1].
    let alpha: Float
}

public struct ColorPresentationParams: Codable {
    /// The text document.
    let textDocument: TextDocumentIdentifier

    /// The color information to request presentations for.
    let color: LSPColor

    /// The range where the color would be inserted. Serves as a context.
    let range: LSPRange

    let workDoneProgressParams: WorkDoneProgressParams

    let partialResultParams: PartialResultParams

    enum CodingKeys: String, CodingKey {
        case textDocument
        case color
        case range
        case workDoneProgressParams
        case partialResultParams
    }
}

public struct ColorPresentation: Codable {
    /// The label of this color presentation. It will be shown on the color
    /// picker header. By default this is also the text that is inserted when selecting
    /// this color presentation.
    let label: String

    /// An [edit](#TextEdit) which is applied to a document when selecting
    /// this presentation for the color.  When `falsy` the [label](#ColorPresentation.label)
    /// is used.
    let textEdit: TextEdit?

    /// An optional array of additional [text edits](#TextEdit) that are applied when
    /// selecting this color presentation. Edits must not overlap with the main [edit](#ColorPresentation.textEdit) nor with themselves.
    let additionalTextEdits: [TextEdit]?

    enum CodingKeys: String, CodingKey {
        case label
        case textEdit
        case additionalTextEdits
    }
}
