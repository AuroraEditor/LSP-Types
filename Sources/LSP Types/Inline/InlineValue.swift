//
//  InlineValue.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

typealias InlineValueClientCapabilities = DynamicRegistrationClientCapabilities

enum InlineValueServerCapabilities: Codable, Equatable {
    case options(InlineValueOptions)
    case registrationOptions(InlineValueRegistrationOptions)
}

/// Inline value options used during static registration.
///
/// @since 3.17.0
public struct InlineValueOptions: Codable, Equatable {
    let workDoneProgressOptions: WorkDoneProgressOptions

    public static func == (lhs: InlineValueOptions,
                           rhs: InlineValueOptions) -> Bool {
        return lhs == rhs
    }
}

/// Inline value options used during static or dynamic registration.
///
/// @since 3.17.0
public struct InlineValueRegistrationOptions: Codable, Equatable {
    let inlineValueOptions: InlineValueOptions
    let textDocumentRegistrationOptions: TextDocumentRegistrationOptions
    let staticRegistrationOptions: StaticRegistrationOptions

    public static func == (lhs: InlineValueRegistrationOptions,
                           rhs: InlineValueRegistrationOptions) -> Bool {
        return lhs == rhs
    }
}

/// A parameter literal used in inline value requests.
///
/// @since 3.17.0
public struct InlineValueParams: Codable, Equatable {
    let workDoneProgressParams: WorkDoneProgressParams

    /// The text document.
    let textDocument: TextDocumentIdentifier

    /// The document range for which inline values should be computed.
    let range: LSPRange

    /// Additional information about the context in which inline values were
    /// requested.
    let context: InlineValueContext

    public static func == (lhs: InlineValueParams, rhs: InlineValueParams) -> Bool {
        return lhs == rhs
    }
}

/// @since 3.17.0
public struct InlineValueContext: Codable, Equatable {
    /// The stack frame (as a DAP Id) where the execution has stopped.
    let frameId: Int32

    /// The document range where execution has stopped.
    /// Typically the end position of the range denotes the line where the
    /// inline values are shown.
    let stoppedLocation: LSPRange
}

/// Provide inline value as text.
///
/// @since 3.17.0
public struct InlineValueText: Codable, Equatable {
    /// The document range for which the inline value applies.
    let range: LSPRange

    /// The text of the inline value.
    let text: String
}

/// Provide inline value through a variable lookup.
///
/// If only a range is specified, the variable name will be extracted from
/// the underlying document.
///
/// An optional variable name can be used to override the extracted name.
///
/// @since 3.17.0
public struct InlineValueVariableLookup: Codable, Equatable {
    /// The document range for which the inline value applies.
    /// The range is used to extract the variable name from the underlying
    /// document.
    let range: LSPRange

    /// If specified the name of the variable to look up.
    let variableName: String?

    /// How to perform the lookup.
    let caseSensitiveLookup: Bool
}

/// Provide an inline value through an expression evaluation.
///
/// If only a range is specified, the expression will be extracted from the
/// underlying document.
///
/// An optional expression can be used to override the extracted expression.
///
/// @since 3.17.0
public struct InlineValueEvaluatableExpression: Codable, Equatable {
    /// The document range for which the inline value applies.
    /// The range is used to extract the evaluatable expression from the
    /// underlying document.
    let range: LSPRange

    /// If specified the expression overrides the extracted expression.
    let expression: String?
}

/// Inline value information can be provided by different means:
/// - directly as a text value (class InlineValueText).
/// - as a name to use for a variable lookup (class InlineValueVariableLookup)
/// - as an evaluatable expression (class InlineValueEvaluatableExpression)
/// The InlineValue types combines all inline value types into one type.
///
/// @since 3.17.0
enum InlineValue: Codable, Equatable {
    case text(InlineValueText)
    case variableLookup(InlineValueVariableLookup)
    case evaluatableExpression(InlineValueEvaluatableExpression)
}

/// Client workspace capabilities specific to inline values.
///
/// @since 3.17.0
public struct InlineValueWorkspaceClientCapabilities: Codable, Equatable {
    /// Whether the client implementation supports a refresh request sent from
    /// the server to the client.
    ///
    /// Note that this event is global and will force the client to refresh all
    /// inline values currently shown. It should be used with absolute care and
    /// is useful for situation where a server for example detect a project wide
    /// change that requires such a calculation.
    var refreshSupport: Bool?
}
