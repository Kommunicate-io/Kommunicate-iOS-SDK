//
//  UIView+Extension.swift
//  Kommunicate
//
//  Created by Shivam Pokhriyal on 14/11/18.
//

import Foundation
import UIKit


extension UIView {

    func addViewsForAutolayout(views: [UIView]) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }

    func drawDottedLine(start p0: CGPoint, end p1: CGPoint) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor =  UIColor(netHex: 0xbebbbb).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [5, 5]
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        self.layer.addSublayer(shapeLayer)
    }
}
