//
//  UIView+Extension.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 14/11/18.
//

import Foundation


extension UIView {
    
    func addViewsForAutolayout(views: [UIView]) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }
    
}
