//
//  LSPCallHierarchy.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

typealias CallHierarchyClientCapabilities = DynamicRegistrationClientCapabilities

public struct CallHierarchyOptions: Codable {
    let workDoneProgressOptions: WorkDoneProgressOptions
}

public enum CallHierarchyServerCapability: Codable {
    case simple(Bool)
    case options(CallHierarchyOptions)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) {
            self = .simple(value)
        } else {
            self = .options(try container.decode(CallHierarchyOptions.self))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .simple(let value):
            try container.encode(value)
        case .options(let value):
            try container.encode(value)
        }
    }
}

extension CallHierarchyOptions {
    func asCallHierarchyServerCapability() -> CallHierarchyServerCapability {
        return .options(self)
    }
}

extension Bool {
    func asCallHierarchyServerCapability() -> CallHierarchyServerCapability {
        return .simple(self)
    }
}

public struct CallHierarchyPrepareParams: Codable {
    let textDocumentPositionParams: TextDocumentPositionParams
    let workDoneProgressParams: WorkDoneProgressParams
}

public struct CallHierarchyItem: Codable {
    /// The name of this item.
    let name: String

    /// The kind of this item.
    let kind: SymbolKind

    /// Tags for this item.
    let tags: [SymbolTag]?

    /// More detail for this item, e.g. the signature of a function.
    let detail: String?

    /// The resource identifier of this item.
    let uri: URL

    /// The range enclosing this symbol not including leading/trailing whitespace but everything else, e.g. comments and code.
    let range: LSPRange

    /// The range that should be selected and revealed when this symbol is being picked, e.g. the name of a function.
    /// Must be contained by the [`range`](#CallHierarchyItem.range).
    let selectionRange: LSPRange

    /// A data entry field that is preserved between a call hierarchy prepare and incoming calls or outgoing calls requests.
    let data: LSPAny?

    enum CodingKeys: String, CodingKey {
        case name
        case kind
        case tags
        case detail
        case uri
        case range
        case selectionRange
        case data
    }
}

public struct CallHierarchyIncomingCallsParams: Codable {
    let item: CallHierarchyItem
    let workDoneProgressParams: WorkDoneProgressParams
    let partialResultParams: PartialResultParams
}

/// Represents an incoming call, e.g. a caller of a method or constructor.
public struct CallHierarchyIncomingCall: Codable {
    /// The item that makes the call.
    let from: CallHierarchyItem

    /// The range at which at which the calls appears. This is relative to the caller
    /// denoted by [`this.from`](#CallHierarchyIncomingCall.from).
    let fromRanges: [LSPRange]

    enum CodingKeys: String, CodingKey {
        case from
        case fromRanges
    }
}

struct CallHierarchyOutgoingCallsParams: Codable {
    let item: CallHierarchyItem
    let workDoneProgressParams: WorkDoneProgressParams
    let partialResultParams: PartialResultParams
}

/// Represents an outgoing call, e.g. calling a getter from a method or a method from a constructor etc.
public struct CallHierarchyOutgoingCall: Codable {
    /// The item that is called.
    let to: CallHierarchyItem

    /// The range at which this item is called. This is the range relative to the caller, e.g the item
    /// passed to [`provideCallHierarchyOutgoingCalls`](#CallHierarchyItemProvider.provideCallHierarchyOutgoingCalls)
    /// and not [`this.to`](#CallHierarchyOutgoingCall.to).
    let fromRanges: [LSPRange]

    enum CodingKeys: String, CodingKey {
        case to
        case fromRanges
    }
}
