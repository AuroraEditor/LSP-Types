//
//  AnyCodable.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/02.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

@propertyWrapper
struct AnyCodable: Codable {
    var value: Any?

    init(wrappedValue: Any?) {
        self.value = wrappedValue
    }

    var wrappedValue: Any? {
        get { value }
        set { value = newValue }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let dictValue = try? container.decode([String: AnyCodable].self) {
            value = dictValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode value")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let value = value as? Encodable {
            try container.encode(value)
        }
    }
}
