//
//  KMUpdateAssigneeStatus.swift
//  Kommunicate
//
//  Created by Abhijeet Ranjan on 05/03/24.
//

import Foundation

protocol KMUpdateAssigneeStatusDelegate: AnyObject {
    func updateAssigniStatus()
}

public enum KMUserStatus {
    case online
    case offline
    case away
    case `default`
}

struct KMUpdateAssigneeStatus {
    
    public static var shared =  KMUpdateAssigneeStatus()
    
    weak var delegate: KMUpdateAssigneeStatusDelegate?
    
    public var assigneeID: String?
    
    public var status: KMUserStatus = .default {
        didSet {
            delegate?.updateAssigniStatus()
        }
    }
    
}
