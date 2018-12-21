//
//  KMConversationViewConfiguration.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 14/12/18.
//

import Foundation

public struct KMConversationViewConfiguration {
    
    public var hideBackButton: Bool = false
    public var imageForBackButton: UIImage?
    public var nsNotificationNameForBackButtonAction: String = "BackButtonAction"
    
    public init() { }
}
