//
//  LSP.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

// Large enough to contain any enumeration name defined in this crate
typealias PascalCaseBuf = [UInt8]

func fmtPascalCase(_ name: String) -> String {
    var result = ""
    for word in name.split(separator: "_") {
        let firstChar = word.first!
        result += String(firstChar)
        result += word.dropFirst().lowercased()
    }
    return result
}

enum LSPEnum {
    case unknown(Int)
}

extension LSPEnum: CustomStringConvertible {
    var description: String {
        switch self {
        case .unknown(let value):
            return "\(type(of: self))(\(value))"
        }
    }
}

extension LSPEnum: RawRepresentable {
    typealias RawValue = Int

    init?(rawValue: RawValue) {
        self = .unknown(rawValue)
    }

    var rawValue: RawValue {
        switch self {
        case .unknown(let value):
            return value
        }
    }
}

extension LSPEnum {
    init?(string: String) {
        let pascalCaseString = fmtPascalCase(string)
        switch pascalCaseString {
        default:
            return nil
        }
    }
}


/* ----------------- Cancel support ----------------- */

public struct CancelParams: Codable {
    /// The request id to cancel.
    let id: NumberOrString
}

/* ----------------- Basic JSON public structures ----------------- */

/// The LSP any type, since Swift can't encode/decode the `any` type
/// we create a codable with all common known swift types.
///
/// @since 3.17.0
public struct LSPAny: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let arrayValue = try? container.decode([LSPAny].self) {
            value = arrayValue.map { $0.value }
        } else if let dictValue = try? container.decode([String: LSPAny].self) {
            value = dictValue.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Cannot decode value")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let arrayValue as [Any]:
            try container.encode(arrayValue.map { LSPAny($0) })
        case let dictValue as [String: Any]:
            try container.encode(dictValue.mapValues { LSPAny($0) })
        default:
            throw EncodingError.invalidValue(value,
                                             EncodingError.Context(codingPath: [],
                                                                   debugDescription: "Cannot encode value"))
        }
    }
}
/// LSP object definition.
///
/// @since 3.17.0
typealias LSPObject = [String: LSPAny]

/// LSP arrays.
///
/// @since 3.17.0
typealias LSPArray = [LSPAny]

/// Position in a text document expressed as zero-based line and character offset.
/// A position is between two characters like an 'insert' cursor in a editor.
public struct LSPPosition: Codable, Hashable {
    /// Line position in a document (zero-based).
    let line: UInt32
    /// Character offset on a line in a document (zero-based). The meaning of this
    /// offset is determined by the negotiated `PositionEncodingKind`.
    ///
    /// If the character value is greater than the line length it defaults back
    /// to the line length.
    let character: UInt32

    init(line: UInt32, character: UInt32) {
        self.line = line
        self.character = character
    }
}

/// A range in a text document expressed as (zero-based) start and end positions.
/// A range is comparable to a selection in an editor. Therefore the end position is exclusive.
public struct LSPRange: Codable, Hashable {
    /// The range's start position.
    let start: LSPPosition
    /// The range's end position.
    let end: LSPPosition

    init(start: LSPPosition, end: LSPPosition) {
        self.start = start
        self.end = end
    }
}

/// Represents a location inside a resource, such as a line inside a text file.
public struct LSPLocation: Codable, Hashable {
    let uri: URL
    let range: LSPRange

    init(uri: URL, range: LSPRange) {
        self.uri = uri
        self.range = range
    }
}

/// Represents a link between a source and a target location.
public struct LocationLink: Codable {
    /// Span of the origin of this link.
    ///
    /// Used as the underlined span for mouse interaction. Defaults to the word range at
    /// the mouse position.
    let originSelectionRange: LSPRange?

    /// The target resource identifier of this link.
    let targetUri: URL

    /// The full target range of this link.
    let targetRange: LSPRange

    /// The span of this link.
    let targetSelectionRange: LSPRange

    enum CodingKeys: String, CodingKey {
        case originSelectionRange
        case targetUri
        case targetRange
        case targetSelectionRange
    }
}

/// A type indicating how positions are encoded,
/// specifically what column offsets mean.
///
/// @since 3.17.0
public struct PositionEncodingKind: Codable, Hashable, RawRepresentable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Character offsets count UTF-8 code units.
    static let utf8 = PositionEncodingKind(rawValue: "utf-8")

    /// Character offsets count UTF-16 code units.
    ///
    /// This is the default and must always be supported
    /// by servers
    static let utf16 = PositionEncodingKind(rawValue: "utf-16")

    /// Character offsets count UTF-32 code units.
    ///
    /// Implementation note: these are the same as Unicode code points,
    /// so this `PositionEncodingKind` may also be used for an
    /// encoding-agnostic representation of character offsets.
    static let utf32 = PositionEncodingKind(rawValue: "utf-32")
}

/// Represents a diagnostic, such as a compiler error or warning.
/// Diagnostic objects are only valid in the scope of a resource.
public struct Diagnostic: Codable {
    /// The range at which the message applies.
    let range: LSPRange

    /// The diagnostic's severity. Can be omitted. If omitted it is up to the
    /// client to interpret diagnostics as error, warning, info or hint.
    let severity: DiagnosticSeverity?

    /// The diagnostic's code. Can be omitted.
    let code: NumberOrString?

    /// An optional property to describe the error code.
    ///
    /// @since 3.16.0
    let codeDescription: CodeDescription?

    /// A human-readable string describing the source of this
    /// diagnostic, e.g. 'typescript' or 'super lint'.
    let source: String?

    /// The diagnostic's message.
    let message: String

    /// An array of related diagnostic information, e.g. when symbol-names within
    /// a scope collide all definitions can be marked via this property.
    let relatedInformation: [DiagnosticRelatedInformation]?

    /// Additional metadata about the diagnostic.
    let tags: [DiagnosticTag]?

    /// A data entry field that is preserved between a `textDocument/publishDiagnostics`
    /// notification and `textDocument/codeAction` request.
    ///
    /// @since 3.16.0
    let data: LSPAny?

    enum CodingKeys: String, CodingKey {
        case range
        case severity
        case code
        case codeDescription
        case source
        case message
        case relatedInformation
        case tags
        case data
    }

    public init(range: LSPRange,
         severity: DiagnosticSeverity?,
         code: NumberOrString?,
         source: String?,
         message: String,
         relatedInformation: [DiagnosticRelatedInformation]?,
         tags: [DiagnosticTag]?) {
        self.range = range
        self.severity = severity
        self.code = code
        self.codeDescription = nil
        self.source = source
        self.message = message
        self.relatedInformation = relatedInformation
        self.tags = tags
        self.data = nil
    }

    public init(range: LSPRange,
                message: String) {
        self.init(range: range,
                  severity: nil,
                  code: nil,
                  source: nil,
                  message: message,
                  relatedInformation: nil,
                  tags: nil)
    }

    public init(range: LSPRange,
         severity: DiagnosticSeverity,
         codeNumber: Int32,
         source: String?,
         message: String) {
        self.init(range: range,
                  severity: severity,
                  code: .number(Double(codeNumber)),
                  source: source,
                  message: message,
                  relatedInformation: nil,
                  tags: nil)
    }
}

public struct CodeDescription: Codable {
    let href: URL
}

/// The protocol currently supports the following diagnostic severities:
public struct DiagnosticSeverity: RawRepresentable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Reports an error.
    static let error = DiagnosticSeverity(rawValue: 1)
    /// Reports a warning.
    static let warning = DiagnosticSeverity(rawValue: 2)
    /// Reports an information.
    static let information = DiagnosticSeverity(rawValue: 3)
    /// Reports a hint.
    static let hint = DiagnosticSeverity(rawValue: 4)
}

/// Represents a related message and source code location for a diagnostic. This
/// should be used to point to code locations that cause or related to a
/// diagnostics, e.g when duplicating a symbol in a scope.
public struct DiagnosticRelatedInformation: Codable {
    /// The location of this related diagnostic information.
    let location: LSPLocation

    /// The message of this related diagnostic information.
    let message: String
}

/// The diagnostic tags.
public struct DiagnosticTag: RawRepresentable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Unused or unnecessary code.
    /// Clients are allowed to render diagnostics with this tag faded out instead of having
    /// an error squiggle.
    static let unnecessary = DiagnosticTag(rawValue: 1)

    /// Deprecated or obsolete code.
    /// Clients are allowed to rendered diagnostics with this tag strike through.
    static let deprecated = DiagnosticTag(rawValue: 2)
}

/// Represents a reference to a command. Provides a title which will be used to represent a command in the UI.
/// Commands are identified by a string identifier. The recommended way to handle commands is to implement
/// their execution on the server side if the client and server provides the corresponding capabilities.
/// Alternatively the tool extension code could handle the command.
/// The protocol currently doesn't specify a set of well-known commands.
public struct LSPCommand: Codable {
    /// Title of the command, like `save`.
    let title: String
    /// The identifier of the actual command handler.
    let command: String
    /// Arguments that the command handler should be
    /// invoked with.
    let arguments: [LSPAny]?

    init(title: String, command: String, arguments: [LSPAny]?) {
        self.title = title
        self.command = command
        self.arguments = arguments
    }

    enum CodingKeys: String, CodingKey {
        case title
        case command
        case arguments
    }
}

/// A textual edit applicable to a text document.
///
/// If n `TextEdit`s are applied to a text document all text edits describe changes to the initial document version.
/// Execution wise text edits should applied from the bottom to the top of the text document. Overlapping text edits
/// are not supported.
public struct TextEdit: Codable {
    /// The range of the text document to be manipulated. To insert
    /// text into a document create a range where start === end.
    let range: LSPRange
    /// The string to be inserted. For delete operations use an
    /// empty string.
    let newText: String

    init(range: LSPRange, newText: String) {
        self.range = range
        self.newText = newText
    }

    enum CodingKeys: String, CodingKey {
        case range
        case newText
    }
}

/// An identifier referring to a change annotation managed by a workspace
/// edit.
///
/// @since 3.16.0
typealias ChangeAnnotationIdentifier = String

/// A special text edit with an additional change annotation.
///
/// @since 3.16.0
public struct AnnotatedTextEdit: Codable {
    let textEdit: TextEdit

    /// The actual annotation
    let annotationId: ChangeAnnotationIdentifier

    enum CodingKeys: String, CodingKey {
        case textEdit
        case annotationId
    }
}

/// Describes textual changes on a single text document. The text document is referred to as a
/// `OptionalVersionedTextDocumentIdentifier` to allow clients to check the text document version before an
/// edit is applied. A `TextDocumentEdit` describes all changes on a version Si and after they are
/// applied move the document to version Si+1. So the creator of a `TextDocumentEdit` doesn't need to
/// sort the array or do any kind of ordering. However the edits must be non overlapping.
public struct TextDocumentEdit: Codable {
    /// The text document to change.
    let textDocument: OptionalVersionedTextDocumentIdentifier

    /// The edits to be applied.
    ///
    /// @since 3.16.0 - support for AnnotatedTextEdit. This is guarded by the
    /// client capability `workspace.workspaceEdit.changeAnnotationSupport`
    let edits: [TextEdit]

    enum CodingKeys: String, CodingKey {
        case textDocument
        case edits
    }
}

/// Additional information that describes document changes.
///
/// @since 3.16.0
public struct ChangeAnnotation: Codable {
    /// A human-readable string describing the actual change. The string
    /// is rendered prominent in the user interface.
    let label: String

    /// A flag which indicates that user confirmation is needed
    /// before applying the change.
    let needsConfirmation: Bool?

    /// A human-readable string which is rendered less prominent in
    /// the user interface.
    let description: String?

    enum CodingKeys: String, CodingKey {
        case label
        case needsConfirmation
        case description
    }
}

public struct ChangeAnnotationWorkspaceEditClientCapabilities: Codable {
    /// Whether the client groups edits with equal labels into tree nodes,
    /// for instance all edits labelled with "Changes in Strings" would
    /// be a tree node.
    let groupsOnLabel: Bool?

    enum CodingKeys: String, CodingKey {
        case groupsOnLabel
    }
}

/// Options to create a file.
public struct CreateFileOptions: Codable {
    /// Overwrite existing file. Overwrite wins over `ignoreIfExists`
    let overwrite: Bool?
    /// Ignore if exists.
    let ignoreIfExists: Bool?

    enum CodingKeys: String, CodingKey {
        case overwrite
        case ignoreIfExists
    }
}

/// Create file operation
public struct CreateFile: Codable {
    /// The resource to create.
    let uri: URL
    /// Additional options
    let options: CreateFileOptions?

    /// An optional annotation identifier describing the operation.
    ///
    /// @since 3.16.0
    let annotationId: ChangeAnnotationIdentifier?

    enum CodingKeys: String, CodingKey {
        case uri
        case options
        case annotationId
    }
}

/// Rename file options
public struct RenameFileOptions: Codable {
    /// Overwrite target if existing. Overwrite wins over `ignoreIfExists`
    let overwrite: Bool?
    /// Ignores if target exists.
    let ignoreIfExists: Bool?

    enum CodingKeys: String, CodingKey {
        case overwrite
        case ignoreIfExists
    }
}

/// Rename file operation
public struct RenameFile: Codable {
    /// The old (existing) location.
    let oldUri: URL
    /// The new location.
    let newUri: URL
    /// Rename options.
    let options: RenameFileOptions?

    /// An optional annotation identifier describing the operation.
    ///
    /// @since 3.16.0
    let annotationId: ChangeAnnotationIdentifier?

    enum CodingKeys: String, CodingKey {
        case oldUri
        case newUri
        case options
        case annotationId
    }
}

/// Delete file options
public struct DeleteFileOptions: Codable {
    /// Delete the content recursively if a folder is denoted.
    let recursive: Bool?
    /// Ignore the operation if the file doesn't exist.
    let ignoreIfNotExists: Bool?

    /// An optional annotation identifier describing the operation.
    ///
    /// @since 3.16.0
    let annotationId: ChangeAnnotationIdentifier?

    enum CodingKeys: String, CodingKey {
        case recursive
        case ignoreIfNotExists
        case annotationId
    }
}

/// Delete file operation
public struct DeleteFile: Codable {
    /// The file to delete.
    let uri: URL
    /// Delete options.
    let options: DeleteFileOptions?

    enum CodingKeys: String, CodingKey {
        case uri
        case options
    }
}

/// A workspace edit represents changes to many resources managed in the workspace.
/// The edit should either provide `changes` or `documentChanges`.
/// If the client can handle versioned document edits and if `documentChanges` are present,
/// the latter are preferred over `changes`.
public struct WorkspaceEdit: Codable {
    /// Holds changes to existing resources.
    var changes: [URL: [TextEdit]]?

    /// Depending on the client capability `workspace.workspaceEdit.resourceOperations` document changes
    /// are either an array of `TextDocumentEdit`s to express changes to n different text documents
    /// where each text document edit addresses a specific version of a text document. Or it can contain
    /// above `TextDocumentEdit`s mixed with create, rename and delete file / folder operations.
    ///
    /// Whether a client supports versioned document edits is expressed via
    /// `workspace.workspaceEdit.documentChanges` client capability.
    ///
    /// If a client neither supports `documentChanges` nor `workspace.workspaceEdit.resourceOperations` then
    /// only plain `TextEdit`s using the `changes` property are supported.
    var documentChanges: DocumentChanges?

    /// A map of change annotations that can be referenced in
    /// `AnnotatedTextEdit`s or create, rename and delete file / folder
    /// operations.
    ///
    /// Whether clients honor this property depends on the client capability
    /// `workspace.changeAnnotationSupport`.
    ///
    /// @since 3.16.0
    var changeAnnotations: [ChangeAnnotationIdentifier: ChangeAnnotation]?

    enum CodingKeys: String, CodingKey {
        case changes
        case documentChanges
        case changeAnnotations
    }

    init(changes: [URL: [TextEdit]]? = nil, documentChanges: DocumentChanges? = nil, changeAnnotations: [ChangeAnnotationIdentifier: ChangeAnnotation]? = nil) {
        self.changes = changes
        self.documentChanges = documentChanges
        self.changeAnnotations = changeAnnotations
    }
}

enum DocumentChanges: Codable {
    case edits([TextDocumentEdit])
    case operations([DocumentChangeOperation])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let edits = try? container.decode([TextDocumentEdit].self) {
            self = .edits(edits)
        } else if let operations = try? container.decode([DocumentChangeOperation].self) {
            self = .operations(operations)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid DocumentChanges")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .edits(let edits):
            try container.encode(edits)
        case .operations(let operations):
            try container.encode(operations)
        }
    }
}

enum DocumentChangeOperation: Codable {
    case op(ResourceOp)
    case edit(TextDocumentEdit)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let op = try? container.decode(ResourceOp.self) {
            self = .op(op)
        } else if let edit = try? container.decode(TextDocumentEdit.self) {
            self = .edit(edit)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid DocumentChangeOperation")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .op(let op):
            try container.encode(op)
        case .edit(let edit):
            try container.encode(edit)
        }
    }
}

enum ResourceOp: Codable {
    case create(CreateFile)
    case rename(RenameFile)
    case delete(DeleteFile)

    enum CodingKeys: String, CodingKey {
        case kind
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(String.self, forKey: .kind)

        switch kind.lowercased() {
        case "create":
            let create = try CreateFile(from: decoder)
            self = .create(create)
        case "rename":
            let rename = try RenameFile(from: decoder)
            self = .rename(rename)
        case "delete":
            let delete = try DeleteFile(from: decoder)
            self = .delete(delete)
        default:
            throw DecodingError.dataCorruptedError(forKey: .kind, in: container, debugDescription: "Invalid ResourceOp kind")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .create(let create):
            try container.encode("create", forKey: .kind)
            try create.encode(to: encoder)
        case .rename(let rename):
            try container.encode("rename", forKey: .kind)
            try rename.encode(to: encoder)
        case .delete(let delete):
            try container.encode("delete", forKey: .kind)
            try delete.encode(to: encoder)
        }
    }
}

typealias DidChangeConfigurationClientCapabilities = DynamicRegistrationClientCapabilities

public struct ConfigurationParams: Codable {
    let items: [ConfigurationItem]
}

public struct ConfigurationItem: Codable {
    /// The scope to get the configuration section for.
    let scopeUri: URL?

    ///The configuration section asked for.
    let section: String?

    enum CodingKeys: String, CodingKey {
        case scopeUri
        case section
    }
}

/// Text documents are identified using a URI. On the protocol level, URIs are passed as strings.
public struct TextDocumentIdentifier: Codable {
    /// The text document's URI.
    let uri: URL

    init(uri: URL) {
        self.uri = uri
    }
}

/// An item to transfer a text document from the client to the server.
public struct TextDocumentItem: Codable {
    /// The text document's URI.
    let uri: URL

    /// The text document's language identifier.
    let languageId: String

    /// The version number of this document (it will strictly increase after each
    /// change, including undo/redo).
    let version: Int

    /// The content of the opened text document.
    let text: String

    init(uri: URL, languageId: String, version: Int, text: String) {
        self.uri = uri
        self.languageId = languageId
        self.version = version
        self.text = text
    }

    enum CodingKeys: String, CodingKey {
        case uri
        case languageId
        case version
        case text
    }
}

/// An identifier to denote a specific version of a text document. This information usually flows from the client to the server.
public struct VersionedTextDocumentIdentifier: Codable {
    /// The text document's URI.
    let uri: URL

    /// The version number of this document.
    ///
    /// The version number of a document will increase after each change,
    /// including undo/redo. The number doesn't need to be consecutive.
    let version: Int

    init(uri: URL, version: Int) {
        self.uri = uri
        self.version = version
    }
}

/// An identifier which optionally denotes a specific version of a text document. This information usually flows from the server to the client.
public struct OptionalVersionedTextDocumentIdentifier: Codable {
    /// The text document's URI.
    let uri: URL

    /// The version number of this document. If an optional versioned text document
    /// identifier is sent from the server to the client and the file is not
    /// open in the editor (the server has not received an open notification
    /// before) the server can send `null` to indicate that the version is
    /// known and the content on disk is the master (as specified with document
    /// content ownership).
    ///
    /// The version number of a document will increase after each change,
    /// including undo/redo. The number doesn't need to be consecutive.
    let version: Int?

    init(uri: URL, version: Int) {
        self.uri = uri
        self.version = version
    }
}

/// A parameter literal used in requests to pass a text document and a position inside that document.
public struct TextDocumentPositionParams: Codable {
    /// The text document.
    let textDocument: TextDocumentIdentifier

    /// The position inside the text document.
    let position: LSPPosition

    init(textDocument: TextDocumentIdentifier,
         position: LSPPosition) {
        self.textDocument = textDocument
        self.position = position
    }
}

/// A document filter denotes a document through properties like language, schema or pattern.
/// Examples are a filter that applies to TypeScript files on disk or a filter the applies to JSON
/// files with name package.json:
///
/// { language: 'typescript', scheme: 'file' }
/// { language: 'json', pattern: '**/package.json' }
public struct DocumentFilter: Codable {
    /// A language id, like `typescript`.
    let language: String?

    /// A Uri [scheme](#Uri.scheme), like `file` or `untitled`.
    let scheme: String?

    /// A glob pattern, like `*.{ts,js}`.
    let pattern: String?

    enum CodingKeys: String, CodingKey {
        case language
        case scheme
        case pattern
    }
}

/// A document selector is the combination of one or many document filters.
typealias DocumentSelector = [DocumentFilter]

// ========================= Actual Protocol =========================

public struct InitializeParams: Codable {
    /// The process Id of the parent process that started
    /// the server. Is null if the process has not been started by another process.
    /// If the parent process is not alive then the server should exit (see exit notification) its process.
    let processId: UInt32?

    /// The rootPath of the workspace. Is null
    /// if no folder is open.
    @available(*, deprecated, message: "Use `rootUri` instead when possible")
    let rootPath: String?

    /// The rootUri of the workspace. Is null if no
    /// folder is open. If both `rootPath` and `rootUri` are set
    /// `rootUri` wins.
    @available(*, deprecated, message: "Use `workspaceFolders` instead when possible")
    let rootUri: String?

    /// User provided initialization options.
    let initializationOptions: LSPAny?

    /// The capabilities provided by the client (editor or tool)
    let capabilities: ClientCapabilities

    /// The initial trace setting. If omitted trace is disabled ('off').
    let trace: TraceValue?

    /// The workspace folders configured in the client when the server starts.
    /// This property is only available if the client supports workspace folders.
    /// It can be `null` if the client supports workspace folders but none are
    /// configured.
    let workspaceFolders: [WorkspaceFolder]?

    /// Information about the client.
    let clientInfo: ClientInfo?

    /// The locale the client is currently showing the user interface
    /// in. This must not necessarily be the locale of the operating
    /// system.
    ///
    /// Uses IETF language tags as the value's syntax
    /// (See <https://en.wikipedia.org/wiki/IETF_language_tag>)
    ///
    /// @since 3.16.0
    let locale: String?

    /// The LSP server may report about initialization progress to the client
    /// by using the following work done token if it was passed by the client.
    let workDoneProgressParams: WorkDoneProgressParams

    enum CodingKeys: String, CodingKey {
        case processId
        case rootPath
        case rootUri
        case initializationOptions
        case capabilities
        case trace
        case workspaceFolders
        case clientInfo
        case locale
        case workDoneProgressParams
    }
}

public struct ClientInfo: Codable {
    /// The name of the client as defined by the client.
    let name: String
    /// The client's version as defined by the client.
    let version: String?
}

public struct InitializedParams: Codable {}

public struct GenericRegistrationOptions: Codable {
    let textDocumentRegistrationOptions: TextDocumentRegistrationOptions
    let options: GenericOptions
    let staticRegistrationOptions: StaticRegistrationOptions
}

public struct GenericOptions: Codable {
    let workDoneProgressOptions: WorkDoneProgressOptions
}

public struct GenericParams: Codable {
    let textDocumentPositionParams: TextDocumentPositionParams
    let workDoneProgressParams: WorkDoneProgressParams
    let partialResultParams: PartialResultParams
}

public struct DynamicRegistrationClientCapabilities: Codable {
    /// This capability supports dynamic registration.
    let dynamicRegistration: Bool?
}

public struct GotoCapability: Codable {
    let dynamicRegistration: Bool?

    /// The client supports additional metadata in the form of definition links.
    let linkSupport: Bool?
}

public struct WorkspaceEditClientCapabilities: Codable {
    /// The client supports versioned document changes in `WorkspaceEdit`s
    let documentChanges: Bool?

    /// The resource operations the client supports. Clients should at least
    /// support 'create', 'rename' and 'delete' files and folders.
    let resourceOperations: [ResourceOperationKind]?

    /// The failure handling strategy of a client if applying the workspace edit fails.
    let failureHandling: FailureHandlingKind?

    /// Whether the client normalizes line endings to the client specific
    /// setting.
    /// If set to `true` the client will normalize line ending characters
    /// in a workspace edit to the client specific new line character(s).
    ///
    /// @since 3.16.0
    let normalizesLineEndings: Bool?

    /// Whether the client in general supports change annotations on text edits,
    /// create file, rename file and delete file changes.
    ///
    /// @since 3.16.0
    let changeAnnotationSupport: ChangeAnnotationWorkspaceEditClientCapabilities?

    enum CodingKeys: String, CodingKey {
        case documentChanges
        case resourceOperations
        case failureHandling
        case normalizesLineEndings
        case changeAnnotationSupport
    }
}

enum ResourceOperationKind: String, Codable {
    case create
    case rename
    case delete
}

enum FailureHandlingKind: String, Codable {
    case abort
    case transactional
    case textOnlyTransactional
    case undo
}

/// A symbol kind.
public struct SymbolKind: RawRepresentable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let file = SymbolKind(rawValue: 1)
    static let module = SymbolKind(rawValue: 2)
    static let namespace = SymbolKind(rawValue: 3)
    static let package = SymbolKind(rawValue: 4)
    static let `class` = SymbolKind(rawValue: 5)
    static let method = SymbolKind(rawValue: 6)
    static let property = SymbolKind(rawValue: 7)
    static let field = SymbolKind(rawValue: 8)
    static let constructor = SymbolKind(rawValue: 9)
    static let `enum` = SymbolKind(rawValue: 10)
    static let `interface` = SymbolKind(rawValue: 11)
    static let function = SymbolKind(rawValue: 12)
    static let variable = SymbolKind(rawValue: 13)
    static let constant = SymbolKind(rawValue: 14)
    static let string = SymbolKind(rawValue: 15)
    static let number = SymbolKind(rawValue: 16)
    static let boolean = SymbolKind(rawValue: 17)
    static let array = SymbolKind(rawValue: 18)
    static let object = SymbolKind(rawValue: 19)
    static let key = SymbolKind(rawValue: 20)
    static let null = SymbolKind(rawValue: 21)
    static let enumMember = SymbolKind(rawValue: 22)
    static let `struct` = SymbolKind(rawValue: 23)
    static let event = SymbolKind(rawValue: 24)
    static let `operator` = SymbolKind(rawValue: 25)
    static let typeParameter = SymbolKind(rawValue: 26)
}

/// Specific capabilities for the `SymbolKind` in the `workspace/symbol` request.
public struct SymbolKindCapability: Codable {
    /// The symbol kind values the client supports. When this
    /// property exists the client also guarantees that it will
    /// handle values outside its set gracefully and falls back
    /// to a default value when unknown.
    ///
    /// If this property is not present the client only supports
    /// the symbol kinds from `File` to `Array` as defined in
    /// the initial version of the protocol.
    let valueSet: [SymbolKind]?

    enum CodingKeys: String, CodingKey {
        case valueSet
    }
}

/// Workspace specific client capabilities.
public struct WorkspaceClientCapabilities: Codable {
    /// The client supports applying batch edits to the workspace by supporting
    /// the request 'workspace/applyEdit'
    let applyEdit: Bool?

    /// Capabilities specific to `WorkspaceEdit`s
    let workspaceEdit: WorkspaceEditClientCapabilities?

    /// Capabilities specific to the `workspace/didChangeConfiguration` notification.
    let didChangeConfiguration: DidChangeConfigurationClientCapabilities?

    /// Capabilities specific to the `workspace/didChangeWatchedFiles` notification.
    let didChangeWatchedFiles: DidChangeWatchedFilesClientCapabilities?

    /// Capabilities specific to the `workspace/symbol` request.
    let symbol: WorkspaceSymbolClientCapabilities?

    /// Capabilities specific to the `workspace/executeCommand` request.
    let executeCommand: ExecuteCommandClientCapabilities?

    /// The client has support for workspace folders.
    ///
    /// @since 3.6.0
    let workspaceFolders: Bool?

    /// The client supports `workspace/configuration` requests.
    ///
    /// @since 3.6.0
    let configuration: Bool?

    /// Capabilities specific to the semantic token requests scoped to the workspace.
    ///
    /// @since 3.16.0
    let semanticTokens: SemanticTokensWorkspaceClientCapabilities?

    /// Capabilities specific to the code lens requests scoped to the workspace.
    ///
    /// @since 3.16.0
    let codeLens: CodeLensWorkspaceClientCapabilities?

    /// The client has support for file requests/notifications.
    ///
    /// @since 3.16.0
    let fileOperations: WorkspaceFileOperationsClientCapabilities?

    /// Client workspace capabilities specific to inline values.
    ///
    /// @since 3.17.0
    let inlineValue: InlineValueWorkspaceClientCapabilities?

    /// Client workspace capabilities specific to inlay hints.
    ///
    /// @since 3.17.0
    let inlayHint: InlayHintWorkspaceClientCapabilities?

    /// Client workspace capabilities specific to diagnostics.
    /// since 3.17.0
    let diagnostic: DiagnosticWorkspaceClientCapabilities?

    enum CodingKeys: String, CodingKey {
        case applyEdit
        case workspaceEdit
        case didChangeConfiguration
        case didChangeWatchedFiles
        case symbol
        case executeCommand
        case workspaceFolders
        case configuration
        case semanticTokens
        case codeLens
        case fileOperations
        case inlineValue
        case inlayHint
        case diagnostic
    }
}

public struct TextDocumentSyncClientCapabilities: Codable {
    /// Whether text document synchronization supports dynamic registration.
    let dynamicRegistration: Bool?

    /// The client supports sending will save notifications.
    let willSave: Bool?

    /// The client supports sending a will save request and
    /// waits for a response providing text edits which will
    /// be applied to the document before it is saved.
    let willSaveWaitUntil: Bool?

    /// The client supports did save notifications.
    let didSave: Bool?

    enum CodingKeys: String, CodingKey {
        case dynamicRegistration
        case willSave
        case willSaveWaitUntil
        case didSave
    }
}

public struct PublishDiagnosticsClientCapabilities: Codable {
    /// Whether the clients accepts diagnostics with related information.
    let relatedInformation: Bool?

    /// Client supports the tag property to provide meta data about a diagnostic.
    /// Clients supporting tags have to handle unknown tags gracefully.
    let tagSupport: TagSupport<DiagnosticTag>?

    /// Whether the client interprets the version property of the
    /// `textDocument/publishDiagnostics` notification's parameter.
    ///
    /// @since 3.15.0
    let versionSupport: Bool?

    /// Client supports a codeDescription property
    ///
    /// @since 3.16.0
    let codeDescriptionSupport: Bool?

    /// Whether code action supports the `data` property which is
    /// preserved between a `textDocument/publishDiagnostics` and
    /// `textDocument/codeAction` request.
    ///
    /// @since 3.16.0
    let dataSupport: Bool?

    enum CodingKeys: String, CodingKey {
        case relatedInformation
        case tagSupport
        case versionSupport
        case codeDescriptionSupport
        case dataSupport
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        relatedInformation = try container.decodeIfPresent(Bool.self, forKey: .relatedInformation)
        tagSupport = try TagSupport<DiagnosticTag>.decodeCompatible(from: container, forKey: CodingKeys.tagSupport)
        versionSupport = try container.decodeIfPresent(Bool.self, forKey: .versionSupport)
        codeDescriptionSupport = try container.decodeIfPresent(Bool.self, forKey: .codeDescriptionSupport)
        dataSupport = try container.decodeIfPresent(Bool.self, forKey: .dataSupport)
    }
}

public struct TagSupport<T>: Codable where T: Codable {
    /// The tags supported by the client.
    let valueSet: [T]

    enum CodingKeys: String, CodingKey {
        case valueSet
    }

    /// Support for deserializing a boolean tag Support, in case it's present.
    ///
    /// This is currently the case for vscode 1.41.1
    static func decodeCompatible<Keys: CodingKey>(from container: KeyedDecodingContainer<Keys>, forKey key: Keys) throws -> TagSupport<T>? {
        if let value = try container.decodeIfPresent(Bool.self, forKey: key) {
            return value ? TagSupport(valueSet: []) : nil
        } else if let tagSupport = try container.decodeIfPresent(TagSupport<T>.self, forKey: key) {
            return tagSupport
        } else {
            return nil
        }
    }
}

/// Text document specific client capabilities.
public struct TextDocumentClientCapabilities: Codable {
    let synchronization: TextDocumentSyncClientCapabilities?
    /// Capabilities specific to the `textDocument/completion`
    let completion: CompletionClientCapabilities?

    /// Capabilities specific to the `textDocument/hover`
    let hover: HoverClientCapabilities?

    /// Capabilities specific to the `textDocument/signatureHelp`
    let signatureHelp: SignatureHelpClientCapabilities?

    /// Capabilities specific to the `textDocument/references`
    let references: ReferenceClientCapabilities?

    /// Capabilities specific to the `textDocument/documentHighlight`
    let documentHighlight: DocumentHighlightClientCapabilities?

    /// Capabilities specific to the `textDocument/documentSymbol`
    let documentSymbol: DocumentSymbolClientCapabilities?

    /// Capabilities specific to the `textDocument/formatting`
    let formatting: DocumentFormattingClientCapabilities?

    /// Capabilities specific to the `textDocument/rangeFormatting`
    let rangeFormatting: DocumentRangeFormattingClientCapabilities?

    /// Capabilities specific to the `textDocument/onTypeFormatting`
    let onTypeFormatting: DocumentOnTypeFormattingClientCapabilities?

    /// Capabilities specific to the `textDocument/declaration`
    let declaration: GotoCapability?

    /// Capabilities specific to the `textDocument/definition`
    let definition: GotoCapability?

    /// Capabilities specific to the `textDocument/typeDefinition`
    let typeDefinition: GotoCapability?

    /// Capabilities specific to the `textDocument/implementation`
    let implementation: GotoCapability?

    /// Capabilities specific to the `textDocument/codeAction`
    let codeAction: CodeActionClientCapabilities?

    /// Capabilities specific to the `textDocument/codeLens`
    let codeLens: CodeLensClientCapabilities?

    /// Capabilities specific to the `textDocument/documentLink`
    let documentLink: DocumentLinkClientCapabilities?

    /// Capabilities specific to the `textDocument/documentColor` and the
    /// `textDocument/colorPresentation` request.
    let colorProvider: DocumentColorClientCapabilities?

    /// Capabilities specific to the `textDocument/rename`
    let rename: RenameClientCapabilities?

    /// Capabilities specific to `textDocument/publishDiagnostics`.
    let publishDiagnostics: PublishDiagnosticsClientCapabilities?

    /// Capabilities specific to `textDocument/foldingRange` requests.
    let foldingRange: FoldingRangeClientCapabilities?

    /// Capabilities specific to the `textDocument/selectionRange` request.
    ///
    /// @since 3.15.0
    let selectionRange: SelectionRangeClientCapabilities?

    /// Capabilities specific to `textDocument/linkedEditingRange` requests.
    ///
    /// @since 3.16.0
    let linkedEditingRange: LinkedEditingRangeClientCapabilities?

    /// Capabilities specific to the various call hierarchy requests.
    ///
    /// @since 3.16.0
    let callHierarchy: CallHierarchyClientCapabilities?

    /// Capabilities specific to the `textDocument/semanticTokens/*` requests.
    let semanticTokens: SemanticTokensClientCapabilities?

    /// Capabilities specific to the `textDocument/moniker` request.
    ///
    /// @since 3.16.0
    let moniker: MonikerClientCapabilities?

    /// Capabilities specific to the various type hierarchy requests.
    ///
    /// @since 3.17.0
    let typeHierarchy: TypeHierarchyClientCapabilities?

    /// Capabilities specific to the `textDocument/inlineValue` request.
    ///
    /// @since 3.17.0
    let inlineValue: InlineValueClientCapabilities?

    /// Capabilities specific to the `textDocument/inlayHint` request.
    ///
    /// @since 3.17.0
    let inlayHint: InlayHintClientCapabilities?

    /// Capabilities specific to the diagnostic pull model.
    ///
    /// @since 3.17.0
    let diagnostic: DiagnosticClientCapabilities?

    /// Capabilities specific to the `textDocument/inlineCompletion` request.
    ///
    /// @since 3.18.0
#if LSP_PROPOSED
    let inlineCompletion: InlineCompletionClientCapabilities?
#endif

    enum CodingKeys: String, CodingKey {
        case synchronization
        case completion
        case hover
        case signatureHelp
        case references
        case documentHighlight
        case documentSymbol
        case formatting
        case rangeFormatting
        case onTypeFormatting
        case declaration
        case definition
        case typeDefinition
        case implementation
        case codeAction
        case codeLens
        case documentLink
        case colorProvider
        case rename
        case publishDiagnostics
        case foldingRange
        case selectionRange
        case linkedEditingRange
        case callHierarchy
        case semanticTokens
        case moniker
        case typeHierarchy
        case inlineValue
        case inlayHint
        case diagnostic
#if LSP_PROPOSED
        case inlineCompletion
#endif
    }
}

/// Where ClientCapabilities are currently empty:
public struct ClientCapabilities: Codable {
    /// Workspace specific client capabilities.
    let workspace: WorkspaceClientCapabilities?

    /// Text document specific client capabilities.
    let textDocument: TextDocumentClientCapabilities?

    /// Window specific client capabilities.
    let window: WindowClientCapabilities?

    /// General client capabilities.
    let general: GeneralClientCapabilities?

    /// Unofficial UT8-offsets extension.
    ///
    /// See https://clangd.llvm.org/extensions.html#utf-8-offsets.
#if LSP_PROPOSED
    let offsetEncoding: [String]?
#endif

    /// Experimental client capabilities.
    let experimental: LSPAny?

    enum CodingKeys: String, CodingKey {
        case workspace
        case textDocument
        case window
        case general
#if LSP_PROPOSED
        case offsetEncoding
#endif
        case experimental
    }
}

public struct GeneralClientCapabilities: Codable {
    /// Client capabilities specific to regular expressions.
    ///
    /// @since 3.16.0
    let regularExpressions: RegularExpressionsClientCapabilities?

    /// Client capabilities specific to the client's markdown parser.
    ///
    /// @since 3.16.0
    let markdown: MarkdownClientCapabilities?

    /// Client capability that signals how the client handles stale requests (e.g. a request for
    /// which the client will not process the response anymore since the information is outdated).
    ///
    /// @since 3.17.0
    let staleRequestSupport: StaleRequestSupportClientCapabilities?

    /// The position encodings supported by the client. Client and server
    /// have to agree on the same position encoding to ensure that offsets
    /// (e.g. character position in a line) are interpreted the same on both
    /// side.
    ///
    /// To keep the protocol backwards compatible the following applies: if
    /// the value 'utf-16' is missing from the array of position encodings
    /// servers can assume that the client supports UTF-16. UTF-16 is
    /// therefore a mandatory encoding.
    ///
    /// If omitted it defaults to ['utf-16'].
    ///
    /// Implementation considerations: since the conversion from one encoding
    /// into another requires the content of the file / line the conversion
    /// is best done where the file is read which is usually on the server
    /// side.
    ///
    /// @since 3.17.0
    let positionEncodings: [PositionEncodingKind]?

    enum CodingKeys: String, CodingKey {
        case regularExpressions
        case markdown
        case staleRequestSupport
        case positionEncodings
    }
}

/// Client capability that signals how the client
/// handles stale requests (e.g. a request
/// for which the client will not process the response
/// anymore since the information is outdated).
///
/// @since 3.17.0
public struct StaleRequestSupportClientCapabilities: Codable {
    /// The client will actively cancel the request.
    let cancel: Bool

    /// The list of requests for which the client
    /// will retry the request if it receives a
    /// response with error code `ContentModified``
    let retryOnContentModified: [String]
}

public struct RegularExpressionsClientCapabilities: Codable {
    /// The engine's name.
    let engine: String

    /// The engine's version
    let version: String?
}

public struct MarkdownClientCapabilities: Codable {
    /// The name of the parser.
    let parser: String

    /// The version of the parser.
    let version: String?

    /// A list of HTML tags that the client allows / supports in
    /// Markdown.
    ///
    /// @since 3.17.0
    let allowedTags: [String]?

    enum CodingKeys: String, CodingKey {
        case parser
        case version
        case allowedTags
    }
}

public struct InitializeResult: Codable {
    /// The capabilities the language server provides.
    let capabilities: ServerCapabilities

    /// Information about the server.
    let serverInfo: ServerInfo?

    /// Unofficial UT8-offsets extension.
    ///
    /// See https://clangd.llvm.org/extensions.html#utf-8-offsets.
#if LSP_PROPOSED
    let offsetEncoding: String?
#endif

    enum CodingKeys: String, CodingKey {
        case capabilities
        case serverInfo
#if LSP_PROPOSED
        case offsetEncoding
#endif
    }
}

public struct ServerInfo: Codable {
    /// The name of the server as defined by the server.
    let name: String

    /// The servers's version as defined by the server.
    let version: String?
}

public struct InitializeError: Codable {
    /// Indicates whether the client execute the following retry logic:
    ///
    /// - (1) show the message provided by the ResponseError to the user
    /// - (2) user selects retry or cancel
    /// - (3) if user selected retry the initialize method is sent again.
    let retry: Bool
}

// The server can signal the following capabilities:

/// Defines how the host (editor) should sync document changes to the language server.
public struct TextDocumentSyncKind: RawRepresentable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Documents should not be synced at all.
    static let none = TextDocumentSyncKind(rawValue: 0)

    /// Documents are synced by always sending the full content of the document.
    static let full = TextDocumentSyncKind(rawValue: 1)

    /// Documents are synced by sending the full content on open. After that only
    /// incremental updates to the document are sent.
    static let incremental = TextDocumentSyncKind(rawValue: 2)
}

typealias ExecuteCommandClientCapabilities = DynamicRegistrationClientCapabilities

/// Execute command options.
public struct ExecuteCommandOptions: Codable {
    /// The commands to be executed on the server
    let commands: [String]

    let workDoneProgressOptions: WorkDoneProgressOptions
}

/// Save options.
public struct SaveOptions: Codable {
    /// The client is supposed to include the content on save.
    let includeText: Bool?

    enum CodingKeys: String, CodingKey {
        case includeText
    }
}

enum TextDocumentSyncSaveOptions: Codable {
    case supported(Bool)
    case saveOptions(SaveOptions)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let supported = try? container.decode(Bool.self) {
            self = .supported(supported)
        } else {
            self = .saveOptions(try container.decode(SaveOptions.self))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .supported(let supported):
            try container.encode(supported)
        case .saveOptions(let saveOptions):
            try container.encode(saveOptions)
        }
    }
}

public struct TextDocumentSyncOptions: Codable {
    /// Open and close notifications are sent to the server.
    let openClose: Bool?

    /// Change notifications are sent to the server. See TextDocumentSyncKind.None, TextDocumentSyncKind.Full
    /// and TextDocumentSyncKindIncremental.
    let change: TextDocumentSyncKind?

    /// Will save notifications are sent to the server.
    let willSave: Bool?

    /// Will save wait until requests are sent to the server.
    let willSaveWaitUntil: Bool?

    /// Save notifications are sent to the server.
    let save: TextDocumentSyncSaveOptions?

    enum CodingKeys: String, CodingKey {
        case openClose
        case change
        case willSave
        case willSaveWaitUntil
        case save
    }
}

enum OneOf<A, B> {
    case left(A)
    case right(B)
}

extension OneOf: Codable where A: Codable, B: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(A.self) {
            self = .left(value)
        } else if let value = try? container.decode(B.self) {
            self = .right(value)
        } else {
            throw DecodingError.typeMismatch(OneOf.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for OneOf"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .left(let a):
            try container.encode(a)
        case .right(let b):
            try container.encode(b)
        }
    }
}

enum TextDocumentSyncCapability {
    case kind(TextDocumentSyncKind)
    case options(TextDocumentSyncOptions)
}

extension TextDocumentSyncCapability: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let kind = try? container.decode(TextDocumentSyncKind.self) {
            self = .kind(kind)
        } else if let options = try? container.decode(TextDocumentSyncOptions.self) {
            self = .options(options)
        } else {
            throw DecodingError.typeMismatch(TextDocumentSyncCapability.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for TextDocumentSyncCapability"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .kind(let kind):
            try container.encode(kind)
        case .options(let options):
            try container.encode(options)
        }
    }
}

enum ImplementationProviderCapability {
    case simple(Bool)
    case options(StaticTextDocumentRegistrationOptions)
}

extension ImplementationProviderCapability: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let simple = try? container.decode(Bool.self) {
            self = .simple(simple)
        } else if let options = try? container.decode(StaticTextDocumentRegistrationOptions.self) {
            self = .options(options)
        } else {
            throw DecodingError.typeMismatch(ImplementationProviderCapability.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ImplementationProviderCapability"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .simple(let simple):
            try container.encode(simple)
        case .options(let options):
            try container.encode(options)
        }
    }
}

enum TypeDefinitionProviderCapability {
    case simple(Bool)
    case options(StaticTextDocumentRegistrationOptions)
}

extension TypeDefinitionProviderCapability: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let simple = try? container.decode(Bool.self) {
            self = .simple(simple)
        } else if let options = try? container.decode(StaticTextDocumentRegistrationOptions.self) {
            self = .options(options)
        } else {
            throw DecodingError.typeMismatch(TypeDefinitionProviderCapability.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for TypeDefinitionProviderCapability"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .simple(let simple):
            try container.encode(simple)
        case .options(let options):
            try container.encode(options)
        }
    }
}

public struct ServerCapabilities: Codable {
    /// The position encoding the server picked from the encodings offered
    /// by the client via the client capability `general.positionEncodings`.
    ///
    /// If the client didn't provide any position encodings the only valid
    /// value that a server can return is 'utf-16'.
    ///
    /// If omitted it defaults to 'utf-16'.
    ///
    /// @since 3.17.0
    let positionEncoding: PositionEncodingKind?

    /// Defines how text documents are synced.
    let textDocumentSync: TextDocumentSyncCapability?

    /// Capabilities specific to `textDocument/selectionRange` requests.
    let selectionRangeProvider: SelectionRangeProviderCapability?

    /// The server provides hover support.
    let hoverProvider: HoverProviderCapability?

    /// The server provides completion support.
    let completionProvider: CompletionOptions?

    /// The server provides signature help support.
    let signatureHelpProvider: SignatureHelpOptions?

    /// The server provides goto definition support.
    let definitionProvider: OneOf<Bool, DefinitionOptions>?

    /// The server provides goto type definition support.
    let typeDefinitionProvider: TypeDefinitionProviderCapability?

    /// The server provides goto implementation support.
    let implementationProvider: ImplementationProviderCapability?

    /// The server provides find references support.
    let referencesProvider: OneOf<Bool, ReferencesOptions>?

    /// The server provides document highlight support.
    let documentHighlightProvider: OneOf<Bool, DocumentHighlightOptions>?

    /// The server provides document symbol support.
    let documentSymbolProvider: OneOf<Bool, DocumentSymbolOptions>?

    /// The server provides workspace symbol support.
    let workspaceSymbolProvider: OneOf<Bool, WorkspaceSymbolOptions>?

    /// The server provides code actions.
    let codeActionProvider: CodeActionProviderCapability?

    /// The server provides code lens.
    let codeLensProvider: CodeLensOptions?

    /// The server provides document formatting.
    let documentFormattingProvider: OneOf<Bool, DocumentFormattingOptions>?

    /// The server provides document range formatting.
    let documentRangeFormattingProvider: OneOf<Bool, DocumentRangeFormattingOptions>?

    /// The server provides document formatting on typing.
    let documentOnTypeFormattingProvider: DocumentOnTypeFormattingOptions?

    /// The server provides rename support.
    let renameProvider: OneOf<Bool, RenameOptions>?

    /// The server provides document link support.
    let documentLinkProvider: DocumentLinkOptions?

    /// The server provides color provider support.
    let colorProvider: ColorProviderCapability?

    /// The server provides folding provider support.
    let foldingRangeProvider: FoldingRangeProviderCapability?

    /// The server provides go to declaration support.
    let declarationProvider: DeclarationCapability?

    /// The server provides execute command support.
    let executeCommandProvider: ExecuteCommandOptions?

    /// Workspace specific server capabilities
    let workspace: WorkspaceServerCapabilities?

    /// Call hierarchy provider capabilities.
    let callHierarchyProvider: CallHierarchyServerCapability?

    /// Semantic tokens server capabilities.
    let semanticTokensProvider: SemanticTokensServerCapabilities?

    /// Whether server provides moniker support.
    let monikerProvider: OneOf<Bool, MonikerServerCapabilities>?

    /// The server provides linked editing range support.
    ///
    /// @since 3.16.0
    let linkedEditingRangeProvider: LinkedEditingRangeServerCapabilities?

    /// The server provides inline values.
    ///
    /// @since 3.17.0
    let inlineValueProvider: OneOf<Bool, InlineValueServerCapabilities>?

    /// The server provides inlay hints.
    ///
    /// @since 3.17.0
    let inlayHintProvider: OneOf<Bool, InlayHintServerCapabilities>?

    /// The server has support for pull model diagnostics.
    ///
    /// @since 3.17.0
    let diagnosticProvider: DiagnosticServerCapabilities?

    /// The server provides inline completions.
    ///
    /// @since 3.18.0
#if LSP_PROPOSED
    let inlineCompletionProvider: OneOf<Bool, InlineCompletionOptions>?
#endif

    /// Experimental server capabilities.
    let experimental: LSPAny?

    enum CodingKeys: String, CodingKey {
        case positionEncoding
        case textDocumentSync
        case selectionRangeProvider
        case hoverProvider
        case completionProvider
        case signatureHelpProvider
        case definitionProvider
        case typeDefinitionProvider
        case implementationProvider
        case referencesProvider
        case documentHighlightProvider
        case documentSymbolProvider
        case workspaceSymbolProvider
        case codeActionProvider
        case codeLensProvider
        case documentFormattingProvider
        case documentRangeFormattingProvider
        case documentOnTypeFormattingProvider
        case renameProvider
        case documentLinkProvider
        case colorProvider
        case foldingRangeProvider
        case declarationProvider
        case executeCommandProvider
        case workspace
        case callHierarchyProvider
        case semanticTokensProvider
        case monikerProvider
        case linkedEditingRangeProvider
        case inlineValueProvider
        case inlayHintProvider
        case diagnosticProvider
#if LSP_PROPOSED
        case inlineCompletionProvider
#endif
        case experimental
    }
}

public struct WorkspaceServerCapabilities: Codable {
    /// The server supports workspace folder.
    let workspaceFolders: WorkspaceFoldersServerCapabilities?

    let fileOperations: WorkspaceFileOperationsServerCapabilities?

    enum CodingKeys: String, CodingKey {
        case workspaceFolders
        case fileOperations
    }
}

/// General parameters to to register for a capability.
public struct Registration: Codable {
    /// The id used to register the request. The id can be used to deregister
    /// the request again.
    let id: String

    /// The method / capability to register for.
    let method: String

    /// Options necessary for the registration.
    let registerOptions: LSPAny?

    enum CodingKeys: String, CodingKey {
        case id
        case method
        case registerOptions
    }
}

public struct RegistrationParams: Codable {
    let registrations: [Registration]
}

/// Since most of the registration options require to specify a document selector there is a base
/// interface that can be used.
public struct TextDocumentRegistrationOptions: Codable {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    let documentSelector: DocumentSelector?
}

enum DeclarationCapability {
    case simple(Bool)
    case registrationOptions(DeclarationRegistrationOptions)
    case options(DeclarationOptions)
}

extension DeclarationCapability: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let bool = try? container.decode(Bool.self) {
            self = .simple(bool)
        } else if let registrationOptions = try? container.decode(DeclarationRegistrationOptions.self) {
            self = .registrationOptions(registrationOptions)
        } else if let options = try? container.decode(DeclarationOptions.self) {
            self = .options(options)
        } else {
            throw DecodingError.typeMismatch(DeclarationCapability.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for DeclarationCapability"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .simple(let bool):
            try container.encode(bool)
        case .registrationOptions(let registrationOptions):
            try container.encode(registrationOptions)
        case .options(let options):
            try container.encode(options)
        }
    }
}

public struct DeclarationRegistrationOptions: Codable {
    let declarationOptions: DeclarationOptions
    let textDocumentRegistrationOptions: TextDocumentRegistrationOptions
    let staticRegistrationOptions: StaticRegistrationOptions
}

public struct DeclarationOptions: Codable {
    let workDoneProgressOptions: WorkDoneProgressOptions
}

public struct StaticRegistrationOptions: Codable {
    let id: String?

    enum CodingKeys: String, CodingKey {
        case id
    }
}
public struct DocumentFormattingOptions: Codable {
    let workDoneProgressOptions: WorkDoneProgressOptions
}

public struct DocumentRangeFormattingOptions: Codable {
    let workDoneProgressOptions: WorkDoneProgressOptions
}

public struct DefinitionOptions: Codable {
    let workDoneProgressOptions: WorkDoneProgressOptions
}

public struct DocumentSymbolOptions: Codable {
    /// A human-readable string that is shown when multiple outlines trees are
    /// shown for the same document.
    ///
    /// @since 3.16.0
    let label: String?

    let workDoneProgressOptions: WorkDoneProgressOptions

    enum CodingKeys: String, CodingKey {
        case label
        case workDoneProgressOptions
    }
}

public struct ReferencesOptions: Codable {
    let workDoneProgressOptions: WorkDoneProgressOptions
}

public struct DocumentHighlightOptions: Codable {
    let workDoneProgressOptions: WorkDoneProgressOptions
}

public struct WorkspaceSymbolOptions: Codable {
    let workDoneProgressOptions: WorkDoneProgressOptions

    /// The server provides support to resolve additional
    /// information for a workspace symbol.
    ///
    /// @since 3.17.0
    let resolveProvider: Bool?

    enum CodingKeys: String, CodingKey {
        case workDoneProgressOptions
        case resolveProvider
    }
}

public struct StaticTextDocumentRegistrationOptions: Codable {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    let documentSelector: DocumentSelector?

    let id: String?
}

/// General parameters to unregister a capability.
public struct Unregistration: Codable {
    /// The id used to unregister the request or notification. Usually an id
    /// provided during the register request.
    let id: String

    /// The method / capability to unregister for.
    let method: String
}

public struct UnregistrationParams: Codable {
    let unregisterations: [Unregistration]
}

public struct DidChangeConfigurationParams: Codable {
    /// The actual changed settings
    let settings: LSPAny
}

public struct DidOpenTextDocumentParams: Codable {
    /// The document that was opened.
    let textDocument: TextDocumentItem
}

public struct DidChangeTextDocumentParams: Codable {
    /// The document that did change. The version number points
    /// to the version after all provided content changes have
    /// been applied.
    let textDocument: VersionedTextDocumentIdentifier

    /// The actual content changes.
    let contentChanges: [TextDocumentContentChangeEvent]

    enum CodingKeys: String, CodingKey {
        case textDocument
        case contentChanges
    }
}

/// An event describing a change to a text document. If range and rangeLength are omitted
/// the new text is considered to be the full content of the document.
public struct TextDocumentContentChangeEvent: Codable {
    /// The range of the document that changed.
    let range: LSPRange?

    /// The length of the range that got replaced.
    ///
    /// Deprecated: Use range instead
    let rangeLength: UInt32?

    /// The new text of the document.
    let text: String

    enum CodingKeys: String, CodingKey {
        case range
        case rangeLength
        case text
    }
}

/// Describe options to be used when registering for text document change events.
///
/// Extends TextDocumentRegistrationOptions
public struct TextDocumentChangeRegistrationOptions: Codable {
    /// A document selector to identify the scope of the registration. If set to null
    /// the document selector provided on the client side will be used.
    let documentSelector: DocumentSelector?

    /// How documents are synced to the server. See TextDocumentSyncKind.Full
    /// and TextDocumentSyncKindIncremental.
    let syncKind: Int

    enum CodingKeys: String, CodingKey {
        case documentSelector
        case syncKind
    }
}

/// The parameters send in a will save text document notification.
public struct WillSaveTextDocumentParams: Codable {
    /// The document that will be saved.
    let textDocument: TextDocumentIdentifier

    /// The 'TextDocumentSaveReason'.
    let reason: TextDocumentSaveReason
}

/// Represents reasons why a text document is saved.
public struct TextDocumentSaveReason: RawRepresentable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Manually triggered, e.g. by the user pressing save, by starting debugging,
    /// or by an API call.
    static let manual = TextDocumentSaveReason(rawValue: 1)

    /// Automatic after a delay.
    static let afterDelay = TextDocumentSaveReason(rawValue: 2)

    /// When the editor lost focus.
    static let focusOut = TextDocumentSaveReason(rawValue: 3)
}

public struct DidCloseTextDocumentParams: Codable {
    /// The document that was closed.
    let textDocument: TextDocumentIdentifier
}

public struct DidSaveTextDocumentParams: Codable {
    /// The document that was saved.
    let textDocument: TextDocumentIdentifier

    /// Optional the content when saved. Depends on the includeText value
    /// when the save notification was requested.
    let text: String?

    enum CodingKeys: String, CodingKey {
        case textDocument
        case text
    }
}

public struct TextDocumentSaveRegistrationOptions: Codable {
    /// The client is supposed to include the content on save.
    let includeText: Bool?

    let textDocumentRegistrationOptions: TextDocumentRegistrationOptions

    enum CodingKeys: String, CodingKey {
        case includeText
        case textDocumentRegistrationOptions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        includeText = try container.decodeIfPresent(Bool.self,
                                                    forKey: .includeText)
        textDocumentRegistrationOptions = try container.decode(TextDocumentRegistrationOptions.self,
                                                               forKey: .textDocumentRegistrationOptions)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(includeText,
                                      forKey: .includeText)
        try container.encode(textDocumentRegistrationOptions,
                             forKey: .textDocumentRegistrationOptions)
    }
}

public struct DidChangeWatchedFilesClientCapabilities: Codable {
    /// Did change watched files notification supports dynamic registration.
    /// Please note that the current protocol doesn't support static
    /// configuration for file changes from the server side.
    let dynamicRegistration: Bool?

    /// Whether the client has support for relative patterns
    /// or not.
    ///
    /// @since 3.17.0
    let relativePatternSupport: Bool?

    enum CodingKeys: String, CodingKey {
        case dynamicRegistration
        case relativePatternSupport
    }
}

public struct DidChangeWatchedFilesParams: Codable {
    /// The actual file events.
    let changes: [FileEvent]
}

/// The file event type.
public struct FileChangeType: RawRepresentable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// The file got created.
    static let created = FileChangeType(rawValue: 1)

    /// The file got changed.
    static let changed = FileChangeType(rawValue: 2)

    /// The file got deleted.
    static let deleted = FileChangeType(rawValue: 3)
}

/// An event describing a file change.
public struct FileEvent: Codable {
    /// The file's URI.
    let uri: URL

    /// The change type.
    let type: FileChangeType

    enum CodingKeys: String, CodingKey {
        case uri
        case type
    }

    init(uri: URL, type: FileChangeType) {
        self.uri = uri
        self.type = type
    }
}

/// Describe options to be used when registered for text document change events.
public struct DidChangeWatchedFilesRegistrationOptions: Codable {
    /// The watchers to register.
    let watchers: [FileSystemWatcher]
}

public struct FileSystemWatcher: Codable {
    /// The glob pattern to watch. See {@link GlobPattern glob pattern}
    /// for more detail.
    ///
    /// @since 3.17.0 support for relative patterns.
    let globPattern: GlobPattern

    /// The kind of events of interest. If omitted it defaults to WatchKind.Create |
    /// WatchKind.Change | WatchKind.Delete which is 7.
    let kind: WatchKind?

    enum CodingKeys: String, CodingKey {
        case globPattern
        case kind
    }
}

/// The glob pattern. Either a string pattern or a relative pattern.
///
/// @since 3.17.0
enum GlobPattern {
    case string(LSPPattern)
    case relative(RelativePattern)
}

extension GlobPattern: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(LSPPattern.self) {
            self = .string(string)
        } else if let relative = try? container.decode(RelativePattern.self) {
            self = .relative(relative)
        } else {
            throw DecodingError.typeMismatch(GlobPattern.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for GlobPattern"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let pattern):
            try container.encode(pattern)
        case .relative(let relative):
            try container.encode(relative)
        }
    }
}

/// A relative pattern is a helper to conpublic struct glob patterns that are matched
/// relatively to a base URI. The common value for a `baseUri` is a workspace
/// folder root, but it can be another absolute URI as well.
///
/// @since 3.17.0
public struct RelativePattern: Codable {
    /// A workspace folder or a base URI to which this pattern will be matched
    /// against relatively.
    let baseUri: OneOf<WorkspaceFolder, URL>

    /// The actual glob pattern.
    let pattern: LSPPattern

    enum CodingKeys: String, CodingKey {
        case baseUri
        case pattern
    }
}

/// The glob pattern to watch relative to the base path. Glob patterns can have
/// the following syntax:
/// - `*` to match one or more characters in a path segment
/// - `?` to match on one character in a path segment
/// - `**` to match any number of path segments, including none
/// - `{}` to group conditions (e.g. `**​/*.{ts,js}` matches all TypeScript
///   and JavaScript files)
/// - `[]` to declare a range of characters to match in a path segment
///   (e.g., `example.[0-9]` to match on `example.0`, `example.1`, …)
/// - `[!...]` to negate a range of characters to match in a path segment
///   (e.g., `example.[!0-9]` to match on `example.a`, `example.b`,
///   but not `example.0`)
///
/// @since 3.17.0
typealias LSPPattern = String

public struct WatchKind: OptionSet, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Interested in create events.
    static let create = WatchKind(rawValue: 1)

    /// Interested in change events
    static let change = WatchKind(rawValue: 2)

    /// Interested in delete events
    static let delete = WatchKind(rawValue: 4)
}

extension WatchKind {
    public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(UInt8.self)
        self = Self(rawValue: Int(rawValue))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public struct PublishDiagnosticsParams: Codable {
    /// The URI for which diagnostic information is reported.
    let uri: URL

    /// An array of diagnostic information items.
    let diagnostics: [Diagnostic]

    /// Optional the version number of the document the diagnostics are published for.
    let version: Int32?

    enum CodingKeys: String, CodingKey {
        case uri
        case diagnostics
        case version
    }

    init(uri: URL, diagnostics: [Diagnostic], version: Int32?) {
        self.uri = uri
        self.diagnostics = diagnostics
        self.version = version
    }
}

enum Documentation: Codable {
    case string(String)
    case markupContent(MarkupContent)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let markupContent = try? container.decode(MarkupContent.self) {
            self = .markupContent(markupContent)
        } else {
            throw DecodingError.typeMismatch(Documentation.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Documentation"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        case .markupContent(let markupContent):
            try container.encode(markupContent)
        }
    }
}

/// MarkedString can be used to render human readable text. It is either a
/// markdown string or a code-block that provides a language and a code snippet.
/// The language identifier is semantically equal to the optional language
/// identifier in fenced code blocks in GitHub issues.
///
/// The pair of a language and a value is an equivalent to markdown:
///
/// ```${language}
/// ${value}
/// ```
enum MarkedString: Codable {
    case string(String)
    case languageString(LanguageString)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let languageString = try? container.decode(LanguageString.self) {
            self = .languageString(languageString)
        } else {
            throw DecodingError.typeMismatch(MarkedString.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for MarkedString"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        case .languageString(let languageString):
            try container.encode(languageString)
        }
    }

    static func fromMarkdown(_ markdown: String) -> MarkedString {
        return .string(markdown)
    }

    static func fromLanguageCode(_ language: String, codeBlock: String) -> MarkedString {
        return .languageString(LanguageString(language: language, value: codeBlock))
    }
}

public struct LanguageString: Codable {
    let language: String
    let value: String
}

public struct GotoDefinitionParams: Codable {
    let textDocumentPositionParams: TextDocumentPositionParams
    let workDoneProgressParams: WorkDoneProgressParams
    let partialResultParams: PartialResultParams
}

/// GotoDefinition response can be single location, or multiple Locations or a link.
enum GotoDefinitionResponse: Codable {
    case scalar(LSPLocation)
    case array([LSPLocation])
    case link([LocationLink])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let location = try? container.decode(LSPLocation.self) {
            self = .scalar(location)
        } else if let locations = try? container.decode([LSPLocation].self) {
            self = .array(locations)
        } else if let links = try? container.decode([LocationLink].self) {
            self = .link(links)
        } else {
            throw DecodingError.typeMismatch(GotoDefinitionResponse.self,
                                             DecodingError.Context(codingPath: decoder.codingPath,
                                                                   debugDescription: "Wrong type for GotoDefinitionResponse"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .scalar(let location):
            try container.encode(location)
        case .array(let locations):
            try container.encode(locations)
        case .link(let links):
            try container.encode(links)
        }
    }
}

extension LSPLocation {
    func asGotoDefinitionResponse() -> GotoDefinitionResponse {
        return .scalar(self)
    }
}

extension Array where Element == LSPLocation {
    func asGotoDefinitionResponse() -> GotoDefinitionResponse {
        return .array(self)
    }
}

extension Array where Element == LocationLink {
    func asGotoDefinitionResponse() -> GotoDefinitionResponse {
        return .link(self)
    }
}

public struct ExecuteCommandParams: Codable {
    /// The identifier of the actual command handler.
    let command: String

    /// Arguments that the command should be invoked with.
    let arguments: [LSPAny]

    let workDoneProgressParams: WorkDoneProgressParams

    enum CodingKeys: String, CodingKey {
        case command
        case arguments
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        command = try container.decode(String.self, forKey: .command)
        arguments = try container.decodeIfPresent([LSPAny].self, forKey: .arguments) ?? []
        workDoneProgressParams = try WorkDoneProgressParams(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(command, forKey: .command)
        try container.encode(arguments, forKey: .arguments)
        try workDoneProgressParams.encode(to: encoder)
    }
}

/// Execute command registration options.
public struct ExecuteCommandRegistrationOptions: Codable {
    /// The commands to be executed on the server
    let commands: [String]

    let executeCommandOptions: ExecuteCommandOptions
}

public struct ApplyWorkspaceEditParams: Codable {
    /// An optional label of the workspace edit. This label is
    /// presented in the user interface for example on an undo
    /// stack to undo the workspace edit.
    let label: String?

    /// The edits to apply.
    let edit: WorkspaceEdit

    enum CodingKeys: String, CodingKey {
        case label
        case edit
    }
}

public struct ApplyWorkspaceEditResponse: Codable {
    /// Indicates whether the edit was applied or not.
    let applied: Bool

    /// An optional textual description for why the edit was not applied.
    /// This may be used may be used by the server for diagnostic
    /// logging or to provide a suitable error for a request that
    /// triggered the edit
    let failureReason: String?

    /// Depending on the client's failure handling strategy `failedChange` might
    /// contain the index of the change that failed. This property is only available
    /// if the client signals a `failureHandlingStrategy` in its client capabilities.
    let failedChange: UInt32?

    enum CodingKeys: String, CodingKey {
        case applied
        case failureReason
        case failedChange
    }
}

/// Describes the content type that a client supports in various
/// result literals like `Hover`, `ParameterInfo` or `CompletionItem`.
///
/// Please note that `MarkupKinds` must not start with a `$`. This kinds
/// are reserved for internal usage.
enum MarkupKind: String, Codable {
    /// Plain text is supported as a content format
    case plainText = "plaintext"

    /// Markdown is supported as a content format
    case markdown
}

/// A `MarkupContent` literal represents a string value which content can be represented in different formats.
/// Currently `plaintext` and `markdown` are supported formats. A `MarkupContent` is usually used in
/// documentation properties of result literals like `CompletionItem` or `SignatureInformation`.
/// If the format is `markdown` the content should follow the [GitHub Flavored Markdown Specification](https://github.github.com/gfm/).
///
/// Here is an example how such a string can be conpublic structed using JavaScript / TypeScript:
///
/// ```ignore
/// let markdown: MarkupContent = {
///     kind: MarkupKind.Markdown,
///     value: [
///         "# Header",
///         "Some text",
///         "```typescript",
///         "someCode();",
///         "```"
///     ]
///     .join("\n"),
/// };
/// ```
///
/// Please *Note* that clients might sanitize the return markdown. A client could decide to
/// remove HTML from the markdown to avoid script execution.
public struct MarkupContent: Codable {
    let kind: MarkupKind
    let value: String
}

/// A parameter literal used to pass a partial result token.
public struct PartialResultParams: Codable {
    let partialResultToken: ProgressToken?

    enum CodingKeys: String, CodingKey {
        case partialResultToken
    }
}

/// Symbol tags are extra annotations that tweak the rendering of a symbol.
///
/// @since 3.16.0
public struct SymbolTag: RawRepresentable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Render a symbol as obsolete, usually using a strike-out.
    static let deprecated = SymbolTag(rawValue: 1)
}
