//
//  LSPCompletion.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

/// Defines how to interpret the insert text in a completion item
public struct InsertTextFormat: RawRepresentable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let plainText = InsertTextFormat(rawValue: 1)
    static let snippet = InsertTextFormat(rawValue: 2)
}

/// The kind of a completion entry.
public struct CompletionItemKind: RawRepresentable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let text = CompletionItemKind(rawValue: 1)
    static let method = CompletionItemKind(rawValue: 2)
    static let function = CompletionItemKind(rawValue: 3)
    static let constructor = CompletionItemKind(rawValue: 4)
    static let field = CompletionItemKind(rawValue: 5)
    static let variable = CompletionItemKind(rawValue: 6)
    static let `class` = CompletionItemKind(rawValue: 7)
    static let `interface` = CompletionItemKind(rawValue: 8)
    static let module = CompletionItemKind(rawValue: 9)
    static let property = CompletionItemKind(rawValue: 10)
    static let unit = CompletionItemKind(rawValue: 11)
    static let value = CompletionItemKind(rawValue: 12)
    static let `enum` = CompletionItemKind(rawValue: 13)
    static let keyword = CompletionItemKind(rawValue: 14)
    static let snippet = CompletionItemKind(rawValue: 15)
    static let color = CompletionItemKind(rawValue: 16)
    static let file = CompletionItemKind(rawValue: 17)
    static let reference = CompletionItemKind(rawValue: 18)
    static let folder = CompletionItemKind(rawValue: 19)
    static let enumMember = CompletionItemKind(rawValue: 20)
    static let constant = CompletionItemKind(rawValue: 21)
    static let `struct` = CompletionItemKind(rawValue: 22)
    static let event = CompletionItemKind(rawValue: 23)
    static let `operator` = CompletionItemKind(rawValue: 24)
    static let typeParameter = CompletionItemKind(rawValue: 25)
}

public struct CompletionItemCapability: Codable {
    /// Client supports snippets as insert text.
    ///
    /// A snippet can define tab stops and placeholders with `$1`, `$2`
    /// and `${3:foo}`. `$0` defines the final tab stop, it defaults to
    /// the end of the snippet. Placeholders with equal identifiers are linked,
    /// that is typing in one will update others too.
    let snippetSupport: Bool?

    /// Client supports commit characters on a completion item.
    let commitCharactersSupport: Bool?

    /// Client supports the follow content formats for the documentation
    /// property. The order describes the preferred format of the client.
    let documentationFormat: [MarkupKind]?

    /// Client supports the deprecated property on a completion item.
    let deprecatedSupport: Bool?

    /// Client supports the preselect property on a completion item.
    let preselectSupport: Bool?

    /// Client supports the tag property on a completion item. Clients supporting
    /// tags have to handle unknown tags gracefully. Clients especially need to
    /// preserve unknown tags when sending a completion item back to the server in
    /// a resolve call.
    let tagSupport: TagSupport<CompletionItemTag>?

    /// Client support insert replace edit to control different behavior if a
    /// completion item is inserted in the text or should replace text.
    ///
    /// @since 3.16.0
    let insertReplaceSupport: Bool?

    /// Indicates which properties a client can resolve lazily on a completion
    /// item. Before version 3.16.0 only the predefined properties `documentation`
    /// and `details` could be resolved lazily.
    ///
    /// @since 3.16.0
    let resolveSupport: CompletionItemCapabilityResolveSupport?

    /// The client supports the `insertTextMode` property on
    /// a completion item to override the whitespace handling mode
    /// as defined by the client.
    ///
    /// @since 3.16.0
    let insertTextModeSupport: InsertTextModeSupport?

    /// The client has support for completion item label
    /// details (see also `CompletionItemLabelDetails`).
    ///
    /// @since 3.17.0
    let labelDetailsSupport: Bool?

    enum CodingKeys: String, CodingKey {
        case snippetSupport
        case commitCharactersSupport
        case documentationFormat
        case deprecatedSupport
        case preselectSupport
        case tagSupport
        case insertReplaceSupport
        case resolveSupport
        case insertTextModeSupport
        case labelDetailsSupport
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        snippetSupport = try container.decodeIfPresent(Bool.self, forKey: .snippetSupport)
        commitCharactersSupport = try container.decodeIfPresent(Bool.self, forKey: .commitCharactersSupport)
        documentationFormat = try container.decodeIfPresent([MarkupKind].self, forKey: .documentationFormat)
        deprecatedSupport = try container.decodeIfPresent(Bool.self, forKey: .deprecatedSupport)
        preselectSupport = try container.decodeIfPresent(Bool.self, forKey: .preselectSupport)
        tagSupport = try TagSupport<CompletionItemTag>.decodeCompatible(from: container, forKey: CodingKeys.tagSupport)
        insertReplaceSupport = try container.decodeIfPresent(Bool.self, forKey: .insertReplaceSupport)
        resolveSupport = try container.decodeIfPresent(CompletionItemCapabilityResolveSupport.self, forKey: .resolveSupport)
        insertTextModeSupport = try container.decodeIfPresent(InsertTextModeSupport.self, forKey: .insertTextModeSupport)
        labelDetailsSupport = try container.decodeIfPresent(Bool.self, forKey: .labelDetailsSupport)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(snippetSupport, forKey: .snippetSupport)
        try container.encodeIfPresent(commitCharactersSupport, forKey: .commitCharactersSupport)
        try container.encodeIfPresent(documentationFormat, forKey: .documentationFormat)
        try container.encodeIfPresent(deprecatedSupport, forKey: .deprecatedSupport)
        try container.encodeIfPresent(preselectSupport, forKey: .preselectSupport)
        try container.encodeIfPresent(tagSupport, forKey: .tagSupport)
        try container.encodeIfPresent(insertReplaceSupport, forKey: .insertReplaceSupport)
        try container.encodeIfPresent(resolveSupport, forKey: .resolveSupport)
        try container.encodeIfPresent(insertTextModeSupport, forKey: .insertTextModeSupport)
        try container.encodeIfPresent(labelDetailsSupport, forKey: .labelDetailsSupport)
    }
}

public struct CompletionItemCapabilityResolveSupport: Codable {
    /// The properties that a client can resolve lazily.
    let properties: [String]
}

public struct InsertTextModeSupport: Codable {
    let valueSet: [InsertTextMode]
}

/// How whitespace and indentation is handled during completion
/// item insertion.
///
/// @since 3.16.0
public struct InsertTextMode: RawRepresentable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// The insertion or replace strings is taken as it is. If the
    /// value is multi line the lines below the cursor will be
    /// inserted using the indentation defined in the string value.
    /// The client will not apply any kind of adjustments to the
    /// string.
    static let asIs = InsertTextMode(rawValue: 1)

    /// The editor adjusts leading whitespace of new lines so that
    /// they match the indentation up to the cursor of the line for
    /// which the item is accepted.
    ///
    /// Consider a line like this: <2tabs><cursor><3tabs>foo. Accepting a
    /// multi line completion item is indented using 2 tabs all
    /// following lines inserted will be indented using 2 tabs as well.
    static let adjustIndentation = InsertTextMode(rawValue: 2)
}

public struct CompletionItemTag: RawRepresentable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let deprecated = CompletionItemTag(rawValue: 1)
}

public struct CompletionItemKindCapability: Codable {
    /// The completion item kind values the client supports. When this
    /// property exists the client also guarantees that it will
    /// handle values outside its set gracefully and falls back
    /// to a default value when unknown.
    ///
    /// If this property is not present the client only supports
    /// the completion items kinds from `Text` to `Reference` as defined in
    /// the initial version of the protocol.
    let valueSet: [CompletionItemKind]?

    enum CodingKeys: String, CodingKey {
        case valueSet
    }
}

public struct CompletionListCapability: Codable {
    /// The client supports the following itemDefaults on
    /// a completion list.
    ///
    /// The value lists the supported property names of the
    /// `CompletionList.itemDefaults` object. If omitted
    /// no properties are supported.
    ///
    /// @since 3.17.0
    let itemDefaults: [String]?

    enum CodingKeys: String, CodingKey {
        case itemDefaults
    }
}

public struct CompletionClientCapabilities: Codable {
    /// Whether completion supports dynamic registration.
    let dynamicRegistration: Bool?

    /// The client supports the following `CompletionItem` specific
    /// capabilities.
    let completionItem: CompletionItemCapability?

    let completionItemKind: CompletionItemKindCapability?

    /// The client supports to send additional context information for a
    /// `textDocument/completion` request.
    let contextSupport: Bool?

    /// The client's default when the completion item doesn't provide a
    /// `insertTextMode` property.
    ///
    /// @since 3.17.0
    let insertTextMode: InsertTextMode?

    /// The client supports the following `CompletionList` specific
    /// capabilities.
    ///
    /// @since 3.17.0
    let completionList: CompletionListCapability?

    enum CodingKeys: String, CodingKey {
        case dynamicRegistration
        case completionItem
        case completionItemKind
        case contextSupport
        case insertTextMode
        case completionList
    }
}

/// A special text edit to provide an insert and a replace operation.
///
/// @since 3.16.0
public struct InsertReplaceEdit: Codable {
    /// The string to be inserted.
    let newText: String

    /// The range if the insert is requested
    let insert: LSPRange

    /// The range if the replace is requested.
    let replace: LSPRange
}

public enum CompletionTextEdit: Codable {
    case edit(TextEdit)
    case insertAndReplace(InsertReplaceEdit)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let edit = try? container.decode(TextEdit.self) {
            self = .edit(edit)
        } else if let insertAndReplace = try? container.decode(InsertReplaceEdit.self) {
            self = .insertAndReplace(insertAndReplace)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid CompletionTextEdit")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .edit(let edit):
            try container.encode(edit)
        case .insertAndReplace(let insertAndReplace):
            try container.encode(insertAndReplace)
        }
    }
}

extension TextEdit {
    func asCompletionTextEdit() -> CompletionTextEdit {
        return .edit(self)
    }
}

extension InsertReplaceEdit {
    func asCompletionTextEdit() -> CompletionTextEdit {
        return .insertAndReplace(self)
    }
}

/// Completion options.
public struct CompletionOptions: Codable {
    /// The server provides support to resolve additional information for a completion item.
    let resolveProvider: Bool?

    /// Most tools trigger completion request automatically without explicitly
    /// requesting it using a keyboard shortcut (e.g. Ctrl+Space). Typically they
    /// do so when the user starts to type an identifier. For example if the user
    /// types `c` in a JavaScript file code complete will automatically pop up
    /// present `console` besides others as a completion item. Characters that
    /// make up identifiers don't need to be listed here.
    ///
    /// If code complete should automatically be trigger on characters not being
    /// valid inside an identifier (for example `.` in JavaScript) list them in
    /// `triggerCharacters`.
    let triggerCharacters: [String]?

    /// The list of all possible characters that commit a completion. This field
    /// can be used if clients don't support individual commit characters per
    /// completion item. See client capability
    /// `completion.completionItem.commitCharactersSupport`.
    ///
    /// If a server provides both `allCommitCharacters` and commit characters on
    /// an individual completion item the ones on the completion item win.
    ///
    /// @since 3.2.0
    let allCommitCharacters: [String]?

    let workDoneProgressOptions: WorkDoneProgressOptions

    /// The server supports the following `CompletionItem` specific
    /// capabilities.
    ///
    /// @since 3.17.0
    let completionItem: CompletionOptionsCompletionItem?
}

public struct CompletionOptionsCompletionItem: Codable {
    /// The server has support for completion item label
    /// details (see also `CompletionItemLabelDetails`) when receiving
    /// a completion item in a resolve call.
    ///
    /// @since 3.17.0
    let labelDetailsSupport: Bool?

    enum CodingKeys: String, CodingKey {
        case labelDetailsSupport
    }
}

public struct CompletionRegistrationOptions: Codable {
    let textDocumentRegistrationOptions: TextDocumentRegistrationOptions
    let completionOptions: CompletionOptions
}

enum CompletionResponse: Codable {
    case array([CompletionItem])
    case list(CompletionList)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let array = try? container.decode([CompletionItem].self) {
            self = .array(array)
        } else if let list = try? container.decode(CompletionList.self) {
            self = .list(list)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid CompletionResponse")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .array(let array):
            try container.encode(array)
        case .list(let list):
            try container.encode(list)
        }
    }
}

extension Array where Element == CompletionItem {
    func asCompletionResponse() -> CompletionResponse {
        return .array(self)
    }
}

extension CompletionList {
    func asCompletionResponse() -> CompletionResponse {
        return .list(self)
    }
}

public struct CompletionParams: Codable {
    // Text Document and Position fields
    let textDocumentPosition: TextDocumentPositionParams

    let workDoneProgressParams: WorkDoneProgressParams

    let partialResultParams: PartialResultParams

    // CompletionParams properties:
    let context: CompletionContext?
}

public struct CompletionContext: Codable {
    /// How the completion was triggered.
    let triggerKind: CompletionTriggerKind

    /// The trigger character (a single character) that has trigger code complete.
    /// Is undefined if `triggerKind !== CompletionTriggerKind.TriggerCharacter`
    let triggerCharacter: String?

    enum CodingKeys: String, CodingKey {
        case triggerKind
        case triggerCharacter
    }
}

/// How a completion was triggered.
public struct CompletionTriggerKind: RawRepresentable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let invoked = CompletionTriggerKind(rawValue: 1)
    static let triggerCharacter = CompletionTriggerKind(rawValue: 2)
    static let triggerForIncompleteCompletions = CompletionTriggerKind(rawValue: 3)
}

/// Represents a collection of [completion items](#CompletionItem) to be presented
/// in the editor.
public struct CompletionList: Codable {
    /// This list it not complete. Further typing should result in recomputing
    /// this list.
    let isIncomplete: Bool

    /// The completion items.
    let items: [CompletionItem]
}

public struct CompletionItem: Codable {
    /// The label of this completion item. By default
    /// also the text that is inserted when selecting
    /// this completion.
    let label: String

    /// Additional details for the label
    ///
    /// @since 3.17.0
    let labelDetails: CompletionItemLabelDetails?

    /// The kind of this completion item. Based of the kind
    /// an icon is chosen by the editor.
    let kind: CompletionItemKind?

    /// A human-readable string with additional information
    /// about this item, like type or symbol information.
    let detail: String?

    /// A human-readable string that represents a doc-comment.
    let documentation: Documentation?

    /// Indicates if this item is deprecated.
    let deprecated: Bool?

    /// Select this item when showing.
    let preselect: Bool?

    /// A string that should be used when comparing this item
    /// with other items. When `falsy` the label is used
    /// as the sort text for this item.
    let sortText: String?

    /// A string that should be used when filtering a set of
    /// completion items. When `falsy` the label is used as the
    /// filter text for this item.
    let filterText: String?

    /// A string that should be inserted into a document when selecting
    /// this completion. When `falsy` the label is used as the insert text
    /// for this item.
    ///
    /// The `insertText` is subject to interpretation by the client side.
    /// Some tools might not take the string literally. For example
    /// VS Code when code complete is requested in this example
    /// `con<cursor position>` and a completion item with an `insertText` of
    /// `console` is provided it will only insert `sole`. Therefore it is
    /// recommended to use `textEdit` instead since it avoids additional client
    /// side interpretation.
    let insertText: String?

    /// The format of the insert text. The format applies to both the `insertText` property
    /// and the `newText` property of a provided `textEdit`. If omitted defaults to `InsertTextFormat.PlainText`.
    ///
    /// @since 3.16.0
    let insertTextFormat: InsertTextFormat?

    /// How whitespace and indentation is handled during completion
    /// item insertion. If not provided the client's default value depends on
    /// the `textDocument.completion.insertTextMode` client capability.
    ///
    /// @since 3.16.0
    /// @since 3.17.0 - support for `textDocument.completion.insertTextMode`
    let insertTextMode: InsertTextMode?

    /// An edit which is applied to a document when selecting
    /// this completion. When an edit is provided the value of
    /// insertText is ignored.
    ///
    /// Most editors support two different operation when accepting a completion item. One is to insert a
    /// completion text and the other is to replace an existing text with a completion text. Since this can
    /// usually not predetermined by a server it can report both ranges. Clients need to signal support for
    /// `InsertReplaceEdits` via the `textDocument.completion.insertReplaceSupport` client capability
    /// property.
    ///
    /// *Note 1:* The text edit's range as well as both ranges from a insert replace edit must be a
    /// [single line] and they must contain the position at which completion has been requested.
    /// *Note 2:* If an `InsertReplaceEdit` is returned the edit's insert range must be a prefix of
    /// the edit's replace range, that means it must be contained and starting at the same position.
    ///
    /// @since 3.16.0 additional type `InsertReplaceEdit`
    let textEdit: CompletionTextEdit?

    /// An optional array of additional text edits that are applied when
    /// selecting this completion. Edits must not overlap with the main edit
    /// nor with themselves.
    let additionalTextEdits: [TextEdit]?

    /// An optional command that is executed *after* inserting this completion. *Note* that
    /// additional modifications to the current document should be described with the
    /// additionalTextEdits-property.
    let command: LSPCommand?

    /// An optional set of characters that when pressed while this completion is
    /// active will accept it first and then type that character. *Note* that all
    /// commit characters should have `length=1` and that superfluous characters
    /// will be ignored.
    let commitCharacters: [String]?

    /// An data entry field that is preserved on a completion item between
    /// a completion and a completion resolve request.
    let data: LSPAny?

    /// Tags for this completion item.
    let tags: [CompletionItemTag]?

    /// Create a CompletionItem with the minimum possible info (label and detail).
    init(label: String, detail: String) {
        self.label = label
        self.detail = detail
        self.labelDetails = nil
        self.kind = nil
        self.documentation = nil
        self.deprecated = nil
        self.preselect = nil
        self.sortText = nil
        self.filterText = nil
        self.insertText = nil
        self.insertTextFormat = nil
        self.insertTextMode = nil
        self.textEdit = nil
        self.additionalTextEdits = nil
        self.command = nil
        self.commitCharacters = nil
        self.data = nil
        self.tags = nil
    }
}

/// Additional details for a completion item label.
///
/// @since 3.17.0
public struct CompletionItemLabelDetails: Codable {
    /// An optional string which is rendered less prominently directly after
    /// {@link CompletionItemLabel.label label}, without any spacing. Should be
    /// used for function signatures or type annotations.
    let detail: String?

    /// An optional string which is rendered less prominently after
    /// {@link CompletionItemLabel.detail}. Should be used for fully qualified
    /// names or file path.
    let description: String?

    enum CodingKeys: String, CodingKey {
        case detail
        case description
    }
}
