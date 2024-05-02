//
//  InlineCompletion.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

/// Client capabilities specific to inline completions.
///
/// @since 3.18.0
public struct InlineCompletionClientCapabilities: Codable, Equatable {
    /// Whether implementation supports dynamic registration for inline completion providers.
    var dynamicRegistration: Bool?
}

/// Inline completion options used during static registration.
///
/// @since 3.18.0
public struct InlineCompletionOptions: Codable, Equatable {
    let workDoneProgressOptions: WorkDoneProgressOptions

    public static func == (lhs: InlineCompletionOptions,
                           rhs: InlineCompletionOptions) -> Bool {
        return lhs == rhs
    }
}

/// Inline completion options used during static or dynamic registration.
///
/// @since 3.18.0
public struct InlineCompletionRegistrationOptions: Codable, Equatable {
    let inlineCompletionOptions: InlineCompletionOptions
    let textDocumentRegistrationOptions: TextDocumentRegistrationOptions
    let staticRegistrationOptions: StaticRegistrationOptions

    public static func == (lhs: InlineCompletionRegistrationOptions,
                           rhs: InlineCompletionRegistrationOptions) -> Bool {
        return lhs == rhs
    }
}

/// A parameter literal used in inline completion requests.
///
/// @since 3.18.0
public struct InlineCompletionParams: Codable, Equatable {
    let workDoneProgressParams: WorkDoneProgressParams
    let textDocumentPosition: TextDocumentPositionParams
    
    /// Additional information about the context in which inline completions were requested.
    let context: InlineCompletionContext

    public static func == (lhs: InlineCompletionParams,
                           rhs: InlineCompletionParams) -> Bool {
        return lhs == rhs
    }
}

/// Describes how an [`InlineCompletionItemProvider`] was triggered.
///
/// @since 3.18.0
enum InlineCompletionTriggerKind: Int, Codable, Equatable {
    /// Completion was triggered explicitly by a user gesture.
    /// Return multiple completion items to enable cycling through them.
    case invoked = 1
    
    /// Completion was triggered automatically while editing.
    /// It is sufficient to return a single completion item in this case.
    case automatic = 2
}

/// Describes the currently selected completion item.
///
/// @since 3.18.0
public struct SelectedCompletionInfo: Codable, Equatable {
    /// The range that will be replaced if this completion item is accepted.
    let range: LSPRange
    /// The text the range will be replaced with if this completion is
    /// accepted.
    let text: String
}

/// Provides information about the context in which an inline completion was
/// requested.
///
/// @since 3.18.0
public struct InlineCompletionContext: Codable, Equatable {
    /// Describes how the inline completion was triggered.
    let triggerKind: InlineCompletionTriggerKind
    /// Provides information about the currently selected item in the
    /// autocomplete widget if it is visible.
    ///
    /// If set, provided inline completions must extend the text of the
    /// selected item and use the same range, otherwise they are not shown as
    /// preview.
    /// As an example, if the document text is `console.` and the selected item
    /// is `.log` replacing the `.` in the document, the inline completion must
    /// also replace `.` and start with `.log`, for example `.log()`.
    ///
    /// Inline completion providers are requested again whenever the selected
    /// item changes.
    let selectedCompletionInfo: SelectedCompletionInfo?
}

/// InlineCompletion response can be multiple completion items, or a list of completion items
enum InlineCompletionResponse: Codable, Equatable {
    case array([InlineCompletionItem])
    case list(InlineCompletionList)
}

/// Represents a collection of [`InlineCompletionItem`] to be presented in the editor.
///
/// @since 3.18.0
public struct InlineCompletionList: Codable, Equatable {
    /// The inline completion items
    let items: [InlineCompletionItem]
}

/// An inline completion item represents a text snippet that is proposed inline
/// to complete text that is being typed.
///
/// @since 3.18.0
public struct InlineCompletionItem: Codable, Equatable {
    /// The text to replace the range with. Must be set.
    /// Is used both for the preview and the accept operation.
    let insertText: String
    /// A text that is used to decide if this inline completion should be
    /// shown. When `falsy` the [`InlineCompletionItem::insertText`] is
    /// used.
    ///
    /// An inline completion is shown if the text to replace is a prefix of the
    /// filter text.
    let filterText: String?
    /// The range to replace.
    /// Must begin and end on the same line.
    ///
    /// Prefer replacements over insertions to provide a better experience when
    /// the user deletes typed text.
    let range: LSPRange?
    /// An optional command that is executed *after* inserting this
    /// completion.
    let command: LSPCommand?
    /// The format of the insert text. The format applies to the `insertText`.
    /// If omitted defaults to `InsertTextFormat.PlainText`.
    let insertTextFormat: InsertTextFormat?

    public static func == (lhs: InlineCompletionItem,
                           rhs: InlineCompletionItem) -> Bool {
        return lhs.filterText == rhs.filterText
    }
}
