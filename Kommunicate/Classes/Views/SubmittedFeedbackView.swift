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
            layoutMargins = (feedback != nil)
                ? UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0):.zero
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
        backgroundColor = .background(.lightGreyOne)
        layoutMargins = .zero
    }

    private func setupLayout() {
        addViewsForAutolayout(views: [mainStack])
        mainStack.addArrangedSubview(ratingView)
        mainStack.addArrangedSubview(commentsView)

        mainStack.layout {
            $0.leading == leadingAnchor + 20
            $0.trailing == trailingAnchor - 20
            $0.bottom == layoutMarginsGuide.bottomAnchor
            $0.top >= layoutMarginsGuide.topAnchor
        }
    }
}

extension SubmittedFeedbackView {
    class RatingView: UIView {

        var rating: RatingType? {
            didSet {
                ratedTitleLabel.text = (rating != nil) ? "You rated the conversation":""
                emojiView.image = rating?.icon()
                self.invalidateIntrinsicContentSize()
            }
        }

        private let ratedTitleLabel: UILabel = {
            let label = UILabel(frame: .zero)
            label.numberOfLines = 1
            label.textColor = .text(.mediumDarkBlack)
            label.font = Style.Font.lightItalic(size: 14).font()
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        private let emojiView = UIImageView(frame: .zero)

        private let leftLineView = UIView(frame: .zero)
        private let rightLineView = UIView(frame: .zero)

        private let titleStackView: UIStackView = {
            let stack = UIStackView(frame: .zero)
            stack.axis = .horizontal
            stack.alignment = .center
            stack.spacing = 5
            return stack
        }()

        override var intrinsicContentSize: CGSize {
            guard rating != nil else { return .zero }
            return ratedTitleLabel.intrinsicContentSize
        }

        init() {
            super.init(frame: .zero)
            setupLayout()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            drawAGradientLine(inView: leftLineView, leftAligned: true)
            drawAGradientLine(inView: rightLineView, leftAligned: false)
        }

        private func setupLayout() {
            addViewsForAutolayout(views: [titleStackView, leftLineView, rightLineView])
            titleStackView.addArrangedSubview(ratedTitleLabel)
            titleStackView.addArrangedSubview(emojiView)
            titleStackView.layout {
                $0.centerX == centerXAnchor
                $0.top == topAnchor
            }
            NSLayoutConstraint.activate([
                leftLineView.heightAnchor.constraint(equalToConstant: 0.51),
                emojiView.widthAnchor.constraint(equalToConstant: 15),
                emojiView.heightAnchor.constraint(equalToConstant: 15)
            ])
            leftLineView.layout {
                $0.leading == leadingAnchor
                $0.trailing == titleStackView.leadingAnchor - 10
                $0.centerY == centerYAnchor
            }
            rightLineView.layout {
                $0.leading == titleStackView.trailingAnchor + 10
                $0.trailing == trailingAnchor
                $0.height == leftLineView.heightAnchor
                $0.centerY == centerYAnchor
            }
        }

        func drawAGradientLine(inView containerView: UIView, leftAligned: Bool) {
            let gradColors = [
                UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1).cgColor,
                UIColor(red: 0, green: 0, blue: 0, alpha: 0.72) .cgColor
            ]
            let gradientLayer = CAGradientLayer()
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradientLayer.colors = leftAligned ? gradColors : gradColors.reversed()
            gradientLayer.frame = containerView.bounds
            gradientLayer.opacity = 0.65
            containerView.layer.addSublayer(gradientLayer)
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
                let addQuotes = newValue != nil && !newValue.isEmpty
                super.text = addQuotes ? "“\(newValue!)”" : newValue
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
            invalidateIntrinsicContentSize()
            flashScrollIndicators()
        }

        private func setupViews() {
            font = Style.Font.lightItalic(size: 14).font()
            textAlignment = .center
            backgroundColor = .clear
            textColor = .text(.mediumDarkBlackTwo)
            isEditable = false
            showsHorizontalScrollIndicator = false
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
