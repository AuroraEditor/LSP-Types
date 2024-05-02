//
//  LSPTrace.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/04/28.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

public struct SetTraceParams: Codable {
    /// The new value that should be assigned to the trace setting.
    let value: TraceValue
}

/// A TraceValue represents the level of verbosity with which the server systematically
/// reports its execution trace using `LogTrace` notifications.
///
/// The initial trace value is set by the client at initialization and can be modified
/// later using the `SetTrace` notification.
enum TraceValue: String, Codable {
    /// The server should not send any `$/logTrace` notification
    case off
    /// The server should not add the 'verbose' field in the `LogTraceParams`
    case messages
    case verbose
}

public struct LogTraceParams: Codable {
    /// The message to be logged.
    let message: String
    /// Additional information that can be computed if the `trace` configuration
    /// is set to `'verbose'`
    let verbose: String?

    enum CodingKeys: String, CodingKey {
        case message
        case verbose
    }
}
