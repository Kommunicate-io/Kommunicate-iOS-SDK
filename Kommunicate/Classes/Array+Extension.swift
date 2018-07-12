//
//  Array+Extension.swift
//  Kommunicate
//
//  Created by Mukesh Thawani on 09/07/18.
//

import Foundation

extension Array where Element == UIView {
    func hideViews() {
        forEach {$0.isHidden = true}
    }
}
