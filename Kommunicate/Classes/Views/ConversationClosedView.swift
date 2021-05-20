//
//  ConversationClosedView.swift
//  ApplozicSwift
//
//  Created by Mukesh on 17/02/20.
//

import UIKit

class ConversationClosedView: UIView {

    var restartTapped: (()->(Void))?

    private let previousRatingView = SubmittedFeedbackView()

    private let conversationResolvedLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.textColor = .text(.brownishGreyTwo)
        label.font = Style.Font.normal(size: 15).font()
        label.backgroundColor = .clear
        label.text = LocalizedText.conversationResolved
        return label
    }()

    private let otherQueriesLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.textColor = .text(.warmGrey)
        label.font = Style.Font.normal(size: 15).font()
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizedText.otherQueries
        return label
    }()

    private let restartConversationButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = Style.Font.normal(size: 15).font()
        button.backgroundColor = .clear
        button.setTitleColor(.text(.warmBlue), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(LocalizedText.restartConversation, for: .normal)
        return button
    }()

    private let restartConversationStackView: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .center
        sv.spacing = Size.RestartConversationView.spacing
        return sv
    }()

    override var isHidden: Bool {
        didSet {
            guard oldValue != isHidden else { return }
            self.invalidateIntrinsicContentSize()
            self.superview?.setNeedsLayout()
            self.superview?.layoutIfNeeded()
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: conversationResolvedLabel.intrinsicContentSize.width,
            height: isHidden ? 0 : (Size.maxHeight + previousRatingView.intrinsicContentSize.height)
        )
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func restartConversationTapped() {
        restartTapped?()
    }

    func setFeedback(_ feedback: Feedback) {
        previousRatingView.feedback = feedback
    }

    func clearFeedback() {
        previousRatingView.feedback = nil
    }

    private func setupView() {
        restartConversationButton.addTarget(
            self,
            action: #selector(restartConversationTapped),
            for: .touchUpInside
        )
        self.backgroundColor = .background(.mediumGrey)
        setupLayout()
    }

    private func setupLayout() {
        restartConversationStackView.addArrangedSubview(otherQueriesLabel)
        restartConversationStackView.addArrangedSubview(restartConversationButton)
        addViewsForAutolayout(views: [
            previousRatingView,
            conversationResolvedLabel,
            restartConversationStackView
        ])

        previousRatingView.layout {
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.bottom ==
                conversationResolvedLabel.topAnchor + Size.PreviousFeedbackView.bottom
            $0.top >= topAnchor
        }

        NSLayoutConstraint.activate([
            conversationResolvedLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor,
                constant: Size.ConversationResolvedLabel.leading
            ),
            conversationResolvedLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor,
                constant: Size.ConversationResolvedLabel.trailing
            ),
            conversationResolvedLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            conversationResolvedLabel.bottomAnchor.constraint(
                equalTo: restartConversationStackView.topAnchor,
                constant: Size.ConversationResolvedLabel.bottom
            ),
            restartConversationStackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor,
                constant: Size.RestartConversationView.leading
            ),
            restartConversationStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor,
                constant: Size.RestartConversationView.trailing
            ),
            restartConversationStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            restartConversationStackView.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: Size.RestartConversationView.bottom
            )
        ])
    }
}

extension ConversationClosedView: Localizable {
    enum LocalizedText {
        static private let filename = Kommunicate.defaultConfiguration.localizedStringFileName

        static let conversationResolved = localizedString(
            forKey: "ConversationClosedDescription",
            fileName: filename
        )
        static let otherQueries = localizedString(
            forKey: "ConversationClosedOtherQueries",
            fileName: filename
        )
        static let restartConversation = localizedString(
            forKey: "ConversationClosedRestartConversation",
            fileName: filename
        )
    }
}

extension ConversationClosedView {
    enum Size {
        static let maxHeight: CGFloat = 85

        enum PreviousFeedbackView {
            static let bottom: CGFloat = -16
        }

        enum ConversationResolvedLabel {
            static let leading: CGFloat = 30
            static let trailing: CGFloat = -30
            static let bottom: CGFloat = -18
        }

        enum RestartConversationView {
            static let leading: CGFloat = 30
            static let trailing: CGFloat = -30
            static let bottom: CGFloat = -5
            static let spacing: CGFloat = 8
        }
    }
}
