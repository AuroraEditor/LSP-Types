//
//  DocumentLinks.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

/// Document link client capabilities
public struct DocumentLinkClientCapabilities: Codable, Equatable {
    /// Whether document link supports dynamic registration.
    var dynamicRegistration: Bool?
    
    /// Whether the client support the `tooltip` property on `DocumentLink`.
    var tooltipSupport: Bool?
}

public struct DocumentLinkOptions: Codable, Equatable {
    /// Document links have a resolve provider as well.
    var resolveProvider: Bool?
    
    let workDoneProgressOptions: WorkDoneProgressOptions
    
    public static func == (lhs: DocumentLinkOptions, rhs: DocumentLinkOptions) -> Bool {
        return lhs == rhs
    }
}

public struct DocumentLinkParams: Codable, Equatable {
    /// The document to provide document links for.
    let textDocument: TextDocumentIdentifier
    
    let workDoneProgressParams: WorkDoneProgressParams
    let partialResultParams: PartialResultParams
    
    public static func == (lhs: DocumentLinkParams, rhs: DocumentLinkParams) -> Bool {
        return lhs.textDocument.uri == rhs.textDocument.uri
    }
}

/// A document link is a range in a text document that links to an internal or external resource, like another
/// text document or a web site.
public struct DocumentLink: Codable, Equatable {
    /// The range this link applies to.
    let range: LSPRange
    
    /// The uri this link points to.
    let target: URL?
    
    /// The tooltip text when you hover over this link.
    ///
    /// If a tooltip is provided, is will be displayed in a string that includes inpublic structions on how to
    /// trigger the link, such as `{0} (ctrl + click)`. The specific inpublic structions vary depending on OS,
    /// user settings, and localization.
    let tooltip: String?
    
    /// A data entry field that is preserved on a document link between a DocumentLinkRequest
    /// and a DocumentLinkResolveRequest.
    let data: AnyCodable?

    public static func == (lhs: DocumentLink, rhs: DocumentLink) -> Bool {
        return lhs.target == rhs.target
    }
}
