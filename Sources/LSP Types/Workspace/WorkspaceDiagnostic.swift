//
//  WorkspaceDiagnostic.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/04/28.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

/// Workspace client capabilities specific to diagnostic pull requests.
///
/// @since 3.17.0
public struct DiagnosticWorkspaceClientCapabilities: Codable, Equatable {
    /// Whether the client implementation supports a refresh request sent from
    /// the server to the client.
    ///
    /// Note that this event is global and will force the client to refresh all
    /// pulled diagnostics currently shown. It should be used with absolute care
    /// and is useful for situation where a server for example detects a project
    /// wide change that requires such a calculation.
    var refreshSupport: Bool?
}

/// A previous result ID in a workspace pull request.
///
/// @since 3.17.0
public struct PreviousResultId: Codable, Equatable {
    /// The URI for which the client knows a result ID.
    let uri: URL

    /// The value of the previous result ID.
    let value: String
}

/// Parameters of the workspace diagnostic request.
///
/// @since 3.17.0
public struct WorkspaceDiagnosticParams: Codable, Equatable {
    /// The additional identifier provided during registration.
    let identifier: String?

    /// The currently known diagnostic reports with their
    /// previous result ids.
    let previousResultIds: [PreviousResultId]

    let workDoneProgressParams: WorkDoneProgressParams
    let partialResultParams: PartialResultParams

    enum CodingKeys: String, CodingKey {
        case identifier, previousResultIds
        case workDoneProgressParams
        case partialResultParams
    }

    public static func == (lhs: WorkspaceDiagnosticParams,
                           rhs: WorkspaceDiagnosticParams) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

/// A full document diagnostic report for a workspace diagnostic result.
///
/// @since 3.17.0
public struct WorkspaceFullDocumentDiagnosticReport: Codable, Equatable {
    /// The URI for which diagnostic information is reported.
    let uri: URL

    /// The version number for which the diagnostics are reported.
    ///
    /// If the document is not marked as open, `None` can be provided.
    let version: Int64?

    let fullDocumentDiagnosticReport: FullDocumentDiagnosticReport

    enum CodingKeys: String, CodingKey {
        case uri, version
        case fullDocumentDiagnosticReport
    }
}

/// An unchanged document diagnostic report for a workspace diagnostic result.
///
/// @since 3.17.0
public struct WorkspaceUnchangedDocumentDiagnosticReport: Codable, Equatable {
    /// The URI for which diagnostic information is reported.
    let uri: URL

    /// The version number for which the diagnostics are reported.
    ///
    /// If the document is not marked as open, `None` can be provided.
    let version: Int64?

    let unchangedDocumentDiagnosticReport: UnchangedDocumentDiagnosticReport

    enum CodingKeys: String, CodingKey {
        case uri, version
        case unchangedDocumentDiagnosticReport
    }
}

/// A workspace diagnostic document report.
///
/// @since 3.17.0
enum WorkspaceDocumentDiagnosticReport: Codable, Equatable {
    case full(WorkspaceFullDocumentDiagnosticReport)
    case unchanged(WorkspaceUnchangedDocumentDiagnosticReport)
}

/// A workspace diagnostic report.
///
/// @since 3.17.0
public struct WorkspaceDiagnosticReport: Codable, Equatable {
    let items: [WorkspaceDocumentDiagnosticReport]
}

/// A partial result for a workspace diagnostic report.
///
/// @since 3.17.0
public struct WorkspaceDiagnosticReportPartialResult: Codable, Equatable {
    let items: [WorkspaceDocumentDiagnosticReport]
}

enum WorkspaceDiagnosticReportResult: Codable, Equatable {
    case report(WorkspaceDiagnosticReport)
    case partial(WorkspaceDiagnosticReportPartialResult)
}
