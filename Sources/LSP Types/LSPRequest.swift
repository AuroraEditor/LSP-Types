//
//  LSPRequest.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

/// The base protocol for LSP requests.
protocol LSPRequest {
    associatedtype Params: Codable
    associatedtype Result: Codable
    static var method: String { get }
}

/// The initialize request is sent as the first request from the client to the server.
enum Initialize: LSPRequest {
    typealias Params = InitializeParams
    typealias Result = InitializeResult
    static let method = "initialize"
}

/// The shutdown request is sent from the client to the server to shut down the server.
enum Shutdown: LSPRequest {
    typealias Params = EmptyParams
    typealias Result = EmptyParams
    static let method = "shutdown"
}

/// The show message request is sent from the server to the client to display a message and request an action.
enum ShowMessageRequest: LSPRequest {
    typealias Params = ShowMessageRequestParams
    typealias Result = MessageActionItem?
    static let method = "window/showMessageRequest"
}

/// The client/registerCapability request is sent from the server to the client to register a new capability.
enum RegisterCapability: LSPRequest {
    typealias Params = RegistrationParams
    typealias Result = EmptyParams
    static let method = "client/registerCapability"
}

/// The client/unregisterCapability request is sent from the server to the client to unregister a previously registered capability.
enum UnregisterCapability: LSPRequest {
    typealias Params = UnregistrationParams
    typealias Result = EmptyParams
    static let method = "client/unregisterCapability"
}

/// The completion request is sent from the client to the server to compute completion items at a given cursor position.
enum Completion: LSPRequest {
    typealias Params = CompletionParams
    typealias Result = CompletionResponse?
    static let method = "textDocument/completion"
}

/// The request is sent from the client to the server to resolve additional information for a given completion item.
enum ResolveCompletionItem: LSPRequest {
    typealias Params = CompletionItem
    typealias Result = CompletionItem
    static let method = "completionItem/resolve"
}

/// The hover request is sent from the client to the server to request hover information at a given text document position.
enum HoverRequest: LSPRequest {
    typealias Params = HoverParams
    typealias Result = Hover?
    static let method = "textDocument/hover"
}

/// The signature help request is sent from the client to the server to request signature information at a given cursor position.
enum SignatureHelpRequest: LSPRequest {
    typealias Params = SignatureHelpParams
    typealias Result = SignatureHelp?
    static let method = "textDocument/signatureHelp"
}

/// The goto declaration request is sent from the client to the server to resolve the declaration location of a symbol.
enum GotoDeclaration: LSPRequest {
    typealias Params = GotoDefinitionParams
    typealias Result = GotoDefinitionResponse?
    static let method = "textDocument/declaration"
}

/// The goto definition request is sent from the client to the server to resolve the definition location of a symbol.
enum GotoDefinition: LSPRequest {
    typealias Params = GotoDefinitionParams
    typealias Result = GotoDefinitionResponse?
    static let method = "textDocument/definition"
}

/// The references request is sent from the client to the server to resolve project-wide references for a symbol.
enum References: LSPRequest {
    typealias Params = ReferenceParams
    typealias Result = [LSPPosition]?
    static let method = "textDocument/references"
}

/// The goto type definition request is sent from the client to the server to resolve the type definition location of a symbol.
enum GotoTypeDefinition: LSPRequest {
    typealias Params = GotoDefinitionParams
    typealias Result = GotoDefinitionResponse?
    static let method = "textDocument/typeDefinition"
}

typealias GotoTypeDefinitionParams = GotoDefinitionParams;

/// The goto implementation request is sent from the client to the server to resolve the implementation location of a symbol.
enum GotoImplementation: LSPRequest {
    typealias Params = GotoTypeDefinitionParams
    typealias Result = GotoDefinitionResponse?
    static let method = "textDocument/implementation"
}

/// The document highlight request is sent from the client to the server to resolve a document highlights for a given text document position.
enum DocumentHighlightRequest: LSPRequest {
    typealias Params = DocumentHighlightParams
    typealias Result = [DocumentHighlight]?
    static let method = "textDocument/documentHighlight"
}

/// The document symbol request is sent from the client to the server to list all symbols found in a given text document.
enum DocumentSymbolRequest: LSPRequest {
    typealias Params = DocumentSymbolParams
    typealias Result = DocumentSymbolResponse?
    static let method = "textDocument/documentSymbol"
}

/// The workspace symbol request is sent from the client to the server to list project-wide symbols matching a query string.
enum WorkspaceSymbolRequest: LSPRequest {
    typealias Params = WorkspaceSymbolParams
    typealias Result = WorkspaceSymbolResponse?
    static let method = "workspace/symbol"
}

/// The workspace symbol resolve request is sent from the client to the server to resolve additional information for a workspace symbol.
enum WorkspaceSymbolResolve: LSPRequest {
    typealias Params = WorkspaceSymbol
    typealias Result = WorkspaceSymbol
    static let method = "workspaceSymbol/resolve"
}

/// The execute command request is sent from the client to the server to trigger command execution on the server.
enum ExecuteCommand: LSPRequest {
    typealias Params = ExecuteCommandParams
    typealias Result = LSPAny?
    static let method = "workspace/executeCommand"
}

/// The document will save request is sent from the client to the server before the document is actually saved.
enum WillSaveWaitUntil: LSPRequest {
    typealias Params = WillSaveTextDocumentParams
    typealias Result = [TextEdit]?
    static let method = "textDocument/willSaveWaitUntil"
}

/// The workspace edit request is sent from the server to the client to modify resources on the client side.
enum ApplyWorkspaceEdit: LSPRequest {
    typealias Params = ApplyWorkspaceEditParams
    typealias Result = ApplyWorkspaceEditResponse
    static let method = "workspace/applyEdit"
}

/// The workspace configuration request is sent from the server to the client to fetch configuration settings.
enum WorkspaceConfiguration: LSPRequest {
    typealias Params = ConfigurationParams
    typealias Result = [LSPAny]
    static let method = "workspace/configuration"
}

/// The code action request is sent from the client to the server to compute commands for a given text document and range.
enum CodeActionRequest: LSPRequest {
    typealias Params = CodeActionParams
    typealias Result = CodeActionResponse?
    static let method = "textDocument/codeAction"
}

/// The code action resolve request is sent from the client to the server to resolve additional information for a given code action.
enum CodeActionResolveRequest: LSPRequest {
    typealias Params = CodeAction
    typealias Result = CodeAction
    static let method = "codeAction/resolve"
}

/// The code lens request is sent from the client to the server to compute code lenses for a given text document.
enum CodeLensRequest: LSPRequest {
    typealias Params = CodeLensParams
    typealias Result = [CodeLens]?
    static let method = "textDocument/codeLens"
}

/// The code lens resolve request is sent from the client to the server to resolve the command for a given code lens item.
enum CodeLensResolve: LSPRequest {
    typealias Params = CodeLens
    typealias Result = CodeLens
    static let method = "codeLens/resolve"
}

/// The document links request is sent from the client to the server to request the location of links in a document.
enum DocumentLinkRequest: LSPRequest {
    typealias Params = DocumentLinkParams
    typealias Result = [DocumentLink]?
    static let method = "textDocument/documentLink"
}

/// The document link resolve request is sent from the client to the server to resolve the target of a given document link.
enum DocumentLinkResolve: LSPRequest {
    typealias Params = DocumentLink
    typealias Result = DocumentLink
    static let method = "documentLink/resolve"
}

/// The document formatting request is sent from the server to the client to format a whole document.
enum Formatting: LSPRequest {
    typealias Params = DocumentFormattingParams
    typealias Result = [TextEdit]?
    static let method = "textDocument/formatting"
}

/// The document range formatting request is sent from the client to the server to format a given range in a document.
enum RangeFormatting: LSPRequest {
    typealias Params = DocumentRangeFormattingParams
    typealias Result = [TextEdit]?
    static let method = "textDocument/rangeFormatting"
}

/// The document on type formatting request is sent from the client to the server to format parts of the document during typing.
enum OnTypeFormatting: LSPRequest {
    typealias Params = DocumentOnTypeFormattingParams
    typealias Result = [TextEdit]?
    static let method = "textDocument/onTypeFormatting"
}

/// The linked editing request is sent from the client to the server to return the ranges that can be edited together.
enum LinkedEditingRange: LSPRequest {
    typealias Params = LinkedEditingRangeParams
    typealias Result = LinkedEditingRanges?
    static let method = "textDocument/linkedEditingRange"
}

/// The rename request is sent from the client to the server to perform a workspace-wide rename of a symbol.
enum Rename: LSPRequest {
    typealias Params = RenameParams
    typealias Result = WorkspaceEdit?
    static let method = "textDocument/rename"
}

/// The document color request is sent from the client to the server to list all color references found in a given text document.
enum DocumentColor: LSPRequest {
    typealias Params = DocumentColorParams
    typealias Result = [ColorInformation]
    static let method = "textDocument/documentColor"
}

/// The color presentation request is sent from the client to the server to obtain a list of presentations for a color value at a given location.
enum ColorPresentationRequest: LSPRequest {
    typealias Params = ColorPresentationParams
    typealias Result = [ColorPresentation]
    static let method = "textDocument/colorPresentation"
}

/// The folding range request is sent from the client to the server to return all folding ranges found in a given text document.
enum FoldingRangeRequest: LSPRequest {
    typealias Params = FoldingRangeParams
    typealias Result = [FoldingRange]?
    static let method = "textDocument/foldingRange"
}

/// The prepare rename request is sent from the client to the server to setup and test the validity of a rename operation at a given location.
enum PrepareRenameRequest: LSPRequest {
    typealias Params = TextDocumentPositionParams
    typealias Result = PrepareRenameResponse?
    static let method = "textDocument/prepareRename"
}

/// The selection range request is sent from the client to the server to return suggested selection ranges at given positions.
enum SelectionRangeRequest: LSPRequest {
    typealias Params = SelectionRangeParams
    typealias Result = [SelectionRange]?
    static let method = "textDocument/selectionRange"
}

/// The call hierarchy prepare request is sent from the client to the server to resolve a call hierarchy item at a given text document position.
enum CallHierarchyPrepare: LSPRequest {
    typealias Params = CallHierarchyPrepareParams
    typealias Result = [CallHierarchyItem]?
    static let method = "textDocument/prepareCallHierarchy"
}

/// The call hierarchy incoming calls request is sent from the client to the server to resolve the incoming calls for a given call hierarchy item.
enum CallHierarchyIncomingCalls: LSPRequest {
    typealias Params = CallHierarchyIncomingCallsParams
    typealias Result = [CallHierarchyIncomingCall]?
    static let method = "callHierarchy/incomingCalls"
}

/// The call hierarchy outgoing calls request is sent from the client to the server to resolve the outgoing calls for a given call hierarchy item.
enum CallHierarchyOutgoingCalls: LSPRequest {
    typealias Params = CallHierarchyOutgoingCallsParams
    typealias Result = [CallHierarchyOutgoingCall]?
    static let method = "callHierarchy/outgoingCalls"
}

/// The semantic tokens full request is sent from the client to the server to request semantic tokens for a whole document.
enum SemanticTokensFullRequest: LSPRequest {
    typealias Params = SemanticTokensParams
    typealias Result = SemanticTokensResult?
    static let method = "textDocument/semanticTokens/full"
}

/// The semantic tokens full delta request is sent from the client to the server to request semantic tokens delta for a document.
enum SemanticTokensFullDeltaRequest: LSPRequest {
    typealias Params = SemanticTokensDeltaParams
    typealias Result = SemanticTokensFullDeltaResult?
    static let method = "textDocument/semanticTokens/full/delta"
}

/// The semantic tokens range request is sent from the client to the server to request semantic tokens for a range in a document.
enum SemanticTokensRangeRequest: LSPRequest {
    typealias Params = SemanticTokensRangeParams
    typealias Result = SemanticTokensRangeResult?
    static let method = "textDocument/semanticTokens/range"
}

/// The semantic tokens refresh request is sent from the server to the client to ask the client to refresh semantic tokens for a document.
enum SemanticTokensRefresh: LSPRequest {
    typealias Params = EmptyParams
    typealias Result = EmptyParams
    static let method = "workspace/semanticTokens/refresh"
}

/// The code lens refresh request is sent from the server to the client to ask the client to refresh code lenses for a document.
enum CodeLensRefresh: LSPRequest {
    typealias Params = EmptyParams
    typealias Result = EmptyParams
    static let method = "workspace/codeLens/refresh"
}

/// The will create files request is sent from the client to the server before files are actually created.
enum WillCreateFiles: LSPRequest {
    typealias Params = CreateFilesParams
    typealias Result = WorkspaceEdit?
    static let method = "workspace/willCreateFiles"
}

/// The will rename files request is sent from the client to the server before files are actually renamed.
enum WillRenameFiles: LSPRequest {
    typealias Params = RenameFilesParams
    typealias Result = WorkspaceEdit?
    static let method = "workspace/willRenameFiles"
}

/// The will delete files request is sent from the client to the server before files are actually deleted.
enum WillDeleteFiles: LSPRequest {
    typealias Params = DeleteFilesParams
    typealias Result = WorkspaceEdit?
    static let method = "workspace/willDeleteFiles"
}

/// The show document request is sent from the server to the client to ask the client to display a particular document.
enum ShowDocument: LSPRequest {
    typealias Params = ShowDocumentParams
    typealias Result = ShowDocumentResult
    static let method = "window/showDocument"
}

/// The moniker request is sent from the client to the server to request the ranges of the monikers found in a given text document.
enum MonikerRequest: LSPRequest {
    typealias Params = MonikerParams
    typealias Result = [Moniker]?
    static let method = "textDocument/moniker"
}

/// The inlay hint request is sent from the client to the server to request inlay hints for a given text document and range.
enum InlayHintRequest: LSPRequest {
    typealias Params = InlayHintParams
    typealias Result = [InlayHint]?
    static let method = "textDocument/inlayHint"
}

/// The inlay hint resolve request is sent from the client to the server to resolve additional information for a given inlay hint.
enum InlayHintResolveRequest: LSPRequest {
    typealias Params = InlayHint
    typealias Result = InlayHint
    static let method = "inlayHint/resolve"
}

// The inlay hint refresh request is sent from the server to the client to ask the client to refresh inlay hints for a document.
enum InlayHintRefreshRequest: LSPRequest {
    typealias Params = EmptyParams
    typealias Result = EmptyParams
    static let method = "workspace/inlayHint/refresh"
}
/// The inline value request is sent from the client to the server to request inline values for a given text document and range.
enum InlineValueRequest: LSPRequest {
    typealias Params = InlineValueParams
    typealias Result = InlineValue?
    static let method = "textDocument/inlineValue"
}
/// The inline value refresh request is sent from the server to the client to ask the client to refresh inline values for a document.
enum InlineValueRefreshRequest: LSPRequest {
    typealias Params = EmptyParams
    typealias Result = EmptyParams
    static let method = "workspace/inlineValue/refresh"
}
/// The document diagnostic request is sent from the client to the server to request diagnostics for a given text document.
enum DocumentDiagnosticRequest: LSPRequest {
    typealias Params = DocumentDiagnosticParams
    typealias Result = DocumentDiagnosticReportResult
    static let method = "textDocument/diagnostic"
}
/// The workspace diagnostic request is sent from the client to the server to request workspace-wide diagnostics.
enum WorkspaceDiagnosticRequest: LSPRequest {
    typealias Params = WorkspaceDiagnosticParams
    typealias Result = WorkspaceDiagnosticReportResult
    static let method = "workspace/diagnostic"
}
/// The workspace diagnostic refresh request is sent from the server to the client to ask the client to refresh workspace-wide diagnostics.
enum WorkspaceDiagnosticRefresh: LSPRequest {
    typealias Params = EmptyParams
    typealias Result = EmptyParams
    static let method = "workspace/diagnostic/refresh"
}
/// The type hierarchy prepare request is sent from the client to the server to resolve a type hierarchy item at a given text document position.
enum TypeHierarchyPrepare: LSPRequest {
    typealias Params = TypeHierarchyPrepareParams
    typealias Result = [TypeHierarchyItem]?
    static let method = "textDocument/prepareTypeHierarchy"
}
/// The type hierarchy supertypes request is sent from the client to the server to resolve the supertypes for a given type hierarchy item.
enum TypeHierarchySupertypes: LSPRequest {
    typealias Params = TypeHierarchySupertypesParams
    typealias Result = [TypeHierarchyItem]?
    static let method = "typeHierarchy/supertypes"
}
/// The type hierarchy subtypes request is sent from the client to the server to resolve the subtypes for a given type hierarchy item.
enum TypeHierarchySubtypes: LSPRequest {
    typealias Params = TypeHierarchySubtypesParams
    typealias Result = [TypeHierarchyItem]?
    static let method = "typeHierarchy/subtypes"
}
/// The work done progress create request is sent from the server to the client to ask the client to create a work done progress.
enum WorkDoneProgressCreate: LSPRequest {
    typealias Params = WorkDoneProgressCreateParams
    typealias Result = EmptyParams
    static let method = "window/workDoneProgress/create"
}
/// The workspace folders request is sent from the server to the client to fetch the open workspace folders.
enum WorkspaceFoldersRequest: LSPRequest {
    typealias Params = EmptyParams
    typealias Result = [WorkspaceFolder]?
    static let method = "workspace/workspaceFolders"
}
