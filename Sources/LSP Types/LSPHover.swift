//
//  LSPHover.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

public struct HoverClientCapabilities: Codable {
    /// Whether completion supports dynamic registration.
    let dynamicRegistration: Bool?

    /// Client supports the follow content formats for the content
    /// property. The order describes the preferred format of the client.
    let contentFormat: [MarkupKind]?

    enum CodingKeys: String, CodingKey {
        case dynamicRegistration
        case contentFormat
    }
}

/// Hover options.
public struct HoverOptions: Codable {
    let workDoneProgressOptions: WorkDoneProgressOptions
}

public struct HoverRegistrationOptions: Codable {
    let textDocumentRegistrationOptions: TextDocumentRegistrationOptions
    let hoverOptions: HoverOptions
}

enum HoverProviderCapability: Codable {
    case simple(Bool)
    case options(HoverOptions)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) {
            self = .simple(value)
        } else if let value = try? container.decode(HoverOptions.self) {
            self = .options(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid HoverProviderCapability")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .simple(let value):
            try container.encode(value)
        case .options(let value):
            try container.encode(value)
        }
    }
}

extension HoverOptions {
    func asHoverProviderCapability() -> HoverProviderCapability {
        return .options(self)
    }
}

extension Bool {
    func asHoverProviderCapability() -> HoverProviderCapability {
        return .simple(self)
    }
}

public struct HoverParams: Codable {
    let textDocumentPositionParams: TextDocumentPositionParams
    let workDoneProgressParams: WorkDoneProgressParams
}

/// The result of a hover request.
public struct Hover: Codable {
    /// The hover's content
    let contents: HoverContents

    /// An optional range is a range inside a text document
    /// that is used to visualize a hover, e.g. by changing the background color.
    let range: LSPRange?

    enum CodingKeys: String, CodingKey {
        case contents
        case range
    }
}

/// Hover contents could be single entry or multiple entries.
enum HoverContents: Codable {
    case scalar(MarkedString)
    case array([MarkedString])
    case markup(MarkupContent)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(MarkedString.self) {
            self = .scalar(value)
        } else if let value = try? container.decode([MarkedString].self) {
            self = .array(value)
        } else if let value = try? container.decode(MarkupContent.self) {
            self = .markup(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid HoverContents")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .scalar(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .markup(let value):
            try container.encode(value)
        }
    }
}
