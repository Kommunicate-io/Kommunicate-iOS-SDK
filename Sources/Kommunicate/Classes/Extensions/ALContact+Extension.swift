//
//  ALContact+Extension.swift
//  Kommunicate
//
//  Created by Mukesh on 27/07/20.
//

import Foundation
import KommunicateCore_iOS_SDK

extension ALContact {
    static let AwayMode: Int = 2

    var isInAwayMode: Bool {
        guard let status = status else { return false }
        return status.intValue == ALContact.AwayMode
    }
}
