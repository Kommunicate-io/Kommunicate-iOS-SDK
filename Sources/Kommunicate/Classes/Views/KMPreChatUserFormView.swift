//
//  KMPreChatUserFormView.swift
//  Kommunicate
//
//  Created by Mukesh Thawani on 04/07/18.
//

import UIKit

class CircleView: UIView {
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.addEllipse(in: rect)
        var backgroundColor = UIColor(red: 92 / 255, green: 90 / 255, blue: 167 / 255, alpha: 1)
        backgroundColor = backgroundColor.withAlphaComponent(0.2)
        context.setFillColor(backgroundColor.cgColor)
        context.fillPath()
    }
}

class KMPreChatUserFormView: UIView, Localizable {
    enum InputField {
        case name
        case email
        case phoneNumber
        case password
    }

    var localizationFileName: String!

    @IBOutlet var contentView: KMPreChatUserFormView!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailTitleLabel: UILabel!
    @IBOutlet var nameTitleLabel: UILabel!
    @IBOutlet var phoneNumberTitle: UILabel!
    @IBOutlet var passwordTitle: UILabel!
    @IBOutlet var sendInstructionsButton: UIButton!

    @IBOutlet var getStartedDescriptionLabel: UILabel!
    @IBOutlet var errorMessageLabel: UILabel!

    @IBOutlet var topStackView: UIStackView!

    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var emailStackView: UIStackView!
    @IBOutlet var nameStackView: UIStackView!
    @IBOutlet var phoneNumberStackView: UIStackView!
    @IBOutlet var passwordStackView: UIStackView!

    enum LocalizationKey {
        private static let prefix = "PreChatView"
        private static let suffix = "Title"
        static let getStarted = prefix + "GetStartedDescription"
        static let nameTitle = prefix + "Name" + suffix
        static let emailTitle = prefix + "Email" + suffix
        static let phoneNumberTitle = prefix + "PhoneNumber" + suffix
        static let passwordTitle = prefix + "Password" + suffix
        static let sendInstructionsButtonTitle = prefix + "SendInstructionsButton" + suffix
    }

    required init(frame: CGRect, localizationFileName: String) {
        self.localizationFileName = localizationFileName
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func commonInit() {
        Bundle.kommunicate.loadNibNamed("KMPreChatUserFormView", owner: self, options: nil)
        guard let contentView = contentView else {
            return
        }
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupLocalizedLabelTexts()
    }

    func setPlaceHolder(for textField: UITextField, valueFromKey key: String) {
        let placeholder = localizedString(forKey: key, fileName: localizationFileName)
        textField.attributedPlaceholder = placeholderWith(text: placeholder)
    }

    func showErrorLabelWith(message: String) {
        errorMessageLabel.text = message
    }

    func hideErrorLabel() {
        errorMessageLabel.text = ""
    }

    func hideField(_ field: InputField) {
        switch field {
        case .name:
            nameStackView.isHidden = true
        case .email:
            emailStackView.isHidden = true
        case .phoneNumber:
            phoneNumberStackView.isHidden = true
        case .password:
            passwordStackView.isHidden = true
        }
    }

    private func placeholderWith(text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [
            .foregroundColor: UIColor(red: 173, green: 168, blue: 168),
            .font: UIFont(name: "HelveticaNeue-Medium", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0),
        ])
    }

    private func setupLocalizedLabelTexts() {
        getStartedDescriptionLabel.text =
            localizedString(forKey: LocalizationKey.getStarted, fileName: localizationFileName)
        nameTitleLabel.text =
            localizedString(forKey: LocalizationKey.nameTitle, fileName: localizationFileName)
        emailTitleLabel.text =
            localizedString(forKey: LocalizationKey.emailTitle, fileName: localizationFileName)
        phoneNumberTitle.text =
            localizedString(forKey: LocalizationKey.phoneNumberTitle, fileName: localizationFileName)
        passwordTitle.text =
            localizedString(forKey: LocalizationKey.passwordTitle, fileName: localizationFileName)
        let buttonTitle =
            localizedString(forKey: LocalizationKey.sendInstructionsButtonTitle, fileName: localizationFileName)
        sendInstructionsButton.setTitle(buttonTitle, for: .normal)
    }
}
