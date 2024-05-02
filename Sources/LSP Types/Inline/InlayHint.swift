//
//  InlayHint.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

public enum InlayHintServerCapabilities: Codable, Equatable {
    case options(InlayHintOptions)
    case registrationOptions(InlayHintRegistrationOptions)
}

/// Inlay hint client capabilities.
///
/// @since 3.17.0
public struct InlayHintClientCapabilities: Codable, Equatable {
    /// Whether inlay hints support dynamic registration.
    var dynamicRegistration: Bool?
    
    /// Indicates which properties a client can resolve lazily on a inlay
    /// hint.
    var resolveSupport: InlayHintResolveClientCapabilities?
}

/// Inlay hint options used during static registration.
///
/// @since 3.17.0
public struct InlayHintOptions: Codable, Equatable {
    let workDoneProgressOptions: WorkDoneProgressOptions
    
    /// The server provides support to resolve additional
    /// information for an inlay hint item.
    var resolveProvider: Bool?

    public static func == (lhs: InlayHintOptions,
                           rhs: InlayHintOptions) -> Bool {
        return lhs == rhs
    }
}

/// Inlay hint options used during static or dynamic registration.
///
/// @since 3.17.0
public struct InlayHintRegistrationOptions: Codable, Equatable {
    let inlayHintOptions: InlayHintOptions
    let textDocumentRegistrationOptions: TextDocumentRegistrationOptions
    let staticRegistrationOptions: StaticRegistrationOptions

    public static func == (lhs: InlayHintRegistrationOptions,
                           rhs: InlayHintRegistrationOptions) -> Bool {
        return lhs == rhs
    }
}

/// A parameter literal used in inlay hint requests.
///
/// @since 3.17.0
public struct InlayHintParams: Codable, Equatable {
    let workDoneProgressParams: WorkDoneProgressParams
    
    /// The text document.
    let textDocument: TextDocumentIdentifier
    
    /// The visible document range for which inlay hints should be computed.
    let range: LSPRange

    public static func == (lhs: InlayHintParams,
                           rhs: InlayHintParams) -> Bool {
        return lhs == rhs
    }
}

/// Inlay hint information.
///
/// @since 3.17.0
public struct InlayHint: Codable, Equatable {
    /// The position of this hint.
    let position: LSPPosition
    
    /// The label of this hint. A human readable string or an array of
    /// InlayHintLabelPart label parts.
    ///
    /// *Note* that neither the string nor the label part can be empty.
    let label: InlayHintLabel
    
    /// The kind of this hint. Can be omitted in which case the client
    /// should fall back to a reasonable default.
    let kind: InlayHintKind?
    
    /// Optional text edits that are performed when accepting this inlay hint.
    ///
    /// *Note* that edits are expected to change the document so that the inlay
    /// hint (or its nearest variant) is now part of the document and the inlay
    /// hint itself is now obsolete.
    ///
    /// Depending on the client capability `inlayHint.resolveSupport` clients
    /// might resolve this property late using the resolve request.
    let textEdits: [TextEdit]?
    
    /// The tooltip text when you hover over this item.
    ///
    /// Depending on the client capability `inlayHint.resolveSupport` clients
    /// might resolve this property late using the resolve request.
    let tooltip: InlayHintTooltip?
    
    /// Render padding before the hint.
    ///
    /// Note: Padding should use the editor's background color, not the
    /// background color of the hint itself. That means padding can be used
    /// to visually align/separate an inlay hint.
    let paddingLeft: Bool?
    
    /// Render padding after the hint.
    ///
    /// Note: Padding should use the editor's background color, not the
    /// background color of the hint itself. That means padding can be used
    /// to visually align/separate an inlay hint.
    let paddingRight: Bool?
    
    /// A data entry field that is preserved on a inlay hint between
    /// a `textDocument/inlayHint` and a `inlayHint/resolve` request.
    let data: LSPAny?

    public static func == (lhs: InlayHint,
                           rhs: InlayHint) -> Bool {
        return lhs.position.line == rhs.position.line
    }
}

public enum InlayHintLabel: Codable, Equatable {
    case string(String)
    case labelParts([InlayHintLabelPart])
}

public enum InlayHintTooltip: Codable, Equatable {
    case string(String)
    case markupContent(MarkupContent)

    public static func == (lhs: InlayHintTooltip,
                           rhs: InlayHintTooltip) -> Bool {
        return lhs == rhs
    }
}

/// An inlay hint label part allows for interactive and composite labels
/// of inlay hints.
public struct InlayHintLabelPart: Codable, Equatable {
    /// The value of this label part.
    let value: String
    
    /// The tooltip text when you hover over this label part. Depending on
    /// the client capability `inlayHint.resolveSupport` clients might resolve
    /// this property late using the resolve request.
    let tooltip: InlayHintLabelPartTooltip?
    
    /// An optional source code location that represents this
    /// label part.
    ///
    /// The editor will use this location for the hover and for code navigation
    /// features: This part will become a clickable link that resolves to the
    /// definition of the symbol at the given location (not necessarily the
    /// location itself), it shows the hover that shows at the given location,
    /// and it shows a context menu with further code navigation commands.
    ///
    /// Depending on the client capability `inlayHint.resolveSupport` clients
    /// might resolve this property late using the resolve request.
    let location: LSPLocation?

    /// An optional command for this label part.
    ///
    /// Depending on the client capability `inlayHint.resolveSupport` clients
    /// might resolve this property late using the resolve request.
    let command: LSPCommand?

    public static func == (lhs: InlayHintLabelPart,
                           rhs: InlayHintLabelPart) -> Bool {
        return lhs.value == rhs.value
    }
}

public enum InlayHintLabelPartTooltip: Codable, Equatable {
    case string(String)
    case markupContent(MarkupContent)

    public static func == (lhs: InlayHintLabelPartTooltip,
                           rhs: InlayHintLabelPartTooltip) -> Bool {
        return lhs == rhs
    }
}

/// Inlay hint kinds.
///
/// @since 3.17.0
public enum InlayHintKind: Int, Codable, Equatable {
    /// An inlay hint that for a type annotation.
    case type = 1
    
    /// An inlay hint that is for a parameter.
    case parameter = 2
}

/// Inlay hint client capabilities.
///
/// @since 3.17.0
public struct InlayHintResolveClientCapabilities: Codable, Equatable {
    /// The properties that a client can resolve lazily.
    let properties: [String]
}

/// Client workspace capabilities specific to inlay hints.
///
/// @since 3.17.0
public struct InlayHintWorkspaceClientCapabilities: Codable, Equatable {
    /// Whether the client implementation supports a refresh request sent from
    /// the server to the client.
    ///
    /// Note that this event is global and will force the client to refresh all
    /// inlay hints currently shown. It should be used with absolute care and
    /// is useful for situation where a server for example detects a project wide
    /// change that requires such a calculation.
    var refreshSupport: Bool?
}
