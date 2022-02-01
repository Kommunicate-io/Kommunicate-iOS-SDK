//
//  Bundle+Extension.swift
//  Kommunicate_Example
//
//  Created by k on 19/04/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

public extension Bundle {
    static var kommunicate: Bundle {
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(for: Kommunicate.self)
        #endif
    }
}
