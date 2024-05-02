//
//  LSPNotification.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

/// The base protocol for LSP notifications.
protocol LSPNotification {
    associatedtype Params: Codable
    static var method: String { get }
}

/// The cancel notification is sent from the client to the server to cancel a request.
enum Cancel: LSPNotification {
    typealias Params = CancelParams
    static let method = "$/cancelRequest"
}

/// The set trace notification is sent from the client to the server to modify the trace setting of the server.
enum SetTrace: LSPNotification {
    typealias Params = SetTraceParams
    static let method = "$/setTrace"
}

/// The log trace notification is sent from the server to the client to log the trace of the server's execution.
enum LogTrace: LSPNotification {
    typealias Params = LogTraceParams
    static let method = "$/logTrace"
}

/// The initialized notification is sent from the client to the server after the client received the result of the initialize request.
enum Initialized: LSPNotification {
    typealias Params = InitializedParams
    static let method = "initialized"
}

/// The exit notification is sent from the client to the server to ask the server to exit its process.
enum Exit: LSPNotification {
    typealias Params = EmptyParams
    static let method = "exit"
}

struct EmptyParams: Codable {}

/// The show message notification is sent from the server to the client to ask the client to display a particular message in the user interface.
enum ShowMessage: LSPNotification {
    typealias Params = ShowMessageParams
    static let method = "window/showMessage"
}

/// The log message notification is sent from the server to the client to ask the client to log a particular message.
enum LogMessage: LSPNotification {
    typealias Params = LogMessageParams
    static let method = "window/logMessage"
}

/// The telemetry event notification is sent from the server to the client to ask the client to log a telemetry event.
enum TelemetryEvent: LSPNotification {
    typealias Params = LSPAny
    static let method = "telemetry/event"
}

/// The did change configuration notification is sent from the client to the server to signal the change of configuration settings.
enum DidChangeConfiguration: LSPNotification {
    typealias Params = DidChangeConfigurationParams
    static let method = "workspace/didChangeConfiguration"
}

/// The did open text document notification is sent from the client to the server to signal newly opened text documents.
enum DidOpenTextDocument: LSPNotification {
    typealias Params = DidOpenTextDocumentParams
    static let method = "textDocument/didOpen"
}

/// The did change text document notification is sent from the client to the server to signal changes to a text document.
enum DidChangeTextDocument: LSPNotification {
    typealias Params = DidChangeTextDocumentParams
    static let method = "textDocument/didChange"
}

/// The will save text document notification is sent from the client to the server before the document is actually saved.
enum WillSaveTextDocument: LSPNotification {
    typealias Params = WillSaveTextDocumentParams
    static let method = "textDocument/willSave"
}

/// The did close text document notification is sent from the client to the server when the document got closed in the client.
enum DidCloseTextDocument: LSPNotification {
    typealias Params = DidCloseTextDocumentParams
    static let method = "textDocument/didClose"
}

/// The did save text document notification is sent from the client to the server when the document was saved in the client.
enum DidSaveTextDocument: LSPNotification {
    typealias Params = DidSaveTextDocumentParams
    static let method = "textDocument/didSave"
}

/// The did change watched files notification is sent from the client to the server when the client detects changes to files and folders watched by the language client.
enum DidChangeWatchedFiles: LSPNotification {
    typealias Params = DidChangeWatchedFilesParams
    static let method = "workspace/didChangeWatchedFiles"
}

/// The did change workspace folders notification is sent from the client to the server to inform the server about workspace folder configuration changes.
enum DidChangeWorkspaceFolders: LSPNotification {
    typealias Params = DidChangeWorkspaceFoldersParams
    static let method = "workspace/didChangeWorkspaceFolders"
}

/// The publish diagnostics notification is sent from the server to the client to signal results of validation runs.
enum PublishDiagnostics: LSPNotification {
    typealias Params = PublishDiagnosticsParams
    static let method = "textDocument/publishDiagnostics"
}

/// The progress notification is sent from the server to the client to ask the client to indicate progress.
enum Progress: LSPNotification {
    typealias Params = ProgressParams
    static let method = "$/progress"
}

/// The work done progress cancel notification is sent from the client to the server to cancel a progress initiated on the server side.
enum WorkDoneProgressCancel: LSPNotification {
    typealias Params = WorkDoneProgressCancelParams
    static let method = "window/workDoneProgress/cancel"
}

/// The did create files notification is sent from the client to the server when files were created from within the client.
enum DidCreateFiles: LSPNotification {
    typealias Params = CreateFilesParams
    static let method = "workspace/didCreateFiles"
}

/// The did rename files notification is sent from the client to the server when files were renamed from within the client.
enum DidRenameFiles: LSPNotification {
    typealias Params = RenameFilesParams
    static let method = "workspace/didRenameFiles"
}

/// The did delete files notification is sent from the client to the server when files were deleted from within the client.
enum DidDeleteFiles: LSPNotification {
    typealias Params = DeleteFilesParams
    static let method = "workspace/didDeleteFiles"
}
