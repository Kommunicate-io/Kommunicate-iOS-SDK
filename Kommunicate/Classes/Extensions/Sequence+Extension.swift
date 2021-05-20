//
//  Sequence+Extension.swift
//  Kommunicate
//
//  Created by Mukesh on 16/01/19.
//

import Foundation

extension Sequence where Iterator.Element: Hashable {
    var uniqueElements: [Iterator.Element] {
        return Array( Set(self) )
    }
}
