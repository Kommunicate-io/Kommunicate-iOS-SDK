//
//  CustomPreChatFormViewController.swift
//  Kommunicate
//
//  Created by Kirti S on 11/24/21.
//

import UIKit

class OptionsCell: UITableViewCell {}

open class CustomPreChatFormViewController: UIViewController {
    // Standard Value from Dashboard for the respective fields
    static let email = "Email"
    static let name = "Name"
    static let phone = "Phone"
    static let dropDownType = "select"

    private var transparentView = UIView()
    private var tableView = UITableView()
    private var selectedButton = UIButton()
    private var selectedDataSource = [String]()

    public struct PreChatConfiguration {
        public var mandatoryOptions = [String]()
        public var phoneNumberRegexPattern: String?
        public init() {}
    }

    public weak var delegate: KMPreChatFormViewControllerDelegate?
    public var preChatConfiguration: PreChatConfiguration!

    var configuration: KMConfiguration!
    var formView: CustomPreChatFormView!

    public var submitButtonTapped: (([String: String]) -> Void)?
    public var closeButtonTapped: (() -> Void)?

    enum TextFieldValidationError: Error, Localizable {
        case invalidEmailAddress
        case invalidPhoneNumber
        case emptyName
        case emptyEmailAddress
        case emptyPhoneNumber
        case emptyField

        func localizationDescription(fromFileName fileName: String) -> String {
            switch self {
            case .invalidEmailAddress:
                return localizedString(forKey: "PreChatViewEmailInvalidError", fileName: fileName)
            case .invalidPhoneNumber:
                return localizedString(forKey: "PreChatViewPhoneNumberInvalidError", fileName: fileName)
            case .emptyName:
                return localizedString(forKey: "PreChatViewNameEmptyError", fileName: fileName)
            case .emptyEmailAddress:
                return localizedString(forKey: "PreChatViewEmailEmptyError", fileName: fileName)
            case .emptyPhoneNumber:
                return localizedString(forKey: "PreChatViewPhoneNumberEmptyError", fileName: fileName)
            case .emptyField:
                return localizedString(forKey: "PreChatViewFieldEmpty", fileName: fileName)
            }
        }
    }

    enum Result<ErrorType> {
        case success, failure(ErrorType)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    public required init(configuration: KMConfiguration, preChatConfiguration: PreChatConfiguration = PreChatConfiguration()) {
        self.configuration = configuration
        self.preChatConfiguration = preChatConfiguration
        super.init(nibName: nil, bundle: nil)
        addObservers()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addObservers()
    }

    deinit {
        removeObservers()
    }

    func setUpView() {
        let leadArray = Kommunicate.leadArray

        for item in leadArray {
            if item.required {
                guard let element = item.element, element == CustomPreChatFormViewController.dropDownType else {
                    preChatConfiguration.mandatoryOptions.append(item.field)
                    continue
                }
                preChatConfiguration.mandatoryOptions.append(item.placeholder)
            }
        }

        formView = CustomPreChatFormView(
            frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height),
            localizationFileName: configuration.localizedStringFileName
        )
        view.backgroundColor = .red
        view.addSubview(formView)

        for (index, subview) in formView.formStackView.arrangedSubviews.enumerated() {
            guard let element = leadArray[index].element, element == CustomPreChatFormViewController.dropDownType else {
                (subview.subviews[1] as? UITextField)?.delegate = self
                continue
            }

            (subview as? UIButton)?.addTarget(self, action: #selector(dropDownButtonTapped), for: .touchUpInside)
        }

        let closeButton = closeButtonOf(frame: CGRect(x: 20, y: 20, width: 30, height: 30))
        view.addSubview(formView)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        var topAnchor = view.topAnchor
        if #available(iOS 11, *) {
            topAnchor = view.safeAreaLayoutGuide.topAnchor
        }
        NSLayoutConstraint.activate(
            [closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
             closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
             closeButton.heightAnchor.constraint(equalToConstant: 30),
             closeButton.widthAnchor.constraint(equalToConstant: 30)]
        )

        formView.sendInstructionsButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)

        let tapper = UITapGestureRecognizer(target: view, action: #selector(view.endEditing(_:)))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OptionsCell.self, forCellReuseIdentifier: "cell")
    }

    @objc func sendButtonTapped() {
        let validation = validate()
        switch validation {
        case let .failure(error):
            formView.showErrorLabelWith(message: error.localizationDescription(fromFileName: configuration.localizedStringFileName))
        case .success:
            var resultDict = [String: String]()

            for (index, subview) in formView.formStackView.arrangedSubviews.enumerated() {
                let item = Kommunicate.leadArray[index]

                guard let element = item.element, element == CustomPreChatFormViewController.dropDownType else {
                    if (subview.subviews[0] as? UILabel)?.text == Kommunicate.leadArray[index].field {
                        resultDict[item.field] = ((subview.subviews[1] as? UITextField)?.text)!
                    }
                    continue
                }

                guard let text = (subview as? UIButton)?.titleLabel?.text, text != item.placeholder else {
                    resultDict[item.field] = ""
                    continue
                }

                resultDict[item.field] = text
            }
            submitButtonTapped?(resultDict)
        }
    }

    func validate() -> Result<TextFieldValidationError> {
        var validationError: TextFieldValidationError?

        outerLoop: for mandatoryOption in preChatConfiguration.mandatoryOptions {
            for (index, element) in Kommunicate.leadArray.enumerated() {
                if mandatoryOption == CustomPreChatFormViewController.email {
                    if let text = (formView.formStackView.arrangedSubviews[index].subviews[0] as? UILabel)?.text, text == mandatoryOption {
                        if let text2 = (formView.formStackView.arrangedSubviews[index].subviews[1] as? UITextField)?.text,!text2.isValidEmail {
                            if text2.isEmpty {
                                validationError = TextFieldValidationError.emptyEmailAddress
                                break outerLoop
                            } else {
                                validationError = TextFieldValidationError.invalidEmailAddress
                                break outerLoop
                            }
                        }
                    }
                } else

                if mandatoryOption == CustomPreChatFormViewController.name {
                    if let text = (formView.formStackView.arrangedSubviews[index].subviews[0] as? UILabel)?.text, text == mandatoryOption {
                        if let text2 = (formView.formStackView.arrangedSubviews[index].subviews[1] as? UITextField)?.text, text2.isEmpty {
                            validationError = TextFieldValidationError.emptyName
                            break outerLoop
                        }
                    }
                } else

                if mandatoryOption == CustomPreChatFormViewController.phone {
                    let isValidNumber: ((String) -> Bool) = { number in
                        self.preChatConfiguration.phoneNumberRegexPattern != nil ?
                            number.matchesWithPattern(self.preChatConfiguration.phoneNumberRegexPattern ?? "") : number.isValidPhoneNumber
                    }
                    if let text = (formView.formStackView.arrangedSubviews[index].subviews[0] as? UILabel)?.text, text == mandatoryOption {
                        if let text2 = (formView.formStackView.arrangedSubviews[index].subviews[1] as? UITextField)?.text, !isValidNumber(text2) {
                            if text2.isEmpty {
                                validationError = TextFieldValidationError.emptyPhoneNumber
                                break outerLoop
                            } else {
                                validationError = TextFieldValidationError.invalidPhoneNumber
                                break outerLoop
                            }
                        }
                    }
                } else {
                    if let elementType = element.element, elementType == CustomPreChatFormViewController.dropDownType {
                        if let title = (formView.formStackView.arrangedSubviews[index] as? UIButton)?.titleLabel?.text, title == mandatoryOption {
                            validationError = TextFieldValidationError.emptyField
                            break outerLoop
                        }
                    } else if let text = (formView.formStackView.arrangedSubviews[index].subviews[0] as? UILabel)?.text, text == mandatoryOption {
                        if let text2 = (formView.formStackView.arrangedSubviews[index].subviews[1] as? UITextField)?.text, text2.isEmpty {
                            validationError = TextFieldValidationError.emptyField
                            break outerLoop
                        }
                    }
                }
            }
        }
        return validationError != nil ? .failure(validationError!) : .success
    }

    @objc func dismissKeyboard(_: UITapGestureRecognizer) {
        (formView.formStackView.arrangedSubviews[0].subviews[1] as? UITextField)?.resignFirstResponder()
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

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillHide() {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        formView.scrollView.contentInset = contentInsets
        formView.scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc func keyboardWillChange(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else { return }
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height + 40, right: 0.0)
        formView.scrollView.contentInset = contentInsets
        formView.scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc func closeButtonAction(_: UIButton) {
        closeButtonTapped?()
    }

    func updateTextFieldWhenbeginEditing(textField: UITextField) {
        formView.hideErrorLabel()
        for (index, _) in Kommunicate.leadArray.enumerated() {
            if textField.tag == index {
                if textField.text == "" {
                    setEmptyPlaceholder(for: textField)
                }
            }
        }
    }

    func updateTextFieldWhenFinishedEditing(textField: UITextField) {
        for (index, _) in Kommunicate.leadArray.enumerated() {
            if textField.tag == index {
                if textField.text == "" {
                    setPlaceholder(for: textField)
                }
            }
        }
    }

    private func addTransparent(_ rect: CGRect) {
        let window = UIApplication.sharedUIApplication()?.keyWindow
        transparentView.frame = window?.frame ?? view.frame
        view.addSubview(transparentView)

        tableView.frame = CGRect(x: rect.origin.x, y: rect.origin.y + rect.height, width: rect.width, height: 0)
        view.addSubview(tableView)
        tableView.layer.cornerRadius = 5
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)

        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapGesture)
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: rect.origin.x, y: rect.origin.y + rect.height, width: rect.width, height: self.view.frame.size.height - self.tableView.frame.origin.y)
        }, completion: nil)
    }

    @objc func removeTransparentView() {
        let rect = selectedButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: rect.origin.x, y: rect.origin.y + rect.height, width: rect.width, height: 0)
        }, completion: nil)
    }

    @objc func dropDownButtonTapped(_ sender: UIButton) {
        let leadElement = Kommunicate.leadArray[sender.tag]

        guard let source = leadElement.options, !source.isEmpty else {
            return
        }
        selectedDataSource.removeAll()
        selectedDataSource.append(leadElement.placeholder)
        for item in source {
            selectedDataSource.append(item.value)
        }

        selectedButton = sender

        guard let superview = sender.superview as? UIStackView else {
            addTransparent(sender.frame)
            return
        }
        let cvtRect = superview.convert(sender.frame, to: view)
        addTransparent(cvtRect)
    }

    func updateDropDownLabel(_ value: String) {
        selectedButton.setTitle(value, for: .normal)
    }

    private func setEmptyPlaceholder(for textField: UITextField) {
        textField.attributedPlaceholder = nil
        for stackView in formView.formStackView.arrangedSubviews {
            if stackView.tag == textField.tag {
                (stackView.subviews[0] as? UILabel)?.show()
            }
        }
    }

    private func setPlaceholder(for textField: UITextField) {
        textField.attributedPlaceholder = formView.placeholderForTextField(text: Kommunicate.leadArray[textField.tag].placeholder)
        for stackView in formView.formStackView.arrangedSubviews {
            if stackView.tag == textField.tag {
                (stackView.subviews[0] as? UILabel)?.hide()
            }
        }
    }
}

extension CustomPreChatFormViewController: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        updateTextFieldWhenbeginEditing(textField: textField)
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        updateTextFieldWhenFinishedEditing(textField: textField)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        for (index, _) in Kommunicate.leadArray.enumerated() {
            if textField.tag == index {
                textField.resignFirstResponder()
                (formView.formStackView.arrangedSubviews[index + 1].subviews[1] as? UITextField)?.becomeFirstResponder()
            }
        }
        return true
    }
}

extension CustomPreChatFormViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = selectedDataSource[indexPath.row]
        return cell
    }

    public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return selectedDataSource.count
    }

    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateDropDownLabel(selectedDataSource[indexPath.row])
        removeTransparentView()
    }
}
