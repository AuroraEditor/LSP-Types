//
//  LSPRename.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

public struct RenameParams: Codable {
    /// Text Document and Position fields
    let textDocumentPosition: TextDocumentPositionParams

    /// The new name of the symbol. If the given name is not valid the
    /// request must return a [ResponseError](#ResponseError) with an
    /// appropriate message set.
    let newName: String

    let workDoneProgressParams: WorkDoneProgressParams

    enum CodingKeys: String, CodingKey {
        case newName
        case workDoneProgressParams
        case textDocumentPosition
    }
}

public struct RenameOptions: Codable {
    /// Renames should be checked and tested before being executed.
    let prepareProvider: Bool?

    let workDoneProgressOptions: WorkDoneProgressOptions

    enum CodingKeys: String, CodingKey {
        case prepareProvider
        case workDoneProgressOptions
    }
}

public struct RenameClientCapabilities: Codable {
    /// Whether rename supports dynamic registration.
    let dynamicRegistration: Bool?

    /// Client supports testing for validity of rename operations before execution.
    ///
    /// @since 3.12.0
    let prepareSupport: Bool?

    /// Client supports the default behavior result.
    ///
    /// The value indicates the default behavior used by the
    /// client.
    ///
    /// @since 3.16.0
    let prepareSupportDefaultBehavior: PrepareSupportDefaultBehavior?

    /// Whether the client honors the change annotations in
    /// text edits and resource operations returned via the
    /// rename request's workspace edit by for example presenting
    /// the workspace edit in the user interface and asking
    /// for confirmation.
    ///
    /// @since 3.16.0
    let honorsChangeAnnotations: Bool?

    enum CodingKeys: String, CodingKey {
        case dynamicRegistration
        case prepareSupport
        case prepareSupportDefaultBehavior
        case honorsChangeAnnotations
    }
}

public struct PrepareSupportDefaultBehavior: RawRepresentable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// The client's default behavior is to select the identifier
    /// according to the language's syntax rule
    static let identifier = PrepareSupportDefaultBehavior(rawValue: 1)
}

enum PrepareRenameResponse: Codable {
    case range(LSPRange)
    case rangeWithPlaceholder(RangeWithPlaceholder)
    case defaultBehavior(DefaultBehavior)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let range = try? container.decode(LSPRange.self) {
            self = .range(range)
        } else if let rangeWithPlaceholder = try? container.decode(RangeWithPlaceholder.self) {
            self = .rangeWithPlaceholder(rangeWithPlaceholder)
        } else if let defaultBehavior = try? container.decode(DefaultBehavior.self) {
            self = .defaultBehavior(defaultBehavior)
        } else {
            throw DecodingError.typeMismatch(PrepareRenameResponse.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown PrepareRenameResponse type"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .range(let range):
            try container.encode(range)
        case .rangeWithPlaceholder(let rangeWithPlaceholder):
            try container.encode(rangeWithPlaceholder)
        case .defaultBehavior(let defaultBehavior):
            try container.encode(defaultBehavior)
        }
    }

    public struct RangeWithPlaceholder: Codable {
        let range: LSPRange
        let placeholder: String
    }

    public struct DefaultBehavior: Codable {
        let defaultBehavior: Bool
    }
}
