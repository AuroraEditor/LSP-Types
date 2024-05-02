//
//  DocumentDiagnostic.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

/// Client capabilities specific to diagnostic pull requests.
///
/// @since 3.17.0
public struct DiagnosticClientCapabilities: Codable, Equatable {
    /// Whether implementation supports dynamic registration.
    ///
    /// If this is set to `true` the client supports the new `(TextDocumentRegistrationOptions &
    /// StaticRegistrationOptions)` return value for the corresponding server capability as well.
    var dynamicRegistration: Bool?

    /// Whether the clients supports related documents for document diagnostic pulls.
    var relatedDocumentSupport: Bool?
}

/// Diagnostic options.
///
/// @since 3.17.0
public struct DiagnosticOptions: Codable, Equatable {
    /// An optional identifier under which the diagnostics are
    /// managed by the client.
    var identifier: String?

    /// Whether the language has inter file dependencies, meaning that editing code in one file can
    /// result in a different diagnostic set in another file. Inter file dependencies are common
    /// for most programming languages and typically uncommon for linters.
    let interFileDependencies: Bool

    /// The server provides support for workspace diagnostics as well.
    let workspaceDiagnostics: Bool

    let workDoneProgressOptions: WorkDoneProgressOptions

    public static func == (lhs: DiagnosticOptions, rhs: DiagnosticOptions) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

/// Diagnostic registration options.
///
/// @since 3.17.0
public struct DiagnosticRegistrationOptions: Codable, Equatable {
    let textDocumentRegistrationOptions: TextDocumentRegistrationOptions
    let diagnosticOptions: DiagnosticOptions
    let staticRegistrationOptions: StaticRegistrationOptions

    public static func == (lhs: DiagnosticRegistrationOptions, rhs: DiagnosticRegistrationOptions) -> Bool {
        return lhs.diagnosticOptions.identifier == rhs.diagnosticOptions.identifier
    }
}

enum DiagnosticServerCapabilities: Codable, Equatable {
    case options(DiagnosticOptions)
    case registrationOptions(DiagnosticRegistrationOptions)
}

/// Parameters of the document diagnostic request.
///
/// @since 3.17.0
public struct DocumentDiagnosticParams: Codable, Equatable {
    /// The text document.
    let textDocument: TextDocumentIdentifier

    /// The additional identifier provided during registration.
    let identifier: String?

    /// The result ID of a previous response if provided.
    let previousResultId: String?

    let workDoneProgressParams: WorkDoneProgressParams
    let partialResultParams: PartialResultParams

    public static func == (lhs: DocumentDiagnosticParams, rhs: DocumentDiagnosticParams) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

/// A diagnostic report with a full set of problems.
///
/// @since 3.17.0
public struct FullDocumentDiagnosticReport: Codable, Equatable {
    /// An optional result ID. If provided it will be sent on the next diagnostic request for the
    /// same document.
    var resultId: String?

    /// The actual items.
    let items: [Diagnostic]

    public static func == (lhs: FullDocumentDiagnosticReport,
                           rhs: FullDocumentDiagnosticReport) -> Bool {
        return lhs.resultId == rhs.resultId
    }
}

/// A diagnostic report indicating that the last returned report is still accurate.
///
/// A server can only return `unchanged` if result ids are provided.
///
/// @since 3.17.0
public struct UnchangedDocumentDiagnosticReport: Codable, Equatable {
    /// A result ID which will be sent on the next diagnostic request for the same document.
    let resultId: String
}

/// The document diagnostic report kinds.
///
/// @since 3.17.0
enum DocumentDiagnosticReportKind: Codable, Equatable {
    /// A diagnostic report with a full set of problems.
    case full(FullDocumentDiagnosticReport)
    /// A report indicating that the last returned report is still accurate.
    case unchanged(UnchangedDocumentDiagnosticReport)
}

/// A full diagnostic report with a set of related documents.
///
/// @since 3.17.0
public struct RelatedFullDocumentDiagnosticReport: Codable, Equatable {
    /// Diagnostics of related documents.
    ///
    /// This information is useful in programming languages where code in a file A can generate
    /// diagnostics in a file B which A depends on. An example of such a language is C/C++ where
    /// macro definitions in a file `a.cpp` result in errors in a header file `b.hpp`.
    ///
    /// @since 3.17.0
    var relatedDocuments: [URL: DocumentDiagnosticReportKind]?

    let fullDocumentDiagnosticReport: FullDocumentDiagnosticReport
}

/// An unchanged diagnostic report with a set of related documents.
///
/// @since 3.17.0
public struct RelatedUnchangedDocumentDiagnosticReport: Codable, Equatable {
    /// Diagnostics of related documents.
    ///
    /// This information is useful in programming languages where code in a file A can generate
    /// diagnostics in a file B which A depends on. An example of such a language is C/C++ where
    /// macro definitions in a file `a.cpp` result in errors in a header file `b.hpp`.
    ///
    /// @since 3.17.0
    var relatedDocuments: [URL: DocumentDiagnosticReportKind]?

    let unchangedDocumentDiagnosticReport: UnchangedDocumentDiagnosticReport
}

/// The result of a document diagnostic pull request.
///
/// A report can either be a full report containing all diagnostics for the requested document or
/// an unchanged report indicating that nothing has changed in terms of diagnostics in comparison
/// to the last pull request.
///
/// @since 3.17.0
enum DocumentDiagnosticReport: Codable, Equatable {
    /// A diagnostic report with a full set of problems.
    case full(RelatedFullDocumentDiagnosticReport)
    /// A report indicating that the last returned report is still accurate.
    case unchanged(RelatedUnchangedDocumentDiagnosticReport)
}

/// A partial result for a document diagnostic report.
///
/// @since 3.17.0
public struct DocumentDiagnosticReportPartialResult: Codable, Equatable {
    var relatedDocuments: [URL: DocumentDiagnosticReportKind]?
}

enum DocumentDiagnosticReportResult: Codable, Equatable {
    case report(DocumentDiagnosticReport)
    case partial(DocumentDiagnosticReportPartialResult)
}

/// Cancellation data returned from a diagnostic request.
///
/// If no data is provided, it defaults to `{ retrigger_request: true }`.
///
/// @since 3.17.0
public struct DiagnosticServerCancellationData: Codable, Equatable {
    let retriggerRequest: Bool

    init() {
        self.retriggerRequest = true
    }
}
