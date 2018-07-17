//
//  KMPreChatFormViewController.swift
//  Kommunicate
//
//  Created by Mukesh Thawani on 04/07/18.
//

import UIKit

public protocol KMPreChatFormViewControllerDelegate: class {
    func userSubmittedResponse(name: String, email: String, phoneNumber: String)
    func closeButtonTapped()
}

open class KMPreChatFormViewController: UIViewController {

    public weak var delegate: KMPreChatFormViewControllerDelegate!
    var formView: KMPreChatUserFormView!
    var sendInstructionsTapped:(()->())?

    enum Placeholder {
        static let email = "Email"
        static let name = "Name"
        static let phoneNumber = "Phone number"
    }

    enum TextFieldValidationError: Error {
        case emailAndPhoneNumberEmpty
        case invalidEmailAddress
        case invalidPhoneNumber

        var description: String {
            switch self {
            case .emailAndPhoneNumberEmpty:
                return "Please fill email or the phone number"
            case .invalidEmailAddress:
                return "Please enter correct email address"
            case .invalidPhoneNumber:
                return "Please enter correct phone number"
            }
        }
    }

    enum Result<ErrorType> {
        case success, failure(ErrorType)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    required public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupViews() {
        formView = KMPreChatUserFormView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        let closeButton = closeButtonOf(frame: CGRect(x: 20, y: 20, width: 30, height: 30))
        view.addSubview(formView)
        view.addSubview(closeButton)
        formView.sendInstructionsButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        [formView.emailTitleLabel, formView.nameTitleLabel, formView.phoneNumberTitle].hideViews()
        formView.setPlaceHolder(for: formView.emailTextField, withText: Placeholder.email)
        formView.setPlaceHolder(for: formView.nameTextField, withText: Placeholder.name)
        formView.setPlaceHolder(for: formView.phoneNumberTextField, withText: Placeholder.phoneNumber)
        setDelegateToSelf(for: [formView.emailTextField, formView.nameTextField, formView.phoneNumberTextField])
    }

    func updateTextFieldWhenbeginEditing(textField: UITextField) {
        // Hide error label as user is updating one of the fields and
        // we'll validate again when user clicks on submit.
        formView.hideErrorLabel()

        switch textField.tag {
        case 1: // email
            if textField.text == "" { setEmptyPlaceholder(for: textField, andHideLabel: formView.emailTitleLabel)}
        case 2: // Name
            if textField.text == "" { setEmptyPlaceholder(for: textField, andHideLabel: formView.nameTitleLabel)}
        case 3: // Phone number
            if textField.text == "" { setEmptyPlaceholder(for: textField, andHideLabel: formView.phoneNumberTitle)}
        default:
            print("Field not implemented yet")
        }
    }

    func updateTextFieldWhenFinishedEditing(textField: UITextField) {
        switch textField.tag {
        case 1: // email
            if textField.text == "" {
                setPlaceHolder(for: textField, withText: Placeholder.email, andShowLabel: formView.emailTitleLabel)}
        case 2: // Name
            if textField.text == "" {
                setPlaceHolder(for: textField, withText: Placeholder.name, andShowLabel: formView.nameTitleLabel)}
        case 3: // Phone number
            if textField.text == "" {
                setPlaceHolder(for: textField, withText: Placeholder.phoneNumber, andShowLabel: formView.phoneNumberTitle)}
        default:
            print("Field not implemented yet")
        }
    }

    func setDelegateToSelf(for textFields:[UITextField]) {
        textFields.forEach {$0.delegate = self}
    }

    @objc func sendButtonTapped() {
        let validation = validate(
            emailTextField: formView.emailTextField,
            phoneNumberTextField: formView.phoneNumberTextField,
            nameTextField: formView.nameTextField)

        switch validation {
        case .failure(let error):
            // Display error message
            formView.showErrorLabelWith(message: error.description)
        case .success:
            delegate.userSubmittedResponse(
                name: formView.nameTextField.text ?? "",
                email: formView.emailTextField.text ?? "",
                phoneNumber: formView.phoneNumberTextField.text ?? "")
        }
    }

    @objc func closeButtonAction(_ button: UIButton) {
        delegate.closeButtonTapped()
    }

    func validate(emailTextField: UITextField, phoneNumberTextField: UITextField, nameTextField: UITextField) -> Result<TextFieldValidationError>{
        // Return error if both email and phone number fields are empty.
        guard let emailText = emailTextField.text,
            let phoneNumberText = phoneNumberTextField.text, (!emailText.isEmpty || !phoneNumberText.isEmpty) else {
            // Show error
            return Result.failure(TextFieldValidationError.emailAndPhoneNumberEmpty)
        }

        // Return invalidEmailAddress error if email is present and not valid
        if !emailText.isEmpty, !emailText.isValidEmail {
            return Result.failure(TextFieldValidationError.invalidEmailAddress)
        }

        // Return invalidPhoneNumber error if phone number is present and not valid
        if !phoneNumberText.isEmpty, !phoneNumberText.isValidPhoneNumber {
            return Result.failure(TextFieldValidationError.invalidPhoneNumber)
        }
        return Result.success
    }

    private func setEmptyPlaceholder(for textField: UITextField, andHideLabel label: UILabel) {
        textField.attributedPlaceholder = nil
        label.show()
    }

    private func setPlaceHolder(for textField: UITextField, withText text: String, andShowLabel label: UILabel) {
        formView.setPlaceHolder(for: textField, withText: text)
        label.hide()
    }

    private func closeButtonOf(frame: CGRect) -> UIButton {
        let button = UIButton(type: .system)
        button.frame = frame
        button.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
        let closeImage = UIImage(named: "closeIcon", in: Bundle.kommunicate, compatibleWith: nil)
        button.setImage(closeImage, for: .normal)
        button.tintColor = UIColor.black
        return button
    }
}

extension KMPreChatFormViewController: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        updateTextFieldWhenbeginEditing(textField: textField)
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        updateTextFieldWhenFinishedEditing(textField: textField)
    }
}


extension Bundle {
    static var kommunicate: Bundle {
        return Bundle(for: Kommunicate.self)
    }
}
