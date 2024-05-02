//
//  TypeHierarchy.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

typealias TypeHierarchyClientCapabilities = DynamicRegistrationClientCapabilities

public struct TypeHierarchyOptions: Codable {
    let workDoneProgressOptions: WorkDoneProgressOptions
}

public struct TypeHierarchyRegistrationOptions: Codable {
    let textDocumentRegistrationOptions: TextDocumentRegistrationOptions
    let typeHierarchyOptions: TypeHierarchyOptions
    let staticRegistrationOptions: StaticRegistrationOptions
}

public struct TypeHierarchyPrepareParams: Codable {
    let textDocumentPositionParams: TextDocumentPositionParams
    let workDoneProgressParams: WorkDoneProgressParams
}

public struct TypeHierarchySupertypesParams: Codable {
    let item: TypeHierarchyItem
    let workDoneProgressParams: WorkDoneProgressParams
    let partialResultParams: PartialResultParams
}

public struct TypeHierarchySubtypesParams: Codable {
    let item: TypeHierarchyItem
    let workDoneProgressParams: WorkDoneProgressParams
    let partialResultParams: PartialResultParams
}

public struct TypeHierarchyItem: Codable {
    /// The name of this item.
    let name: String

    /// The kind of this item.
    let kind: SymbolKind

    /// Tags for this item.
    let tags: SymbolTag?

    /// More detail for this item, e.g. the signature of a function.
    let detail: String?

    /// The resource identifier of this item.
    let uri: URL

    /// The range enclosing this symbol not including leading/trailing whitespace
    /// but everything else, e.g. comments and code.
    let range: LSPRange

    /// The range that should be selected and revealed when this symbol is being
    /// picked, e.g. the name of a function. Must be contained by the
    /// [`range`](#TypeHierarchyItem.range).
    let selectionRange: LSPRange

    /// A data entry field that is preserved between a type hierarchy prepare and
    /// supertypes or subtypes requests. It could also be used to identify the
    /// type hierarchy in the server, helping improve the performance on
    /// resolving supertypes and subtypes.
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
