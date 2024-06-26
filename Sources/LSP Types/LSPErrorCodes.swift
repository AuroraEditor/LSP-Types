//
//  LSPErrorCodes.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

//! In this module we only define constants for lsp specific error codes.
//! There are other error codes that are defined in the
//! [JSON RPC specification](https://www.jsonrpc.org/specification#error_object).

/// Defined in the LSP specification but in the range reserved for JSON-RPC error codes,
/// namely the -32099 to -32000 "Reserved for implementation-defined server-errors." range.
/// The code has, nonetheless, been left in this range for backwards compatibility reasons.
public let serverNotInitialized: Int64 = -32002

/// Defined in the LSP specification but in the range reserved for JSON-RPC error codes,
/// namely the -32099 to -32000 "Reserved for implementation-defined server-errors." range.
/// The code has, nonetheless, left in this range for backwards compatibility reasons.
public let unknownErrorCode: Int64 = -32001

/// This is the start range of LSP reserved error codes.
/// It doesn't denote a real error code.
///
/// @since 3.16.0
public let lspReservedErrorRangeStart: Int64 = -32899

/// A request failed but it was syntactically correct, e.g the
/// method name was known and the parameters were valid. The error
/// message should contain human readable information about why
/// the request failed.
///
/// @since 3.17.0
public let requestFailed: Int64 = -32803

/// The server cancelled the request. This error code should
/// only be used for requests that explicitly support being
/// server cancellable.
///
/// @since 3.17.0
public let serverCancelled: Int64 = -32802

/// The server detected that the content of a document got
/// modified outside normal conditions. A server should
/// NOT send this error code if it detects a content change
/// in it unprocessed messages. The result even computed
/// on an older state might still be useful for the client.
///
/// If a client decides that a result is not of any use anymore
/// the client should cancel the request.
public let contentModified: Int64 = -32801

/// The client has canceled a request and a server as detected
/// the cancel.
public let requestCancelled: Int64 = -32800

/// This is the end range of LSP reserved error codes.
/// It doesn't denote a real error code.
///
/// @since 3.16.0
public let lspReservedErrorRangeEnd: Int64 = -32800
