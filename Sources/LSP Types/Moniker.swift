//
//  Moniker.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/04/28.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

public typealias MonikerClientCapabilities = DynamicRegistrationClientCapabilities

public enum MonikerServerCapabilities: Codable {
    case options(MonikerOptions)
    case registrationOptions(MonikerRegistrationOptions)
}

public struct MonikerOptions: Codable {
    public let workDoneProgressOptions: WorkDoneProgressOptions

    public init(workDoneProgressOptions: WorkDoneProgressOptions) {
        self.workDoneProgressOptions = workDoneProgressOptions
    }
}

public struct MonikerRegistrationOptions: Codable {
    public let textDocumentRegistrationOptions: TextDocumentRegistrationOptions
    public let monikerOptions: MonikerOptions

    public init(textDocumentRegistrationOptions: TextDocumentRegistrationOptions, monikerOptions: MonikerOptions) {
        self.textDocumentRegistrationOptions = textDocumentRegistrationOptions
        self.monikerOptions = monikerOptions
    }

    private enum CodingKeys: String, CodingKey {
        case textDocumentRegistrationOptions
        case monikerOptions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        textDocumentRegistrationOptions = try TextDocumentRegistrationOptions(from: decoder)
        monikerOptions = try container.decode(MonikerOptions.self, forKey: .monikerOptions)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try textDocumentRegistrationOptions.encode(to: encoder)
        try container.encode(monikerOptions, forKey: .monikerOptions)
    }
}

/// Moniker uniqueness level to define scope of the moniker.
public enum UniquenessLevel: String, Codable {
    /// The moniker is only unique inside a document
    case document = "document"
    /// The moniker is unique inside a project for which a dump got created
    case project = "project"
    /// The moniker is unique inside the group to which a project belongs
    case group = "group"
    /// The moniker is unique inside the moniker scheme.
    case scheme = "scheme"
    /// The moniker is globally unique
    case global = "global"
}

/// The moniker kind.
public enum MonikerKind: String, Codable {
    /// The moniker represent a symbol that is imported into a project
    case `import` = "import"
    /// The moniker represent a symbol that is exported into a project
    case `export` = "export"
    /// The moniker represents a symbol that is local to a project (e.g. a local
    /// variable of a function, a class not visible outside the project, ...)
    case local = "local"
}

public struct MonikerParams: Codable {
    public let textDocumentPositionParams: TextDocumentPositionParams
    public let workDoneProgressParams: WorkDoneProgressParams
    public let partialResultParams: PartialResultParams

    public init(textDocumentPositionParams: TextDocumentPositionParams, workDoneProgressParams: WorkDoneProgressParams, partialResultParams: PartialResultParams) {
        self.textDocumentPositionParams = textDocumentPositionParams
        self.workDoneProgressParams = workDoneProgressParams
        self.partialResultParams = partialResultParams
    }

    private enum CodingKeys: String, CodingKey {
        case textDocumentPositionParams
        case workDoneProgressParams
        case partialResultParams
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        textDocumentPositionParams = try TextDocumentPositionParams(from: decoder)
        workDoneProgressParams = try container.decode(WorkDoneProgressParams.self, forKey: .workDoneProgressParams)
        partialResultParams = try container.decode(PartialResultParams.self, forKey: .partialResultParams)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try textDocumentPositionParams.encode(to: encoder)
        try container.encode(workDoneProgressParams, forKey: .workDoneProgressParams)
        try container.encode(partialResultParams, forKey: .partialResultParams)
    }
}

/// Moniker definition to match LSIF 0.5 moniker definition.
public struct Moniker: Codable {
    /// The scheme of the moniker. For example tsc or .Net
    public let scheme: String
    /// The identifier of the moniker. The value is opaque in LSIF however
    /// schema owners are allowed to define the structure if they want.
    public let identifier: String
    /// The scope in which the moniker is unique
    public let unique: UniquenessLevel
    /// The moniker kind if known.
    public let kind: MonikerKind?

    public init(scheme: String, identifier: String, unique: UniquenessLevel, kind: MonikerKind? = nil) {
        self.scheme = scheme
        self.identifier = identifier
        self.unique = unique
        self.kind = kind
    }

    private enum CodingKeys: String, CodingKey {
        case scheme
        case identifier
        case unique
        case kind
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scheme = try container.decode(String.self, forKey: .scheme)
        identifier = try container.decode(String.self, forKey: .identifier)
        unique = try container.decode(UniquenessLevel.self, forKey: .unique)
        kind = try container.decodeIfPresent(MonikerKind.self, forKey: .kind)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scheme, forKey: .scheme)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(unique, forKey: .unique)
        try container.encodeIfPresent(kind, forKey: .kind)
    }
}
