//
//  FeedbackRatingView.swift
//  Kommunicate
//
//  Created by Mukesh on 03/12/19.
//

import Foundation

class FeedbackRatingView: UIView {

    private let sadEmojiButton: EmojiRatingButton = {
        let button = EmojiRatingButton(frame: .zero, rating: .sad)
        button.tag = 1
        return button
    }()

    private let confusedEmojiButton: EmojiRatingButton = {
        let button = EmojiRatingButton(frame: .zero, rating: .confused)
        button.tag = 2
        return button
    }()

    private let happyEmojiButton: EmojiRatingButton = {
        let button = EmojiRatingButton(frame: .zero, rating: .happy)
        button.tag = 3
        return button
    }()

    private let emojiStackView: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.alignment = .fill
        sv.spacing = 40
        return sv
    }()

    private var onRatingTap: ((EmojiRatingButton.Tag) -> Void)?
    private lazy var ratingButtons = [
        sadEmojiButton,
        confusedEmojiButton,
        happyEmojiButton
    ]

    private var selectedRatingTag = 0 {
        didSet {
            guard selectedRatingTag >= 1 && selectedRatingTag <= 3 && selectedRatingTag != oldValue
                else {
                    return
            }
            // update state of all buttons
            ratingButtons.forEach { $0.isInactive = ($0.tag != selectedRatingTag) }
        }
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        addConstraints()
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        onRatingTap = { [weak self] tag in
            self?.selectedRatingTag = tag
        }
        ratingButtons.forEach { $0.ratingTapped = onRatingTap }
    }

    private func addConstraints() {
        ratingButtons.forEach { emojiStackView.addArrangedSubview($0) }
        addViewsForAutolayout(views: [emojiStackView])

        NSLayoutConstraint.activate([
            emojiStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emojiStackView.topAnchor.constraint(equalTo: topAnchor),
            emojiStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

class EmojiRatingButton: UIView {

    typealias Tag = Int

    enum IconName {
        static let sad = "sad_emoji"
        static let confused = "confused_emoji"
        static let happy = "happy_emoji"
    }

    enum RatingType {
        case sad
        case confused
        case happy

        // TODO: Localization
        func title() -> String {
            switch self {
            case .sad:
                return "Poor"
            case .confused:
                return "Average"
            case .happy:
                return "Great"
            }
        }

        func icon() -> UIImage? {
            var name = ""
            switch self {
            case .sad:
                name = IconName.sad
            case .confused:
                name = IconName.confused
            case .happy:
                name = IconName.happy
            }
            return UIImage(named: name, in: Bundle.kommunicate, compatibleWith: nil)
        }
    }

    var selectedStateWidth: CGFloat = 42
    var ratingTapped: ((Tag) -> Void)?

    var isInactive: Bool = false {
        didSet {
            emojiButton.isInactive = isInactive
            // Avoid when the current button state is same
            guard emojiButton.isSelected == isInactive else { return }
            toggleButton()
        }
    }

    let rating: RatingType

    private let emojiButton: Button = {
        let button = Button(frame: .zero)
        button.adjustsImageWhenHighlighted = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // FIXME: Add font and text color
    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 2
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let verticalStack: UIStackView = {
        let stackview = UIStackView(frame: .zero)
        stackview.axis = .vertical
        stackview.alignment = .center
        stackview.distribution = .fillProportionally
        return stackview
    }()

    private lazy var normalStateWidth = selectedStateWidth*0.8
    private lazy var emojiWidthConstraint = emojiButton.widthAnchor.constraint(
        equalToConstant: normalStateWidth
    )

    init(frame: CGRect, rating: RatingType) {
        self.rating = rating
        super.init(frame: frame)
        addConstraints()
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        emojiButton.setBackgroundImage(rating.icon(), for: .normal)
        emojiButton.setBackgroundImage(rating.icon()?.noir, for: .inactive)
        titleLabel.text = rating.title()
        titleLabel.alpha = 0
        emojiButton.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
        emojiButton.layoutIfNeeded()
        emojiButton.subviews.first?.contentMode = .scaleAspectFit
    }

    private func addConstraints() {
        verticalStack.addArrangedSubview(emojiButton)
        verticalStack.addArrangedSubview(titleLabel)
        addViewsForAutolayout(views: [verticalStack])

        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: topAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            emojiWidthConstraint,
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1)
        ])
    }

    @objc private func tapped(_ button: UIButton) {
        ratingTapped?(tag)
    }

    private func toggleButton() {
        var buttonWidth: CGFloat = selectedStateWidth
        var labelAlpha: CGFloat = 1

        if emojiButton.isSelected {
            buttonWidth = normalStateWidth
            labelAlpha = 0
        }
        emojiButton.isSelected = !emojiButton.isSelected
        emojiWidthConstraint.constant = buttonWidth
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.layoutIfNeeded()
            self.titleLabel.alpha = labelAlpha
        })
    }
}

extension EmojiRatingButton {
    class Button: UIButton {

        var isInactive: Bool = false {
            didSet {
                setNeedsLayout()
            }
        }

        override var state: UIControl.State {
            get {
                return isInactive ? UIControl.State(rawValue: super.state.rawValue |
                    UIControl.State.inactive.rawValue) : super.state
            }
        }
    }
}

private extension UIControl.State {
    static let inactive = UIControl.State(rawValue: 1 << 16)
}
