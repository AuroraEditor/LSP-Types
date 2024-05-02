//
//  SelectionRange.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

public struct SelectionRangeClientCapabilities: Codable {
    /// Whether implementation supports dynamic registration for selection range
    /// providers. If this is set to `true` the client supports the new
    /// `SelectionRangeRegistrationOptions` return value for the corresponding
    /// server capability as well.
    let dynamicRegistration: Bool?

    enum CodingKeys: String, CodingKey {
        case dynamicRegistration
    }
}

public struct SelectionRangeOptions: Codable {
    let workDoneProgressOptions: WorkDoneProgressOptions
}

public struct SelectionRangeRegistrationOptions: Codable {
    let selectionRangeOptions: SelectionRangeOptions
    let registrationOptions: StaticTextDocumentRegistrationOptions
}

enum SelectionRangeProviderCapability: Codable {
    case simple(Bool)
    case options(SelectionRangeOptions)
    case registrationOptions(SelectionRangeRegistrationOptions)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) {
            self = .simple(value)
        } else if let value = try? container.decode(SelectionRangeOptions.self) {
            self = .options(value)
        } else if let value = try? container.decode(SelectionRangeRegistrationOptions.self) {
            self = .registrationOptions(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid SelectionRangeProviderCapability")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .simple(let value):
            try container.encode(value)
        case .options(let value):
            try container.encode(value)
        case .registrationOptions(let value):
            try container.encode(value)
        }
    }
}

extension SelectionRangeRegistrationOptions {
    func asSelectionsectionRangeProviderCapability() -> SelectionRangeProviderCapability {
        return .registrationOptions(self)
    }
}

extension SelectionRangeOptions {
    func asSelectionsectionRangeProviderCapability() -> SelectionRangeProviderCapability {
        return .options(self)
    }
}

extension Bool {
    func asSelectionsectionRangeProviderCapability() -> SelectionRangeProviderCapability {
        return .simple(self)
    }
}

/// A parameter literal used in selection range requests.
public struct SelectionRangeParams: Codable {
    /// The text document.
    let textDocument: TextDocumentIdentifier

    /// The positions inside the text document.
    let positions: [LSPPosition]

    let workDoneProgressParams: WorkDoneProgressParams

    let partialResultParams: PartialResultParams

    enum CodingKeys: String, CodingKey {
        case textDocument
        case positions
        case workDoneProgressParams
        case partialResultParams
    }
}

/// Represents a selection range.
class SelectionRange: Codable {
    /// Range of the selection.
    let range: LSPRange

    /// The parent selection range containing this range.
    let parent: SelectionRange?

    enum CodingKeys: String, CodingKey {
        case range
        case parent
    }

    init(range: LSPRange, parent: SelectionRange?) {
        self.range = range
        self.parent = parent
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        range = try container.decode(LSPRange.self, forKey: .range)
        parent = try container.decodeIfPresent(SelectionRange.self, forKey: .parent)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(range, forKey: .range)
        try container.encodeIfPresent(parent, forKey: .parent)
    }
}
