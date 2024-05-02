//
//  LSPReferences.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

typealias ReferenceClientCapabilities = DynamicRegistrationClientCapabilities

public struct ReferenceContext: Codable {
    /// Include the declaration of the current symbol.
    let includeDeclaration: Bool
}

public struct ReferenceParams: Codable {
    // Text Document and Position fields
    let textDocumentPosition: TextDocumentPositionParams

    let workDoneProgressParams: WorkDoneProgressParams

    let partialResultParams: PartialResultParams

    // ReferenceParams properties:
    let context: ReferenceContext

    enum CodingKeys: String, CodingKey {
        case context
        case textDocumentPosition
        case workDoneProgressParams
        case partialResultParams
    }
}
