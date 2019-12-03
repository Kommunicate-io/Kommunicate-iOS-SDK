//
//  KMErrors.swift
//  Kommunicate
//
//  Created by Sunil on 29/11/19.
//
import Foundation

/// KMConversationError  enum is for conversation errors occurred during a creating conversation.
public enum KMConversationError : LocalizedError {

    /// Thrown when title is invalid.
    case invalidTitle
    /// Thrown when user is not logged in.
    case notLoggedIn
    /// Thrown when Internet is not available.
    case internet
    /// Thrown when API error.
    case api
    /// Custom error description.
    case custom(_ description: String)

    public var errorDescription: String? {
        var errorMessage: String
        switch self {
        case .invalidTitle:
            errorMessage = "Please pass a valid title."
        case .notLoggedIn:
            errorMessage = "User is not logged in."
        case .internet:
            errorMessage = "Internet is not available."
        case .api:
            errorMessage = "Failed to proccess API request."
        case .custom(let description):
            errorMessage = description
        }
        return errorMessage
    }

}
