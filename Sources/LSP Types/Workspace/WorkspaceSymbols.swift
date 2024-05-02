//
//  WorkspaceSymbols.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/04/28.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

/// Workspace client capabilities specific to the `workspace/symbol` request.
public struct WorkspaceSymbolClientCapabilities: Codable, Equatable {
    /// This capability supports dynamic registration.
    var dynamicRegistration: Bool?
    
    /// Specific capabilities for the `SymbolKind` in the `workspace/symbol` request.
    var symbolKind: SymbolKindCapability?
    
    /// The client supports tags on `SymbolInformation`.
    /// Clients supporting tags have to handle unknown tags gracefully.
    ///
    /// @since 3.16.0
    var tagSupport: TagSupport<SymbolTag>?
    
    /// The client support partial workspace symbols. The client will send the
    /// request `workspaceSymbol/resolve` to the server to resolve additional
    /// properties.
    ///
    /// @since 3.17.0
    var resolveSupport: WorkspaceSymbolResolveSupportCapability?

    public static func == (lhs: WorkspaceSymbolClientCapabilities,
                           rhs: WorkspaceSymbolClientCapabilities) -> Bool {
        return lhs == rhs
    }
}

/// The parameters of a Workspace Symbol Request.
public struct WorkspaceSymbolParams: Codable, Equatable {
    let partialResultParams: PartialResultParams
    let workDoneProgressParams: WorkDoneProgressParams
    
    /// A non-empty query string
    let query: String

    public static func == (lhs: WorkspaceSymbolParams,
                           rhs: WorkspaceSymbolParams) -> Bool {
        return lhs.query == rhs.query
    }
}

public struct WorkspaceSymbolResolveSupportCapability: Codable, Equatable {
    /// The properties that a client can resolve lazily. Usually
    /// `location.range`
    let properties: [String]
}

/// A special workspace symbol that supports locations without a range
///
/// @since 3.17.0
public struct WorkspaceSymbol: Codable, Equatable {
    /// The name of this symbol.
    let name: String
    
    /// The kind of this symbol.
    let kind: SymbolKind
    
    /// Tags for this completion item.
    let tags: [SymbolTag]?
    
    /// The name of the symbol containing this symbol. This information is for
    /// user interface purposes (e.g. to render a qualifier in the user interface
    /// if necessary). It can't be used to re-infer a hierarchy for the document
    /// symbols.
    let containerName: String?
    
    /// The location of this symbol. Whether a server is allowed to
    /// return a location without a range depends on the client
    /// capability `workspace.symbol.resolveSupport`.
    ///
    /// See also `SymbolInformation.location`.
    let location: OneOf<LSPLocation, WorkspaceLocation>

    /// A data entry field that is preserved on a workspace symbol between a
    /// workspace symbol request and a workspace symbol resolve request.
    let data: LSPAny?

    public static func == (lhs: WorkspaceSymbol,
                           rhs: WorkspaceSymbol) -> Bool {
        return lhs == rhs
    }
}

public struct WorkspaceLocation: Codable, Equatable {
    let uri: URL
}

enum WorkspaceSymbolResponse: Codable, Equatable {
    case flat([SymbolInformation])
    case nested([WorkspaceSymbol])
}
