//
//  Style+Color.swift
//  ApplozicSwift
//
//  Created by Mukesh on 17/02/20.
//

import Foundation

extension Style {
    enum Color {
        enum Background: Int {
            case mediumGray = 0xf0f0f0
        }
    }
}

extension UIColor {
    static func background(_ color: Style.Color.Background) -> UIColor {
        return .init(netHex: color.rawValue)
    }
}
