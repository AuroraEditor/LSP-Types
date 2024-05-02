//
//  SignatureHelp.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

public struct SignatureInformationSettings: Codable {
    /// Client supports the follow content formats for the documentation
    /// property. The order describes the preferred format of the client.
    let documentationFormat: [MarkupKind]?

    let parameterInformation: ParameterInformationSettings?

    /// The client support the `activeParameter` property on `SignatureInformation`
    /// literal.
    ///
    /// @since 3.16.0
    let activeParameterSupport: Bool?

    enum CodingKeys: String, CodingKey {
        case documentationFormat
        case parameterInformation
        case activeParameterSupport
    }
}

public struct ParameterInformationSettings: Codable {
    /// The client supports processing label offsets instead of a
    /// simple label string.
    ///
    /// @since 3.14.0
    let labelOffsetSupport: Bool?

    enum CodingKeys: String, CodingKey {
        case labelOffsetSupport
    }
}

public struct SignatureHelpClientCapabilities: Codable {
    /// Whether completion supports dynamic registration.
    let dynamicRegistration: Bool?

    /// The client supports the following `SignatureInformation`
    /// specific properties.
    let signatureInformation: SignatureInformationSettings?

    /// The client supports to send additional context information for a
    /// `textDocument/signatureHelp` request. A client that opts into
    /// contextSupport will also support the `retriggerCharacters` on
    /// `SignatureHelpOptions`.
    ///
    /// @since 3.15.0
    let contextSupport: Bool?

    enum CodingKeys: String, CodingKey {
        case dynamicRegistration
        case signatureInformation
        case contextSupport
    }
}

/// Signature help options.
public struct SignatureHelpOptions: Codable {
    /// The characters that trigger signature help automatically.
    let triggerCharacters: [String]?

    /// List of characters that re-trigger signature help.
    /// These trigger characters are only active when signature help is already showing. All trigger characters
    /// are also counted as re-trigger characters.
    let retriggerCharacters: [String]?

    let workDoneProgressOptions: WorkDoneProgressOptions
}

/// Signature help options.
public struct SignatureHelpRegistrationOptions: Codable {
    let textDocumentRegistrationOptions: TextDocumentRegistrationOptions
}

/// Signature help options.
public struct SignatureHelpTriggerKind: RawRepresentable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Signature help was invoked manually by the user or by a command.
    static let invoked = SignatureHelpTriggerKind(rawValue: 1)

    /// Signature help was triggered by a trigger character.
    static let triggerCharacter = SignatureHelpTriggerKind(rawValue: 2)

    /// Signature help was triggered by the cursor moving or by the document content changing.
    static let contentChange = SignatureHelpTriggerKind(rawValue: 3)
}

public struct SignatureHelpParams: Codable {
    /// The signature help context. This is only available if the client specifies
    /// to send this using the client capability  `textDocument.signatureHelp.contextSupport === true`
    let context: SignatureHelpContext?

    let textDocumentPositionParams: TextDocumentPositionParams

    let workDoneProgressParams: WorkDoneProgressParams
}

public struct SignatureHelpContext: Codable {
    /// Action that caused signature help to be triggered.
    let triggerKind: SignatureHelpTriggerKind

    /// Character that caused signature help to be triggered.
    /// This is undefined when `triggerKind !== SignatureHelpTriggerKind.TriggerCharacter`
    let triggerCharacter: String?

    /// `true` if signature help was already showing when it was triggered.
    /// Retriggers occur when the signature help is already active and can be caused by actions such as
    /// typing a trigger character, a cursor move, or document content changes.
    let isRetrigger: Bool

    /// The currently active `SignatureHelp`.
    /// The `activeSignatureHelp` has its `SignatureHelp.activeSignature` field updated based on
    /// the user navigating through available signatures.
    let activeSignatureHelp: SignatureHelp?

    enum CodingKeys: String, CodingKey {
        case triggerKind
        case triggerCharacter
        case isRetrigger
        case activeSignatureHelp
    }
}

/// Signature help represents the signature of something
/// callable. There can be multiple signature but only one
/// active and only one active parameter.
public struct SignatureHelp: Codable {
    /// One or more signatures.
    let signatures: [SignatureInformation]

    /// The active signature.
    let activeSignature: UInt32?

    /// The active parameter of the active signature.
    let activeParameter: UInt32?

    enum CodingKeys: String, CodingKey {
        case signatures
        case activeSignature
        case activeParameter
    }
}

/// Represents the signature of something callable. A signature
/// can have a label, like a function-name, a doc-comment, and
/// a set of parameters.
public struct SignatureInformation: Codable {
    /// The label of this signature. Will be shown in
    /// the UI.
    let label: String

    /// The human-readable doc-comment of this signature. Will be shown
    /// in the UI but can be omitted.
    let documentation: Documentation?

    /// The parameters of this signature.
    let parameters: [ParameterInformation]?

    /// The index of the active parameter.
    ///
    /// If provided, this is used in place of `SignatureHelp.activeParameter`.
    ///
    /// @since 3.16.0
    let activeParameter: UInt32?

    enum CodingKeys: String, CodingKey {
        case label
        case documentation
        case parameters
        case activeParameter
    }
}

/// Represents a parameter of a callable-signature. A parameter can
/// have a label and a doc-comment.
public struct ParameterInformation: Codable {
    /// The label of this parameter information.
    ///
    /// Either a string or an inclusive start and exclusive end offsets within its containing
    /// signature label. (see SignatureInformation.label). *Note*: A label of type string must be
    /// a substring of its containing signature label.
    let label: ParameterLabel

    /// The human-readable doc-comment of this parameter. Will be shown
    /// in the UI but can be omitted.
    let documentation: Documentation?

    enum CodingKeys: String, CodingKey {
        case label
        case documentation
    }
}

enum ParameterLabel: Codable {
    case simple(String)
    case labelOffsets([UInt32])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .simple(string)
        } else if let offsets = try? container.decode([UInt32].self) {
            self = .labelOffsets(offsets)
        } else {
            throw DecodingError.typeMismatch(ParameterLabel.self,
                                             DecodingError.Context(codingPath: decoder.codingPath,
                                                                   debugDescription: "Invalid ParameterLabel"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .simple(let string):
            try container.encode(string)
        case .labelOffsets(let offsets):
            try container.encode(offsets)
        }
    }
}
