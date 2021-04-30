//
//  File.swift
//  Kommunicate
//
//  Created by Sunil on 10/08/20.
//

import Foundation
import UIKit

extension NSLayoutDimension {
    func constraintEqualToAnchor(constant: CGFloat, identifier: String) -> NSLayoutConstraint {
        let constraint = self.constraint(equalToConstant: constant)
        constraint.identifier = identifier
        return constraint
    }
}
