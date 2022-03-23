//
//  CustomPreChatFormView.swift
//  Kommunicate
//
//  Created by Kirti S on 12/3/21.
//

import UIKit

class CustomPreChatFormView: UIView, UITextFieldDelegate {
    var localizationFileName: String!

    @IBOutlet var contentView: UIView!
    @IBOutlet var headerStackView: UIStackView!
    @IBOutlet public var formStackView: UIStackView!
    @IBOutlet var sendInstructionsButton: UIButton!
    @IBOutlet var errorMessageLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var titleLabel: UILabel!

    public var name = String()
    public var email = String()
    public var phoneNumber = String()

    required init(frame: CGRect, localizationFileName: String) {
        self.localizationFileName = localizationFileName
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func commonInit() {
        Bundle.kommunicate.loadNibNamed("CustomPreChatFormView", owner: self, options: nil)
        guard let contentView = contentView else {
            return
        }
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setUpView()
    }

    func setUpView() {
        if let title = UserDefaults.standard.string(forKey: "leadCollectionTitle") {
            titleLabel.text = title
        } else {
            titleLabel.text = "Pre-Chat Lead Collection"
        }

        for (index, element) in Kommunicate.leadArray.enumerated() {
            if let type = element.element, type == CustomPreChatFormViewController.dropDownType, let options = element.options, !options.isEmpty {
                let image = UIImage(named: "icon_down", in: Bundle.kommunicate, compatibleWith: nil)
                let button = UIButton()
                button.setTitleColor(UIColor(red: 131, green: 131, blue: 136), for: .normal)
                button.setTitle(element.placeholder, for: .normal)
                button.tag = index
                button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                button.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
                button.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
                button.setImage(image, for: .normal)
                button.imageEdgeInsets = UIEdgeInsets(top: 5, left: contentView.frame.width - 60, bottom: 5, right: 15)
                button.layer.cornerRadius = 2
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor(red: 92, green: 90, blue: 167).cgColor
                formStackView.addArrangedSubview(button)
                button.leadingAnchor.constraint(equalTo: formStackView.leadingAnchor, constant: 15).isActive = true
                button.trailingAnchor.constraint(equalTo: formStackView.trailingAnchor, constant: -15).isActive = true

            } else {
                let textLabel = UILabel()
                textLabel.text = element.field
                textLabel.textAlignment = .left
                textLabel.font = UIFont(name: "HelveticaNeue", size: 13)
                textLabel.textColor = UIColor(red: 131, green: 131, blue: 136)
                textLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
                textLabel.heightAnchor.constraint(equalToConstant: 14.0).isActive = true
                textLabel.isHidden = true

                let textField = UITextField()
                textField.borderStyle = .none
                textField.textAlignment = .left
                textField.attributedPlaceholder = placeholderForTextField(text: element.placeholder)
                textLabel.font = UIFont(name: "HelveticaNeue", size: 16)
                textLabel.textColor = UIColor(red: 68, green: 68, blue: 70)
                textField.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
                textField.heightAnchor.constraint(equalToConstant: 22).isActive = true
                textField.tag = index
                textField.autocapitalizationType = .none
                textField.autocorrectionType = .no
                textField.smartDashesType = .no
                textField.smartInsertDeleteType = .no
                textField.smartQuotesType = .no
                textField.spellCheckingType = .no

                let view = UIView()
                view.backgroundColor = UIColor(red: 218, green: 215, blue: 215)
                view.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
                view.heightAnchor.constraint(equalToConstant: 2).isActive = true

                // Stack View
                let stackView = UIStackView()
                stackView.axis = NSLayoutConstraint.Axis.vertical
                stackView.distribution = UIStackView.Distribution.equalSpacing
                stackView.alignment = UIStackView.Alignment.leading
                stackView.spacing = -10
                stackView.tag = index

                stackView.addArrangedSubview(textLabel)
                stackView.addArrangedSubview(textField)
                stackView.addArrangedSubview(view)
                stackView.translatesAutoresizingMaskIntoConstraints = false

                formStackView.addArrangedSubview(stackView)
                stackView.leadingAnchor.constraint(equalTo: formStackView.leadingAnchor, constant: 15).isActive = true
                stackView.trailingAnchor.constraint(equalTo: formStackView.trailingAnchor, constant: -15).isActive = true
            }
        }
        formStackView.heightAnchor.constraint(equalToConstant: CGFloat(50 * Kommunicate.leadArray.count)).isActive = true
    }

    func placeholderForTextField(text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [
            .foregroundColor: UIColor(red: 173, green: 168, blue: 168),
            .font: UIFont(name: "HelveticaNeue-Medium", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0),
        ])
    }

    func placeholderWith(text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [
            .foregroundColor: UIColor(red: 173, green: 168, blue: 168),
            .font: UIFont(name: "HelveticaNeue-Medium", size: 13.0) ?? UIFont.systemFont(ofSize: 13.0),
        ])
    }

    func hideErrorLabel() {
        errorMessageLabel.text = ""
    }

    func showErrorLabelWith(message: String) {
        errorMessageLabel.text = message
    }
}
