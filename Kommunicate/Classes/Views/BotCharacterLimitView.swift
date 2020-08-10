//
//  BotCharacterLimitView.swift
//  Kommunicate
//
//  Created by Sunil on 05/08/20.
//

import Foundation
class BotCharacterLimitView: UIView {

    enum CharacterLimit {
        static let charLimitForDialogFlowBot = 256
        static let charLimitWarningForDialogFlowBot = 55
    }

    enum ConstraintIdentifier: String {
        case botCharacterLimitViewHeight
        case messageViewHeight
    }

    struct Padding {
        struct MessageLabel {
            static let top: CGFloat = 5.0
            static let leading: CGFloat  = 20.0
            static let trailing: CGFloat = -20.0
            static let height: CGFloat = 70.0
        }
    }

    private let messageLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.contentMode = .center
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 4
        return label
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupViews() {
        addConstraints()
    }

    func setBackgroundColor(color: UIColor)  {
        messageLabel.textColor =  color.isLight() ? .black :  .white
        backgroundColor = color

    }

    func set(message: String) {
        messageLabel.text = message
    }

    private func addConstraints() {
        addViewsForAutolayout(views: [messageLabel])
        messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: Padding.MessageLabel.top).isActive = true

        messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.MessageLabel.leading).isActive = true

        messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Padding.MessageLabel.trailing).isActive = true

        messageLabel.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: BotCharacterLimitView.ConstraintIdentifier.messageViewHeight.rawValue).isActive = true
    }

    func hideView(hide:Bool) {
        messageLabel.constraint(withIdentifier: BotCharacterLimitView.ConstraintIdentifier.messageViewHeight.rawValue)?.constant = hide ? 0 : height()
        layoutIfNeeded()
    }

    func height() -> CGFloat {
        return Padding.MessageLabel.height + Padding.MessageLabel.top
    }
}

extension BotCharacterLimitView: Localizable {
    enum LocalizedText {
        static private let filename = Kommunicate.defaultConfiguration.localizedStringFileName

        static let botCharLimit = localizedString(forKey: "BotCharLimit", fileName: filename)
        static let removeCharMessage = localizedString(forKey: "RemoveCharMessage", fileName: filename)
        static let remainingCharMessage = localizedString(forKey: "RemainingCharMessage", fileName: filename)

    }
}
