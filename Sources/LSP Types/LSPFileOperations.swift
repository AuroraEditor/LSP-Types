//
//  LSPFileOperation.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/01.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

public struct WorkspaceFileOperationsClientCapabilities: Codable {
    /// Whether the client supports dynamic registration for file
    /// requests/notifications.
    let dynamicRegistration: Bool?

    /// The client has support for sending didCreateFiles notifications.
    let didCreate: Bool?

    /// The server is interested in receiving willCreateFiles requests.
    let willCreate: Bool?

    /// The server is interested in receiving didRenameFiles requests.
    let didRename: Bool?

    /// The server is interested in receiving willRenameFiles requests.
    let willRename: Bool?

    /// The server is interested in receiving didDeleteFiles requests.
    let didDelete: Bool?

    /// The server is interested in receiving willDeleteFiles requests.
    let willDelete: Bool?

    enum CodingKeys: String, CodingKey {
        case dynamicRegistration
        case didCreate
        case willCreate
        case didRename
        case willRename
        case didDelete
        case willDelete
    }
}

public struct WorkspaceFileOperationsServerCapabilities: Codable {
    /// The server is interested in receiving didCreateFiles
    /// notifications.
    let didCreate: FileOperationRegistrationOptions?

    /// The server is interested in receiving willCreateFiles requests.
    let willCreate: FileOperationRegistrationOptions?

    /// The server is interested in receiving didRenameFiles
    /// notifications.
    let didRename: FileOperationRegistrationOptions?

    /// The server is interested in receiving willRenameFiles requests.
    let willRename: FileOperationRegistrationOptions?

    /// The server is interested in receiving didDeleteFiles file
    /// notifications.
    let didDelete: FileOperationRegistrationOptions?

    /// The server is interested in receiving willDeleteFiles file
    /// requests.
    let willDelete: FileOperationRegistrationOptions?

    enum CodingKeys: String, CodingKey {
        case didCreate
        case willCreate
        case didRename
        case willRename
        case didDelete
        case willDelete
    }
}

/// The options to register for file operations.
///
/// @since 3.16.0
public struct FileOperationRegistrationOptions: Codable {
    /// The actual filters.
    let filters: [FileOperationFilter]
}

/// A filter to describe in which file operation requests or notifications
/// the server is interested in.
///
/// @since 3.16.0
public struct FileOperationFilter: Codable {
    /// A Uri like `file` or `untitled`.
    let scheme: String?

    /// The actual file operation pattern.
    let pattern: FileOperationPattern
}

/// A pattern kind describing if a glob pattern matches a file a folder or
/// both.
///
/// @since 3.16.0
enum FileOperationPatternKind: String, Codable {
    /// The pattern matches a file only.
    case file

    /// The pattern matches a folder only.
    case folder
}

/// Matching options for the file operation pattern.
///
/// @since 3.16.0
public struct FileOperationPatternOptions: Codable {
    /// The pattern should be matched ignoring casing.
    let ignoreCase: Bool?

    enum CodingKeys: String, CodingKey {
        case ignoreCase
    }
}

/// A pattern to describe in which file operation requests or notifications
/// the server is interested in.
///
/// @since 3.16.0
public struct FileOperationPattern: Codable {
    /// The glob pattern to match. Glob patterns can have the following syntax:
    /// - `*` to match one or more characters in a path segment
    /// - `?` to match on one character in a path segment
    /// - `**` to match any number of path segments, including none
    /// - `{}` to group conditions (e.g. `**​/*.{ts,js}` matches all TypeScript
    ///   and JavaScript files)
    /// - `[]` to declare a range of characters to match in a path segment
    ///   (e.g., `example.[0-9]` to match on `example.0`, `example.1`, …)
    /// - `[!...]` to negate a range of characters to match in a path segment
    ///   (e.g., `example.[!0-9]` to match on `example.a`, `example.b`, but
    ///   not `example.0`)
    let glob: String

    /// Whether to match files or folders with this pattern.
    ///
    /// Matches both if undefined.
    let matches: FileOperationPatternKind?

    /// Additional options used during matching.
    let options: FileOperationPatternOptions?

    enum CodingKeys: String, CodingKey {
        case glob
        case matches
        case options
    }
}

/// The parameters sent in notifications/requests for user-initiated creation
/// of files.
///
/// @since 3.16.0
public struct CreateFilesParams: Codable {
    /// An array of all files/folders created in this operation.
    let files: [FileCreate]
}

/// Represents information on a file/folder create.
///
/// @since 3.16.0
public struct FileCreate: Codable {
    /// A file:// URI for the location of the file/folder being created.
    let uri: String
}

/// The parameters sent in notifications/requests for user-initiated renames
/// of files.
///
/// @since 3.16.0
public struct RenameFilesParams: Codable {
    /// An array of all files/folders renamed in this operation. When a folder
    /// is renamed, only the folder will be included, and not its children.
    let files: [FileRename]
}

/// Represents information on a file/folder rename.
///
/// @since 3.16.0
public struct FileRename: Codable {
    /// A file:// URI for the original location of the file/folder being renamed.
    let oldUri: String

    /// A file:// URI for the new location of the file/folder being renamed.
    let newUri: String

    enum CodingKeys: String, CodingKey {
        case oldUri = "old_uri"
        case newUri = "new_uri"
    }
}

/// The parameters sent in notifications/requests for user-initiated deletes
/// of files.
///
/// @since 3.16.0
public struct DeleteFilesParams: Codable {
    /// An array of all files/folders deleted in this operation.
    let files: [FileDelete]
}

/// Represents information on a file/folder delete.
///
/// @since 3.16.0
public struct FileDelete: Codable {
    /// A file:// URI for the location of the file/folder being deleted.
    let uri: String
}
