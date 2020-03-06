//
//  SubmittedFeedbackView.swift
//  ApplozicSwift
//
//  Created by Mukesh on 03/03/20.
//

import UIKit

class SubmittedFeedbackView: UIView {
    private let ratingView = RatingView()
    private let commentsView = CommentsView()

    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 10
        return stack
    }()

    override var intrinsicContentSize: CGSize {
        guard feedback != nil else { return .zero }
        // TODO: move spacing const
        let commentsViewHeight = commentsView.intrinsicContentSize.height
        let spacing: CGFloat = commentsViewHeight > 0 ? 10:0
        return CGSize(
            width: frame.width,
            height: spacing + ratingView.intrinsicContentSize.height + commentsViewHeight
        )
    }

    var feedback: Feedback? {
        didSet {
            ratingView.rating = feedback?.rating
            commentsView.text = feedback?.comment
            ratingView.isHidden = feedback?.rating == nil
            commentsView.isHidden = feedback?.comment == nil
        }
    }

    init() {
        super.init(frame: .zero)
        setupView()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // TODO: Use conversation VC's back color through config
        backgroundColor = .white
    }

    private func setupLayout() {
        addViewsForAutolayout(views: [mainStack])
        mainStack.addArrangedSubview(ratingView)
        mainStack.addArrangedSubview(commentsView)

        mainStack.layout {
            $0.leading == leadingAnchor + 20
            $0.trailing == trailingAnchor - 20
            $0.bottom == bottomAnchor
            $0.top >= topAnchor
        }
    }
}

extension SubmittedFeedbackView {
    class RatingView: UIView {

        var rating: RatingType? {
            didSet {
                // TODO: Localize
                label.text = (rating != nil) ? "You rated the conversation":""
                self.invalidateIntrinsicContentSize()
                self.superview?.setNeedsLayout()
                self.superview?.layoutIfNeeded()
            }
        }
        // TODO: two lines(a stroke): leading and trailing
        // one label in the center and one icon for rating

        // TODO: Change name
        private let label: UILabel = {
            let label = UILabel(frame: .zero)
            label.numberOfLines = 1
            label.textColor = .darkGray
            label.font = Style.Font.italic(size: 14).font()
            return label
        }()

        override var intrinsicContentSize: CGSize {
            guard rating != nil else { return .zero }
            return label.intrinsicContentSize
        }

        init() {
            super.init(frame: .zero)
            setupLayout()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupLayout() {
            addViewsForAutolayout(views: [label])
            label.layout {
                $0.leading == leadingAnchor
                $0.trailing == trailingAnchor
                $0.top == topAnchor
            }
        }
    }
}

extension SubmittedFeedbackView {
    class CommentsView: UITextView {
        override var intrinsicContentSize: CGSize {
            guard text != nil else { return .zero }
            return CGSize(
                width: frame.width,
                height: CommentsView.heightFor(self)
            )
        }

        override var text: String! {
            get { return super.text }
            set {
                let didChange = super.text != newValue
                super.text = newValue
                if didChange {
                    textChanged()
                }
            }
        }

        init() {
            super.init(frame: .zero, textContainer: nil)
            setupViews()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func textChanged() {
            // update height
            invalidateIntrinsicContentSize()
            superview?.setNeedsLayout()
            superview?.layoutIfNeeded()
        }

        private func setupViews() {
            font = Style.Font.normal(size: 14).font()
            isEditable = false
        }
    }
}

extension SubmittedFeedbackView.CommentsView {
    static func heightFor(
        _ textView: UITextView,
        maxHeight: CGFloat = 70
    ) -> CGFloat {
        var reqHeightForComments: CGFloat = 0
        guard let comments = textView.text, !comments.isEmpty else { return reqHeightForComments }

        let textView = UITextView(frame: textView.frame)
        let attributes = textView.typingAttributes
        textView.attributedText = NSAttributedString(string: comments, attributes: attributes)
        let fixedWidth = textView.frame.size.width
        let size = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        reqHeightForComments = size.height
        return reqHeightForComments < maxHeight ? reqHeightForComments:maxHeight
    }
}
