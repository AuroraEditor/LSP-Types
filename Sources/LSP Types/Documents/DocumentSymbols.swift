//
//  DocumentSymbols.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

/// Document symbol client capabilities
public struct DocumentSymbolClientCapabilities: Codable, Equatable {
    /// This capability supports dynamic registration.
    var dynamicRegistration: Bool?

    /// Specific capabilities for the `SymbolKind`.
    var symbolKind: SymbolKindCapability?

    /// The client support hierarchical document symbols.
    var hierarchicalDocumentSymbolSupport: Bool?

    /// The client supports tags on `SymbolInformation`. Tags are supported on
    /// `DocumentSymbol` if `hierarchicalDocumentSymbolSupport` is set to true.
    /// Clients supporting tags have to handle unknown tags gracefully.
    ///
    /// @since 3.16.0
    var tagSupport: TagSupport<SymbolTag>?

    public static func == (lhs: DocumentSymbolClientCapabilities,
                           rhs: DocumentSymbolClientCapabilities) -> Bool {
        return lhs == rhs
    }
}

enum DocumentSymbolResponse: Codable, Equatable {
    case flat([SymbolInformation])
    case nested([DocumentSymbol])
}

public struct DocumentSymbolParams: Codable, Equatable {
    /// The text document.
    let textDocument: TextDocumentIdentifier

    let workDoneProgressParams: WorkDoneProgressParams
    let partialResultParams: PartialResultParams

    public static func == (lhs: DocumentSymbolParams,
                           rhs: DocumentSymbolParams) -> Bool {
        return lhs == rhs
    }
}

/// Represents programming conpublic structs like variables, classes, interfaces etc.
/// that appear in a document. Document symbols can be hierarchical and they have two ranges:
/// one that encloses its definition and one that points to its most interesting range,
/// e.g. the range of an identifier.
public struct DocumentSymbol: Codable, Equatable {
    /// The name of this symbol.
    let name: String
    /// More detail for this symbol, e.g the signature of a function. If not provided the
    /// name is used.
    let detail: String?
    /// The kind of this symbol.
    let kind: SymbolKind
    /// Tags for this completion item.
    ///
    /// @since 3.15.0
    let tags: [SymbolTag]?
    /// Indicates if this symbol is deprecated.
    @available(*, deprecated, message: "Use tags instead")
    let deprecated: Bool?
    /// The range enclosing this symbol not including leading/trailing whitespace but everything else
    /// like comments. This information is typically used to determine if the the clients cursor is
    /// inside the symbol to reveal in the symbol in the UI.
    let range: LSPRange
    /// The range that should be selected and revealed when this symbol is being picked, e.g the name of a function.
    /// Must be contained by the the `range`.
    let selectionRange: LSPRange
    /// Children of this symbol, e.g. properties of a class.
    let children: [DocumentSymbol]?

    public static func == (lhs: DocumentSymbol,
                           rhs: DocumentSymbol) -> Bool {
        return lhs == rhs
    }
}

/// Represents information about programming conpublic structs like variables, classes,
/// interfaces etc.
public struct SymbolInformation: Codable, Equatable {
    /// The name of this symbol.
    let name: String

    /// The kind of this symbol.
    let kind: SymbolKind

    /// Tags for this completion item.
    ///
    /// @since 3.16.0
    let tags: [SymbolTag]?

    /// Indicates if this symbol is deprecated.
    @available(*, deprecated, message: "Use tags instead")
    let deprecated: Bool?

    /// The location of this symbol.
    let location: LSPLocation

    /// The name of the symbol containing this symbol.
    let containerName: String?

    public static func == (lhs: SymbolInformation,
                           rhs: SymbolInformation) -> Bool {
        return lhs == rhs
    }
}
