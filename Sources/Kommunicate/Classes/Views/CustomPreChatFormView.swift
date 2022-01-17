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
    @IBOutlet weak var headerStackView: UIStackView!
    @IBOutlet public var formStackView : UIStackView!
    @IBOutlet weak var sendInstructionsButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    
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
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setUpView()
    }
    
    func setUpView() {
        
        guard let title = UserDefaults.standard.string(forKey: "leadCollectionTitle") else {
            titleLabel.text = "Pre-Chat Lead Collection"
            return
        }
        titleLabel.text = title
        var array = Kommunicate.leadArray
        let option = [LeadCollectionDropDownField(value: "1"),
                      LeadCollectionDropDownField(value: "2"),
                      LeadCollectionDropDownField(value: "3")]
        
        let dropDown = LeadCollectionFields(type:"" , field: "Lucky Number", required: true, placeholder: "Enter your luck number", element: "selection", options: option)
        array.append(dropDown)
        
        for (index,element) in array.enumerated() {
            if let type = element.element, type == "selection", let options = element.options, !options.isEmpty {
                let button = UIButton()
                button.setTitleColor(UIColor.black, for: .normal)
                button.setTitle(element.placeholder, for: .normal)
                button.layer.cornerRadius = 5
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.red.cgColor
                button.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
                button.tag = index
                button.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
                
                let tableView = UITableView()
                tableView.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
                tableView.tag = index
                let row = options.count
                tableView.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
                tableView.isHidden = false
                let stack = UIStackView()
                stack.axis = .vertical
                stack.alignment = UIStackView.Alignment.leading
                stack.spacing   = 15
                stack.tag = index
                stack.addArrangedSubview(button)
                stack.addArrangedSubview(tableView)
                
//                
//                tableView.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
//                tableView.heightAnchor.constraint(equalToConstant: 20 * options).isActive = true
//                
//                let bgView = UIView()
//                bgView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
//                bgView.layer.cornerRadius = 5
//                bgView.layer.borderWidth = 2
//                bgView.layer.borderColor = UIColor.red.cgColor

//
//
//                stack.addArrangedSubview(button)
//                stack.addArrangedSubview(bgV)
//
//                let tableView = UITableView()
//

                formStackView.addArrangedSubview(stack)
                button.leadingAnchor.constraint(equalTo: formStackView.leadingAnchor, constant: 15).isActive = true
                button.trailingAnchor.constraint(equalTo: formStackView.trailingAnchor, constant: -15).isActive = true
                
                
            }else{
                let textLabel = UILabel()
                textLabel.text  = element.field
                textLabel.textAlignment = .left
                textLabel.font = UIFont(name: "HelveticaNeue", size: 13)
                textLabel.textColor = UIColor(131, green: 131, blue: 136)
                textLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
                textLabel.heightAnchor.constraint(equalToConstant: 14.0).isActive = true
                textLabel.isHidden = true
                
                let textField = UITextField()
                textField.borderStyle = .none
                textField.textAlignment = .left
                textField.attributedPlaceholder = placeholderForTextField(text: element.placeholder)
                textLabel.font = UIFont(name: "HelveticaNeue", size: 16)
                textLabel.textColor = UIColor(68, green: 68, blue: 70)
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
                view.backgroundColor = UIColor(218, green: 215, blue: 215)
                view.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
                view.heightAnchor.constraint(equalToConstant: 2).isActive = true
                
                //Stack View
                let stackView   = UIStackView()
                stackView.axis  = NSLayoutConstraint.Axis.vertical
                stackView.distribution  = UIStackView.Distribution.equalSpacing
                stackView.alignment = UIStackView.Alignment.leading
                stackView.spacing   = -10
                stackView.tag = index
                
                stackView.addArrangedSubview(textLabel)
                stackView.addArrangedSubview(textField)
                stackView.addArrangedSubview(view)
                stackView.translatesAutoresizingMaskIntoConstraints = false
                
                formStackView.addArrangedSubview(stackView)
                stackView.leadingAnchor.constraint(equalTo: formStackView.leadingAnchor, constant: 15).isActive = true
                stackView.trailingAnchor.constraint(equalTo: formStackView.trailingAnchor, constant: -15).isActive = true
                
            }
//            else{
//
//            }
//
//            let textLabel = UILabel()
//            textLabel.text  = element.field
//            textLabel.textAlignment = .left
//            textLabel.font = UIFont(name: "HelveticaNeue", size: 13)
//            textLabel.textColor = UIColor(131, green: 131, blue: 136)
//            textLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
//            textLabel.heightAnchor.constraint(equalToConstant: 14.0).isActive = true
//            textLabel.isHidden = true
//
//            let textField = UITextField()
//            textField.borderStyle = .none
//            textField.textAlignment = .left
//            textField.attributedPlaceholder = placeholderForTextField(text: element.placeholder)
//            textLabel.font = UIFont(name: "HelveticaNeue", size: 16)
//            textLabel.textColor = UIColor(68, green: 68, blue: 70)
//            textField.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
//            textField.heightAnchor.constraint(equalToConstant: 22).isActive = true
//            textField.tag = index
//            textField.autocapitalizationType = .none
//            textField.autocorrectionType = .no
//            textField.smartDashesType = .no
//            textField.smartInsertDeleteType = .no
//            textField.smartQuotesType = .no
//            textField.spellCheckingType = .no
//
//            let view = UIView()
//            view.backgroundColor = UIColor(218, green: 215, blue: 215)
//            view.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
//            view.heightAnchor.constraint(equalToConstant: 2).isActive = true
//
//            //Stack View
//            let stackView   = UIStackView()
//            stackView.axis  = NSLayoutConstraint.Axis.vertical
//            stackView.distribution  = UIStackView.Distribution.equalSpacing
//            stackView.alignment = UIStackView.Alignment.leading
//            stackView.spacing   = -10
//            stackView.tag = index
//
//            stackView.addArrangedSubview(textLabel)
//            stackView.addArrangedSubview(textField)
//            stackView.addArrangedSubview(view)
//            stackView.translatesAutoresizingMaskIntoConstraints = false
//
//            formStackView.addArrangedSubview(stackView)
//            stackView.leadingAnchor.constraint(equalTo: formStackView.leadingAnchor, constant: 15).isActive = true
//            stackView.trailingAnchor.constraint(equalTo: formStackView.trailingAnchor, constant: -15).isActive = true
        }
        formStackView.heightAnchor.constraint(equalToConstant: CGFloat((50*Kommunicate.leadArray.count))).isActive = true
    }
    
    func placeholderForTextField(text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [
            .foregroundColor: UIColor(red: 173, green: 168, blue: 168) ,
            .font: UIFont(name: "HelveticaNeue-Medium", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0)
        ])
    }
    
    func placeholderWith(text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [
            .foregroundColor: UIColor(red: 173, green: 168, blue: 168) ,
            .font: UIFont(name: "HelveticaNeue-Medium", size: 13.0) ?? UIFont.systemFont(ofSize: 13.0)
        ])
    }
    
    func hideErrorLabel() {
        errorMessageLabel.text = ""
    }
    
    func showErrorLabelWith(message: String) {
        errorMessageLabel.text = message
    }
}
