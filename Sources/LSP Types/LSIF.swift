//
//  LSIF.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/04/28.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

// Types of Language Server Index Format (LSIF). LSIF is a standard format
// for language servers or other programming tools to dump their knowledge
// about a workspace.
//
// Based on <https://microsoft.github.io/language-server-protocol/specifications/lsif/0.6.0/specification/>

public typealias Id = NumberOrString

public enum LocationOrRangeId: Codable {
    case location(LSPLocation)
    case rangeId(Id)
}

public struct Entry: Codable {
    public let id: Id
    public let data: Element

    private enum CodingKeys: String, CodingKey {
        case id
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Id.self, forKey: .id)
        data = try Element(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try data.encode(to: encoder)
    }
}

public enum Element: Codable {
    case vertex(Vertex)
    case edge(Edge)

    private enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "vertex":
            self = .vertex(try Vertex(from: decoder))
        case "edge":
            self = .edge(try Edge(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid type value")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .vertex(let vertex):
            try container.encode("vertex", forKey: .type)
            try vertex.encode(to: encoder)
        case .edge(let edge):
            try container.encode("edge", forKey: .type)
            try edge.encode(to: encoder)
        }
    }
}

public struct ToolInfo: Codable {
    public let name: String
    public let args: [String]
    public let version: String?

    public init(name: String, args: [String] = [], version: String? = nil) {
        self.name = name
        self.args = args
        self.version = version
    }
}

public enum Encoding: String, Codable {
    /// Currently only 'utf-16' is supported due to the limitations in LSP.
    case utf16 = "utf-16"
}

public struct RangeBasedDocumentSymbol: Codable {
    public let id: Id
    public let children: [RangeBasedDocumentSymbol]

    public init(id: Id, children: [RangeBasedDocumentSymbol] = []) {
        self.id = id
        self.children = children
    }
}

public enum DocumentSymbolOrRangeBasedVec: Codable {
    case documentSymbol([DocumentSymbol])
    case rangeBased([RangeBasedDocumentSymbol])
}

public struct DefinitionTag: Codable {
    /// The text covered by the range
    public let text: String
    /// The symbol kind.
    public let kind: SymbolKind
    /// Indicates if this symbol is deprecated.
    public let deprecated: Bool
    /// The full range of the definition not including leading/trailing whitespace but everything else, e.g comments and code.
    /// The range must be included in fullRange.
    public let fullRange: LSPRange
    /// Optional detail information for the definition.
    public let detail: String?

    public init(text: String, kind: SymbolKind, deprecated: Bool = false, fullRange: LSPRange, detail: String? = nil) {
        self.text = text
        self.kind = kind
        self.deprecated = deprecated
        self.fullRange = fullRange
        self.detail = detail
    }
}

public struct DeclarationTag: Codable {
    /// The text covered by the range
    public let text: String
    /// The symbol kind.
    public let kind: SymbolKind
    /// Indicates if this symbol is deprecated.
    public let deprecated: Bool
    /// The full range of the definition not including leading/trailing whitespace but everything else, e.g comments and code.
    /// The range must be included in fullRange.
    public let fullRange: LSPRange
    /// Optional detail information for the definition.
    public let detail: String?

    public init(text: String, kind: SymbolKind, deprecated: Bool, fullRange: LSPRange, detail: String? = nil) {
        self.text = text
        self.kind = kind
        self.deprecated = deprecated
        self.fullRange = fullRange
        self.detail = detail
    }
}

public struct ReferenceTag: Codable {
    public let text: String

    public init(text: String) {
        self.text = text
    }
}

public struct UnknownTag: Codable {
    public let text: String

    public init(text: String) {
        self.text = text
    }
}

public enum RangeTag: Codable {
    case definition(DefinitionTag)
    case declaration(DeclarationTag)
    case reference(ReferenceTag)
    case unknown(UnknownTag)

    private enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "definition":
            self = .definition(try DefinitionTag(from: decoder))
        case "declaration":
            self = .declaration(try DeclarationTag(from: decoder))
        case "reference":
            self = .reference(try ReferenceTag(from: decoder))
        case "unknown":
            self = .unknown(try UnknownTag(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid type value")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .definition(let definitionTag):
            try container.encode("definition", forKey: .type)
            try definitionTag.encode(to: encoder)
        case .declaration(let declarationTag):
            try container.encode("declaration", forKey: .type)
            try declarationTag.encode(to: encoder)
        case .reference(let referenceTag):
            try container.encode("reference", forKey: .type)
            try referenceTag.encode(to: encoder)
        case .unknown(let unknownTag):
            try container.encode("unknown", forKey: .type)
            try unknownTag.encode(to: encoder)
        }
    }
}

public enum Vertex: Codable {
    case metaData(MetaData)
    /// <https://github.com/Microsoft/language-server-protocol/blob/master/indexFormat/specification.md#the-project-vertex>
    case project(LSPProject)
    case document(Document)
    /// <https://github.com/Microsoft/language-server-protocol/blob/master/indexFormat/specification.md#ranges>
    case range(LSPRange, tag: RangeTag?)
    /// <https://github.com/Microsoft/language-server-protocol/blob/master/indexFormat/specification.md#result-set>
    case resultSet(ResultSet)
    case moniker(Moniker)
    case packageInformation(PackageInformation)
    case event(LSPEvent)
    case definitionResult
    case declarationResult
    case typeDefinitionResult
    case referenceResult
    case implementationResult
    case foldingRangeResult(result: [FoldingRange])
    case hoverResult(result: Hover)
    case documentSymbolResult(result: DocumentSymbolOrRangeBasedVec)
    case documentLinkResult(result: [DocumentLink])
    case diagnosticResult(result: [Diagnostic])

    private enum CodingKeys: String, CodingKey {
        case label
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let label = try container.decode(String.self, forKey: .label)

        switch label {
        case "metaData":
            self = .metaData(try MetaData(from: decoder))
        case "project":
            self = .project(try LSPProject(from: decoder))
        case "document":
            self = .document(try Document(from: decoder))
        case "range":
            let range = try LSPRange(from: decoder)
            let tag = try container.decodeIfPresent(RangeTag.self, forKey: .label)
            self = .range(range, tag: tag)
        case "resultSet":
            self = .resultSet(try ResultSet(from: decoder))
        case "moniker":
            self = .moniker(try Moniker(from: decoder))
        case "packageInformation":
            self = .packageInformation(try PackageInformation(from: decoder))
        case "$event":
            self = .event(try LSPEvent(from: decoder))
        case "definitionResult":
            self = .definitionResult
        case "declarationResult":
            self = .declarationResult
        case "typeDefinitionResult":
            self = .typeDefinitionResult
        case "referenceResult":
            self = .referenceResult
        case "implementationResult":
            self = .implementationResult
        case "foldingRangeResult":
            let result = try container.decode([FoldingRange].self, forKey: .label)
            self = .foldingRangeResult(result: result)
        case "hoverResult":
            let result = try container.decode(Hover.self, forKey: .label)
            self = .hoverResult(result: result)
        case "documentSymbolResult":
            let result = try container.decode(DocumentSymbolOrRangeBasedVec.self, forKey: .label)
            self = .documentSymbolResult(result: result)
        case "documentLinkResult":
            let result = try container.decode([DocumentLink].self, forKey: .label)
            self = .documentLinkResult(result: result)
        case "diagnosticResult":
            let result = try container.decode([Diagnostic].self, forKey: .label)
            self = .diagnosticResult(result: result)
        default:
            throw DecodingError.dataCorruptedError(forKey: .label, in: container, debugDescription: "Invalid label value")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .metaData(let metaData):
            try container.encode("metaData", forKey: .label)
            try metaData.encode(to: encoder)
        case .project(let project):
            try container.encode("project", forKey: .label)
            try project.encode(to: encoder)
        case .document(let document):
            try container.encode("document", forKey: .label)
            try document.encode(to: encoder)
        case .range(let range, let tag):
            try container.encode("range", forKey: .label)
            try range.encode(to: encoder)
            try tag?.encode(to: encoder)
        case .resultSet(let resultSet):
            try container.encode("resultSet", forKey: .label)
            try resultSet.encode(to: encoder)
        case .moniker(let moniker):
            try container.encode("moniker", forKey: .label)
            try moniker.encode(to: encoder)
        case .packageInformation(let packageInformation):
            try container.encode("packageInformation", forKey: .label)
            try packageInformation.encode(to: encoder)
        case .event(let event):
            try container.encode("$event", forKey: .label)
            try event.encode(to: encoder)
        case .definitionResult:
            try container.encode("definitionResult", forKey: .label)
        case .declarationResult:
            try container.encode("declarationResult", forKey: .label)
        case .typeDefinitionResult:
            try container.encode("typeDefinitionResult", forKey: .label)
        case .referenceResult:
            try container.encode("referenceResult", forKey: .label)
        case .implementationResult:
            try container.encode("implementationResult", forKey: .label)
        case .foldingRangeResult(let result):
            try container.encode("foldingRangeResult", forKey: .label)
            try container.encode(result, forKey: .label)
        case .hoverResult(let result):
            try container.encode("hoverResult", forKey: .label)
            try container.encode(result, forKey: .label)
        case .documentSymbolResult(let result):
            try container.encode("documentSymbolResult", forKey: .label)
            try container.encode(result, forKey: .label)
        case .documentLinkResult(let result):
            try container.encode("documentLinkResult", forKey: .label)
            try container.encode(result, forKey: .label)
        case .diagnosticResult(let result):
            try container.encode("diagnosticResult", forKey: .label)
            try container.encode(result, forKey: .label)
        }
    }
}

public enum EventKind: String, Codable {
    case begin = "begin"
    case end = "end"
}

public enum EventScope: String, Codable {
    case document = "document"
    case project = "project"
}

public struct LSPEvent: Codable {
    public let kind: EventKind
    public let scope: EventScope
    public let data: Id

    public init(kind: EventKind, scope: EventScope, data: Id) {
        self.kind = kind
        self.scope = scope
        self.data = data
    }
}

public enum Edge: Codable {
    case contains(EdgeDataMultiIn)
    case moniker(EdgeData)
    case nextMoniker(EdgeData)
    case next(EdgeData)
    case packageInformation(EdgeData)
    case item(Item)
    case definition(EdgeData)
    case declaration(EdgeData)
    case hover(EdgeData)
    case references(EdgeData)
    case implementation(EdgeData)
    case typeDefinition(EdgeData)
    case foldingRange(EdgeData)
    case documentLink(EdgeData)
    case documentSymbol(EdgeData)
    case diagnostic(EdgeData)

    private enum CodingKeys: String, CodingKey {
        case label
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let label = try container.decode(String.self, forKey: .label)

        switch label {
        case "contains":
            self = .contains(try EdgeDataMultiIn(from: decoder))
        case "moniker":
            self = .moniker(try EdgeData(from: decoder))
        case "nextMoniker":
            self = .nextMoniker(try EdgeData(from: decoder))
        case "next":
            self = .next(try EdgeData(from: decoder))
        case "packageInformation":
            self = .packageInformation(try EdgeData(from: decoder))
        case "item":
            self = .item(try Item(from: decoder))
        case "textDocument/definition":
            self = .definition(try EdgeData(from: decoder))
        case "textDocument/declaration":
            self = .declaration(try EdgeData(from: decoder))
        case "textDocument/hover":
            self = .hover(try EdgeData(from: decoder))
        case "textDocument/references":
            self = .references(try EdgeData(from: decoder))
        case "textDocument/implementation":
            self = .implementation(try EdgeData(from: decoder))
        case "textDocument/typeDefinition":
            self = .typeDefinition(try EdgeData(from: decoder))
        case "textDocument/foldingRange":
            self = .foldingRange(try EdgeData(from: decoder))
        case "textDocument/documentLink":
            self = .documentLink(try EdgeData(from: decoder))
        case "textDocument/documentSymbol":
            self = .documentSymbol(try EdgeData(from: decoder))
        case "textDocument/diagnostic":
            self = .diagnostic(try EdgeData(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: .label, in: container, debugDescription: "Invalid label value")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .contains(let edgeDataMultiIn):
            try container.encode("contains", forKey: .label)
            try edgeDataMultiIn.encode(to: encoder)
        case .moniker(let edgeData):
            try container.encode("moniker", forKey: .label)
            try edgeData.encode(to: encoder)
        case .nextMoniker(let edgeData):
            try container.encode("nextMoniker", forKey: .label)
            try edgeData.encode(to: encoder)
        case .next(let edgeData):
            try container.encode("next", forKey: .label)
            try edgeData.encode(to: encoder)
        case .packageInformation(let edgeData):
            try container.encode("packageInformation", forKey: .label)
            try edgeData.encode(to: encoder)
        case .item(let item):
            try container.encode("item", forKey: .label)
            try item.encode(to: encoder)
        case .definition(let edgeData):
            try container.encode("textDocument/definition", forKey: .label)
            try edgeData.encode(to: encoder)
        case .declaration(let edgeData):
            try container.encode("textDocument/declaration", forKey: .label)
            try edgeData.encode(to: encoder)
        case .hover(let edgeData):
            try container.encode("textDocument/hover", forKey: .label)
            try edgeData.encode(to: encoder)
        case .references(let edgeData):
            try container.encode("textDocument/references", forKey: .label)
            try edgeData.encode(to: encoder)
        case .implementation(let edgeData):
            try container.encode("textDocument/implementation", forKey: .label)
            try edgeData.encode(to: encoder)
        case .typeDefinition(let edgeData):
            try container.encode("textDocument/typeDefinition", forKey: .label)
            try edgeData.encode(to: encoder)
        case .foldingRange(let edgeData):
            try container.encode("textDocument/foldingRange", forKey: .label)
            try edgeData.encode(to: encoder)
        case .documentLink(let edgeData):
            try container.encode("textDocument/documentLink", forKey: .label)
            try edgeData.encode(to: encoder)
        case .documentSymbol(let edgeData):
            try container.encode("textDocument/documentSymbol", forKey: .label)
            try edgeData.encode(to: encoder)
        case .diagnostic(let edgeData):
            try container.encode("textDocument/diagnostic", forKey: .label)
            try edgeData.encode(to: encoder)
        }
    }
}

public struct EdgeData: Codable {
    public let inV: Id
    public let outV: Id

    public init(inV: Id, outV: Id) {
        self.inV = inV
        self.outV = outV
    }
}

public struct EdgeDataMultiIn: Codable {
    public let inVs: [Id]
    public let outV: Id

    public init(inVs: [Id], outV: Id) {
        self.inVs = inVs
        self.outV = outV
    }
}

public enum DefinitionResultType: Codable {
    case scalar(LocationOrRangeId)
    case array([LocationOrRangeId])
}

public enum ItemKind: String, Codable {
    case declarations
    case definitions
    case references
    case referenceResults
    case implementationResults
}

public struct Item: Codable {
    public let document: Id
    public let property: ItemKind?
    public let edgeData: EdgeDataMultiIn

    public init(document: Id, property: ItemKind? = nil, edgeData: EdgeDataMultiIn) {
        self.document = document
        self.property = property
        self.edgeData = edgeData
    }

    private enum CodingKeys: String, CodingKey {
        case document
        case property
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        document = try container.decode(Id.self, forKey: .document)
        property = try container.decodeIfPresent(ItemKind.self, forKey: .property)
        edgeData = try EdgeDataMultiIn(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(document, forKey: .document)
        try container.encodeIfPresent(property, forKey: .property)
        try edgeData.encode(to: encoder)
    }
}

public struct Document: Codable {
    public let uri: URL
    public let languageId: String

    public init(uri: URL, languageId: String) {
        self.uri = uri
        self.languageId = languageId
    }
}

/// <https://github.com/Microsoft/language-server-protocol/blob/master/indexFormat/specification.md#result-set>
public struct ResultSet: Codable {
    public let key: String?

    public init(key: String? = nil) {
        self.key = key
    }
}

/// <https://github.com/Microsoft/language-server-protocol/blob/master/indexFormat/specification.md#the-project-vertex>
public struct LSPProject: Codable {
    public let resource: URL?
    public let content: String?
    public let kind: String

    public init(resource: URL? = nil, content: String? = nil, kind: String) {
        self.resource = resource
        self.content = content
        self.kind = kind
    }
}

public struct MetaData: Codable {
    /// The version of the LSIF format using semver notation. See <https://semver.org/>. Please note
    /// the version numbers starting with 0 don't adhere to semver and adopters have to assume
    /// that each new version is breaking.
    public let version: String

    /// The project root (in form of an URI) used to compute this dump.
    public let projectRoot: URL

    /// The string encoding used to compute line and character values in
    /// positions and ranges.
    public let positionEncoding: Encoding

    /// Information about the tool that created the dump
    public let toolInfo: ToolInfo?

    public init(version: String, projectRoot: URL, positionEncoding: Encoding, toolInfo: ToolInfo? = nil) {
        self.version = version
        self.projectRoot = projectRoot
        self.positionEncoding = positionEncoding
        self.toolInfo = toolInfo
    }
}

public struct LSPRepository: Codable {
    public let type: String
    public let url: String
    public let commitId: String?

    public init(type: String, url: String, commitId: String? = nil) {
        self.type = type
        self.url = url
        self.commitId = commitId
    }
}

public struct PackageInformation: Codable {
    public let name: String
    public let manager: String
    public let uri: URL?
    public let content: String?
    public let repository: LSPRepository?
    public let version: String?

    public init(name: String,
                manager: String,
                uri: URL? = nil,
                content: String? = nil,
                repository: LSPRepository? = nil,
                version: String? = nil) {
        self.name = name
        self.manager = manager
        self.uri = uri
        self.content = content
        self.repository = repository
        self.version = version
    }
}
