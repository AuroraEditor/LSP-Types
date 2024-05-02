//
//  DocumentHighlight.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

typealias DocumentHighlightClientCapabilities = DynamicRegistrationClientCapabilities

public struct DocumentHighlightParams: Codable, Equatable {
    let textDocumentPositionParams: TextDocumentPositionParams
    let workDoneProgressParams: WorkDoneProgressParams
    let partialResultParams: PartialResultParams
    
    public static func == (lhs: DocumentHighlightParams,
                           rhs: DocumentHighlightParams) -> Bool {
        return lhs.textDocumentPositionParams.position == rhs.textDocumentPositionParams.position
    }
}

/// A document highlight is a range inside a text document which deserves
/// special attention. Usually a document highlight is visualized by changing
/// the background color of its range.
public struct DocumentHighlight: Codable, Equatable {
    /// The range this highlight applies to.
    let range: LSPRange
    
    /// The highlight kind, default is DocumentHighlightKind.text.
    let kind: DocumentHighlightKind?
}

/// A document highlight kind.
public enum DocumentHighlightKind: Int, Codable, Equatable {
    /// A textual occurrence.
    case text = 1
    
    /// Read-access of a symbol, like reading a variable.
    case read = 2
    
    /// Write-access of a symbol, like writing to a variable.
    case write = 3
}
