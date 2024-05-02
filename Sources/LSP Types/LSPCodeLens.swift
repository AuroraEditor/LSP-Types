//
//  LSPCodeLens.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

typealias CodeLensClientCapabilities = DynamicRegistrationClientCapabilities

/// Code Lens options.
public struct CodeLensOptions: Codable {
    /// Code lens has a resolve provider as well.
    let resolveProvider: Bool?

    enum CodingKeys: String, CodingKey {
        case resolveProvider
    }
}

public struct CodeLensParams: Codable {
    /// The document to request code lens for.
    let textDocument: TextDocumentIdentifier

    let workDoneProgressParams: WorkDoneProgressParams

    let partialResultParams: PartialResultParams
}

/// A code lens represents a command that should be shown along with
/// source text, like the number of references, a way to run tests, etc.
///
/// A code lens is _unresolved_ when no command is associated to it. For performance
/// reasons the creation of a code lens and resolving should be done in two stages.
public struct CodeLens: Codable {
    /// The range in which this code lens is valid. Should only span a single line.
    let range: LSPRange

    /// The command this code lens represents.
    let command: LSPCommand?

    /// A data entry field that is preserved on a code lens item between
    /// a code lens and a code lens resolve request.
    let data: LSPAny?

    enum CodingKeys: String, CodingKey {
        case range
        case command
        case data
    }
}

public struct CodeLensWorkspaceClientCapabilities: Codable {
    /// Whether the client implementation supports a refresh request sent from the
    /// server to the client.
    ///
    /// Note that this event is global and will force the client to refresh all
    /// code lenses currently shown. It should be used with absolute care and is
    /// useful for situation where a server for example detect a project wide
    /// change that requires such a calculation.
    let refreshSupport: Bool?

    enum CodingKeys: String, CodingKey {
        case refreshSupport
    }
}
