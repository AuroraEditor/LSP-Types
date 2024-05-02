//
//  LSPCodeAction.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

public enum CodeActionProviderCapability: Codable {
    case simple(Bool)
    case options(CodeActionOptions)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) {
            self = .simple(value)
        } else {
            self = .options(try container.decode(CodeActionOptions.self))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .simple(let value):
            try container.encode(value)
        case .options(let value):
            try container.encode(value)
        }
    }
}

extension CodeActionOptions {
    func asCodeActionProviderCapability() -> CodeActionProviderCapability {
        return .options(self)
    }
}

extension Bool {
    func asCodeActionProviderCapability() -> CodeActionProviderCapability {
        return .simple(self)
    }
}

public struct CodeActionClientCapabilities: Codable {
    /// This capability supports dynamic registration.
    let dynamicRegistration: Bool?

    /// The client support code action literals as a valid
    /// response of the `textDocument/codeAction` request.
    let codeActionLiteralSupport: CodeActionLiteralSupport?

    /// Whether code action supports the `isPreferred` property.
    ///
    /// @since 3.15.0
    let isPreferredSupport: Bool?

    /// Whether code action supports the `disabled` property.
    ///
    /// @since 3.16.0
    let disabledSupport: Bool?

    /// Whether code action supports the `data` property which is
    /// preserved between a `textDocument/codeAction` and a
    /// `codeAction/resolve` request.
    ///
    /// @since 3.16.0
    let dataSupport: Bool?

    /// Whether the client supports resolving additional code action
    /// properties via a separate `codeAction/resolve` request.
    ///
    /// @since 3.16.0
    let resolveSupport: CodeActionCapabilityResolveSupport?

    /// Whether the client honors the change annotations in
    /// text edits and resource operations returned via the
    /// `CodeAction#edit` property by for example presenting
    /// the workspace edit in the user interface and asking
    /// for confirmation.
    ///
    /// @since 3.16.0
    let honorsChangeAnnotations: Bool?

    enum CodingKeys: String, CodingKey {
        case dynamicRegistration
        case codeActionLiteralSupport
        case isPreferredSupport
        case disabledSupport
        case dataSupport
        case resolveSupport
        case honorsChangeAnnotations
    }
}

/// Whether the client supports resolving additional code action
/// properties via a separate `codeAction/resolve` request.
///
/// @since 3.16.0
public struct CodeActionCapabilityResolveSupport: Codable {
    /// The properties that a client can resolve lazily.
    let properties: [String]
}

public struct CodeActionLiteralSupport: Codable {
    /// The code action kind is support with the following value set.
    let codeActionKind: CodeActionKindLiteralSupport
}

public struct CodeActionKindLiteralSupport: Codable {
    /// The code action kind values the client supports. When this
    /// property exists the client also guarantees that it will
    /// handle values outside its set gracefully and falls back
    /// to a default value when unknown.
    let valueSet: [String]
}

/// Params for the CodeActionRequest
public struct CodeActionParams: Codable {
    /// The document in which the command was invoked.
    let textDocument: TextDocumentIdentifier

    /// The range for which the command was invoked.
    let range: LSPRange

    /// Context carrying additional information.
    let context: CodeActionContext

    let workDoneProgressParams: WorkDoneProgressParams

    let partialResultParams: PartialResultParams
}

/// response for CodeActionRequest
typealias CodeActionResponse = [CodeActionOrCommand]

public enum CodeActionOrCommand: Codable {
    case command(LSPCommand)
    case codeAction(CodeAction)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let command = try? container.decode(LSPCommand.self) {
            self = .command(command)
        } else {
            self = .codeAction(try container.decode(CodeAction.self))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .command(let command):
            try container.encode(command)
        case .codeAction(let codeAction):
            try container.encode(codeAction)
        }
    }
}

extension LSPCommand {
    func asCodeActionOrCommand() -> CodeActionOrCommand {
        return .command(self)
    }
}

extension CodeAction {
    func asCodeActionOrCommand() -> CodeActionOrCommand {
        return .codeAction(self)
    }
}

public struct CodeActionKind: RawRepresentable, Codable, Hashable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Empty kind.
    static let empty = CodeActionKind(rawValue: "")

    /// Base kind for quickfix actions: 'quickfix'
    static let quickfix = CodeActionKind(rawValue: "quickfix")

    /// Base kind for refactoring actions: 'refactor'
    static let refactor = CodeActionKind(rawValue: "refactor")

    /// Base kind for refactoring extraction actions: 'refactor.extract'
    ///
    /// Example extract actions:
    ///
    /// - Extract method
    /// - Extract function
    /// - Extract variable
    /// - Extract interface from class
    /// - ...
    static let refactorExtract = CodeActionKind(rawValue: "refactor.extract")

    /// Base kind for refactoring inline actions: 'refactor.inline'
    ///
    /// Example inline actions:
    ///
    /// - Inline function
    /// - Inline variable
    /// - Inline constant
    /// - ...
    static let refactorInline = CodeActionKind(rawValue: "refactor.inline")

    /// Base kind for refactoring rewrite actions: 'refactor.rewrite'
    ///
    /// Example rewrite actions:
    ///
    /// - Convert JavaScript function to class
    /// - Add or remove parameter
    /// - Encapsulate field
    /// - Make method static
    /// - Move method to base class
    /// - ...
    static let refactorRewrite = CodeActionKind(rawValue: "refactor.rewrite")

    /// Base kind for source actions: `source`
    ///
    /// Source code actions apply to the entire file.
    static let source = CodeActionKind(rawValue: "source")

    /// Base kind for an organize imports source action: `source.organizeImports`
    static let sourceOrganizeImports = CodeActionKind(rawValue: "source.organizeImports")

    /// Base kind for a 'fix all' source action: `source.fixAll`.
    ///
    /// 'Fix all' actions automatically fix errors that have a clear fix that
    /// do not require user input. They should not suppress errors or perform
    /// unsafe fixes such as generating new types or classes.
    ///
    /// @since 3.17.0
    static let sourceFixAll = CodeActionKind(rawValue: "source.fixAll")
}

extension String {
    func asCodeActionKind() -> CodeActionKind {
        return CodeActionKind(rawValue: self)
    }
}

extension StaticString {
    func asCodeActionKind() -> CodeActionKind {
        return CodeActionKind(rawValue: self.description)
    }
}

public struct CodeAction: Codable {
    /// A short, human-readable, title for this code action.
    let title: String

    /// The kind of the code action.
    /// Used to filter code actions.
    let kind: CodeActionKind?

    /// The diagnostics that this code action resolves.
    let diagnostics: [Diagnostic]?

    /// The workspace edit this code action performs.
    let edit: WorkspaceEdit?

    /// A command this code action executes. If a code action
    /// provides an edit and a command, first the edit is
    /// executed and then the command.
    let command: LSPCommand?

    /// Marks this as a preferred action. Preferred actions are used by the `auto fix` command and can be targeted
    /// by keybindings.
    /// A quick fix should be marked preferred if it properly addresses the underlying error.
    /// A refactoring should be marked preferred if it is the most reasonable choice of actions to take.
    ///
    /// @since 3.15.0
    let isPreferred: Bool?

    /// Marks that the code action cannot currently be applied.
    ///
    /// Clients should follow the following guidelines regarding disabled code actions:
    ///
    /// - Disabled code actions are not shown in automatic
    ///   [lightbulb](https://code.visualstudio.com/docs/editor/editingevolved#_code-action)
    ///   code action menu.
    ///
    /// - Disabled actions are shown as faded out in the code action menu when the user request
    ///   a more specific type of code action, such as refactorings.
    ///
    /// - If the user has a keybinding that auto applies a code action and only a disabled code
    ///   actions are returned, the client should show the user an error message with `reason`
    ///   in the editor.
    ///
    /// @since 3.16.0
    let disabled: CodeActionDisabled?

    /// A data entry field that is preserved on a code action between
    /// a `textDocument/codeAction` and a `codeAction/resolve` request.
    ///
    /// @since 3.16.0
    let data: LSPAny?

    enum CodingKeys: String, CodingKey {
        case title
        case kind
        case diagnostics
        case edit
        case command
        case isPreferred
        case disabled
        case data
    }
}

public struct CodeActionDisabled: Codable {
    /// Human readable description of why the code action is currently disabled.
    ///
    /// This is displayed in the code actions UI.
    let reason: String
}

/// The reason why code actions were requested.
///
/// @since 3.17.0
public struct CodeActionTriggerKind: RawRepresentable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Code actions were explicitly requested by the user or by an extension.
    static let invoked = CodeActionTriggerKind(rawValue: 1)

    /// Code actions were requested automatically.
    ///
    /// This typically happens when current selection in a file changes, but can
    /// also be triggered when file content changes.
    static let automatic = CodeActionTriggerKind(rawValue: 2)
}

/// Contains additional diagnostic information about the context in which
/// a code action is run.
public struct CodeActionContext: Codable {
    /// An array of diagnostics.
    let diagnostics: [Diagnostic]

    /// Requested kind of actions to return.
    ///
    /// Actions not of this kind are filtered out by the client before being shown. So servers
    /// can omit computing them.
    let only: [CodeActionKind]?

    /// The reason why code actions were requested.
    ///
    /// @since 3.17.0
    let triggerKind: CodeActionTriggerKind?

    enum CodingKeys: String, CodingKey {
        case diagnostics
        case only
        case triggerKind
    }
}

public struct CodeActionOptions: Codable {
    /// CodeActionKinds that this server may return.
    ///
    /// The list of kinds may be generic, such as `CodeActionKind.Refactor`, or the server
    /// may list out every specific kind they provide.
    let codeActionKinds: [CodeActionKind]?

    let workDoneProgressOptions: WorkDoneProgressOptions

    /// The server provides support to resolve additional
    /// information for a code action.
    ///
    /// @since 3.16.0
    let resolveProvider: Bool?

    enum CodingKeys: String, CodingKey {
        case codeActionKinds
        case workDoneProgressOptions
        case resolveProvider
    }
}
