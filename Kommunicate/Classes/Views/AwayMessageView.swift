//
//  File.swift
//  Kommunicate
//
//  Created by Mukesh on 08/01/19.
//

import Foundation
import ApplozicSwift

class AwayMessageView: UIView {

    let messageLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        label.contentMode = .center
        label.textAlignment = .center
        label.textColor = UIColor(netHex: 0x676262)
        label.numberOfLines = 4
        return label
    }()

    let dottedLineView: UIView = {
        return UIView(frame: CGRect.zero)
    }()

    let dottedLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor =  UIColor(netHex: 0xbebbbb).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [5, 5]
        shapeLayer.path = CGMutablePath()
        return shapeLayer
    }()

    lazy var dottedLineHeightAnchor = dottedLineView.heightAnchor.constraint(equalToConstant: 0)

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func commonInit() {
        addViewsForAutolayout(views: [dottedLineView, messageLabel])
        dottedLineHeightAnchor.isActive = true
        dottedLineView.layout {
            $0.top == topAnchor
            $0.leading == leadingAnchor + 12
            $0.trailing == trailingAnchor - 23
        }

        messageLabel.layout {
            $0.bottom == bottomAnchor
            $0.top == dottedLineView.bottomAnchor + 5
            $0.leading == leadingAnchor + 20
            $0.trailing == trailingAnchor - 20
        }
        dottedLineView.layer.addSublayer(dottedLayer)
    }

    func set(message: String) {
        messageLabel.text = message
    }

    func drawDottedLines() {
        guard dottedLineView.frame.width > 0 else { return }
        let startPoint = CGPoint(x: dottedLineView.frame.origin.x, y: 0)
        let endPoint = CGPoint(x: dottedLineView.frame.width, y: 0)
        let path = CGMutablePath()
        path.addLines(between: [startPoint, endPoint])
        dottedLayer.path = path
    }

    func showMessage(_ flag: Bool) {
        dottedLineHeightAnchor.constant = flag ? 1:0
        dottedLayer.lineWidth = flag ? 1:0
    }
}
