//
//  LSPProgress.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

typealias ProgressToken = NumberOrString

/// The progress notification is sent from the server to the client to ask
/// the client to indicate progress.
public struct ProgressParams: Codable {
    /// The progress token provided by the client.
    let token: ProgressToken

    /// The progress data.
    let value: ProgressParamsValue
}

enum ProgressParamsValue: Codable {
    case workDone(WorkDoneProgress)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let workDone = try? container.decode(WorkDoneProgress.self) {
            self = .workDone(workDone)
        } else {
            throw DecodingError.typeMismatch(ProgressParamsValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid ProgressParamsValue"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .workDone(let workDone):
            try container.encode(workDone)
        }
    }
}

/// The `window/workDoneProgress/create` request is sent
/// from the server to the client to ask the client to create a work done progress.
public struct WorkDoneProgressCreateParams: Codable {
    /// The token to be used to report progress.
    let token: ProgressToken
}

/// The `window/workDoneProgress/cancel` notification is sent from the client
/// to the server to cancel a progress initiated on the server side using the `window/workDoneProgress/create`.
public struct WorkDoneProgressCancelParams: Codable {
    /// The token to be used to report progress.
    let token: ProgressToken
}

/// Options to signal work done progress support in server capabilities.
public struct WorkDoneProgressOptions: Codable {
    let workDoneProgress: Bool?

    enum CodingKeys: String, CodingKey {
        case workDoneProgress
    }
}

/// An optional token that a server can use to report work done progress
public struct WorkDoneProgressParams: Codable {
    let workDoneToken: ProgressToken?

    enum CodingKeys: String, CodingKey {
        case workDoneToken
    }
}

public struct WorkDoneProgressBegin: Codable {
    /// Mandatory title of the progress operation. Used to briefly inform
    /// about the kind of operation being performed.
    /// Examples: "Indexing" or "Linking dependencies".
    let title: String

    /// Controls if a cancel button should show to allow the user to cancel the
    /// long running operation. Clients that don't support cancellation are allowed
    /// to ignore the setting.
    let cancellable: Bool?

    /// Optional, more detailed associated progress message. Contains
    /// complementary information to the `title`.
    ///
    /// Examples: "3/25 files", "project/src/module2", "node_modules/some_dep".
    /// If unset, the previous progress message (if any) is still valid.
    let message: String?

    /// Optional progress percentage to display (value 100 is considered 100%).
    /// If not provided infinite progress is assumed and clients are allowed
    /// to ignore the `percentage` value in subsequent in report notifications.
    ///
    /// The value should be steadily rising. Clients are free to ignore values
    /// that are not following this rule. The value range is [0, 100]
    let percentage: UInt32?

    enum CodingKeys: String, CodingKey {
        case title
        case cancellable
        case message
        case percentage
    }
}

public struct WorkDoneProgressReport: Codable {
    /// Controls if a cancel button should show to allow the user to cancel the
    /// long running operation. Clients that don't support cancellation are allowed
    /// to ignore the setting.
    let cancellable: Bool?

    /// Optional, more detailed associated progress message. Contains
    /// complementary information to the `title`.
    /// Examples: "3/25 files", "project/src/module2", "node_modules/some_dep".
    /// If unset, the previous progress message (if any) is still valid.
    let message: String?

    /// Optional progress percentage to display (value 100 is considered 100%).
    /// If not provided infinite progress is assumed and clients are allowed
    /// to ignore the `percentage` value in subsequent in report notifications.
    ///
    /// The value should be steadily rising. Clients are free to ignore values
    /// that are not following this rule. The value range is [0, 100]
    let percentage: UInt32?

    enum CodingKeys: String, CodingKey {
        case cancellable
        case message
        case percentage
    }
}

public struct WorkDoneProgressEnd: Codable {
    /// Optional, more detailed associated progress message. Contains
    /// complementary information to the `title`.
    /// Examples: "3/25 files", "project/src/module2", "node_modules/some_dep".
    /// If unset, the previous progress message (if any) is still valid.
    let message: String?

    enum CodingKeys: String, CodingKey {
        case message
    }
}

enum WorkDoneProgress: Codable {
    case begin(WorkDoneProgressBegin)
    case report(WorkDoneProgressReport)
    case end(WorkDoneProgressEnd)

    enum CodingKeys: String, CodingKey {
        case kind
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(String.self, forKey: .kind)

        switch kind.lowercased() {
        case "begin":
            let begin = try WorkDoneProgressBegin(from: decoder)
            self = .begin(begin)
        case "report":
            let report = try WorkDoneProgressReport(from: decoder)
            self = .report(report)
        case "end":
            let end = try WorkDoneProgressEnd(from: decoder)
            self = .end(end)
        default:
            throw DecodingError.dataCorruptedError(forKey: .kind, in: container, debugDescription: "Invalid WorkDoneProgress kind")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .begin(let begin):
            try container.encode("begin", forKey: .kind)
            try begin.encode(to: encoder)
        case .report(let report):
            try container.encode("report", forKey: .kind)
            try report.encode(to: encoder)
        case .end(let end):
            try container.encode("end", forKey: .kind)
            try end.encode(to: encoder)
        }
    }
}
