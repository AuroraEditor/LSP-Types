//
//  LinkedEditing.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

typealias LinkedEditingRangeClientCapabilities = DynamicRegistrationClientCapabilities

public struct LinkedEditingRangeOptions: Codable {
    let workDoneProgressOptions: WorkDoneProgressOptions
}

public struct LinkedEditingRangeRegistrationOptions: Codable {
    let textDocumentRegistrationOptions: TextDocumentRegistrationOptions
    let linkedEditingRangeOptions: LinkedEditingRangeOptions
    let staticRegistrationOptions: StaticRegistrationOptions
}

enum LinkedEditingRangeServerCapabilities: Codable {
    case simple(Bool)
    case options(LinkedEditingRangeOptions)
    case registrationOptions(LinkedEditingRangeRegistrationOptions)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) {
            self = .simple(value)
        } else if let value = try? container.decode(LinkedEditingRangeOptions.self) {
            self = .options(value)
        } else if let value = try? container.decode(LinkedEditingRangeRegistrationOptions.self) {
            self = .registrationOptions(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Invalid LinkedEditingRangeServerCapabilities")
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

public struct LinkedEditingRangeParams: Codable {
    let textDocumentPositionParams: TextDocumentPositionParams
    let workDoneProgressParams: WorkDoneProgressParams
}

public struct LinkedEditingRanges: Codable {
    /// A list of ranges that can be renamed together. The ranges must have
    /// identical length and contain identical text content. The ranges cannot overlap.
    let ranges: [LSPRange]
    
    /// An optional word pattern (regular expression) that describes valid contents for
    /// the given ranges. If no pattern is provided, the client configuration's word
    /// pattern will be used.
    let wordPattern: String?
    
    enum CodingKeys: String, CodingKey {
        case ranges
        case wordPattern
    }
}
