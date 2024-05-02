//
//  WorkspaceFolders.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/04/28.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

public struct WorkspaceFoldersServerCapabilities: Codable, Equatable {
    /// The server has support for workspace folders
    let supported: Bool?

    /// Whether the server wants to receive workspace folder
    /// change notifications.
    ///
    /// If a string is provided, the string is treated as an ID
    /// under which the notification is registered on the client
    /// side. The ID can be used to unregister for these events
    /// using the `client/unregisterCapability` request.
    let changeNotifications: OneOf<Bool, String>?

    enum CodingKeys: String, CodingKey {
        case supported
        case changeNotifications
    }

    init(supported: Bool? = nil,
         changeNotifications: OneOf<Bool, String>? = nil) {
        self.supported = supported
        self.changeNotifications = changeNotifications
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        supported = try container.decodeIfPresent(Bool.self, forKey: .supported)
        changeNotifications = try container.decodeIfPresent(OneOf<Bool,
                                                            String>.self,
                                                            forKey: .changeNotifications)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(supported,
                                      forKey: .supported)
        try container.encodeIfPresent(changeNotifications,
                                      forKey: .changeNotifications)
    }

    public static func == (lhs: WorkspaceFoldersServerCapabilities,
                           rhs: WorkspaceFoldersServerCapabilities) -> Bool {
        return lhs == rhs
    }
}

public struct WorkspaceFolder: Codable, Equatable, Comparable {
    /// The associated URI for this workspace folder.
    let uri: URL

    /// The name of the workspace folder. Defaults to the uri's basename.
    let name: String

    public static func < (lhs: WorkspaceFolder, rhs: WorkspaceFolder) -> Bool {
        return lhs.uri.absoluteString < rhs.uri.absoluteString
    }
}

public struct DidChangeWorkspaceFoldersParams: Codable, Equatable {
    /// The actual workspace folder change event.
    let event: WorkspaceFoldersChangeEvent
}

/// The workspace folder change event.
public struct WorkspaceFoldersChangeEvent: Codable, Equatable {
    /// The array of added workspace folders
    let added: [WorkspaceFolder]

    /// The array of the removed workspace folders
    let removed: [WorkspaceFolder]

    init(added: [WorkspaceFolder] = [], removed: [WorkspaceFolder] = []) {
        self.added = added
        self.removed = removed
    }
}
