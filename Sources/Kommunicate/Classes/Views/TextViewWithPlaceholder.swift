//
//  TextViewWithPlaceholder.swift
//  Kommunicate
//
//  Created by Mukesh on 07/01/20.
//

import UIKit

class TextViewWithPlaceholder: UITextView {
    private class PlaceholderLabel: UILabel { }

    override func layoutSubviews() {
        super.layoutSubviews()
        setPlaceHolderFrame()
    }

    var placeholderColor: UIColor = .gray {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }

    var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
            setPlaceHolderFrame()
        }
    }

    override var font: UIFont! {
        didSet {
            placeholderLabel.font = font
        }
    }

    private var placeholderLabel: PlaceholderLabel = {
        let label = PlaceholderLabel(frame: .zero)
        return label
    }()

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        placeholderLabel.text = placeholder
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.font = font
        placeholderLabel.numberOfLines = 0
        textStorage.delegate = self
        addSubview(placeholderLabel)
    }

    private func setPlaceHolderFrame() {
        let width = frame.width - textContainer.lineFragmentPadding * 2
        let size = placeholderLabel.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        placeholderLabel.frame.size.height = size.height
        placeholderLabel.frame.size.width = width
        placeholderLabel.frame.origin = CGPoint(x: textContainer.lineFragmentPadding, y: textContainerInset.top)
    }
}

extension TextViewWithPlaceholder: NSTextStorageDelegate {
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask.contains(.editedCharacters) {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }
}
