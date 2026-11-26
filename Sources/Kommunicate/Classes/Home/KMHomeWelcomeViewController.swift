//
//  KMHomeWelcomeViewController.swift
//  Kommunicate
//

import UIKit

final class KMHomeWelcomeViewController: KMHomeBaseViewController {
    var onViewConversations: (() -> Void)?

    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()

    private let waveLabel: UILabel = {
        let label = UILabel()
        label.text = "👋"
        label.font = .systemFont(ofSize: 44)
        return label
    }()

    private let helloLabel: UILabel = {
        let label = UILabel()
        label.text = KMHomeText.string("HomeWelcomeHello", default: "Hello").uppercased()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        return label
    }()

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.text = KMHomeText.string("HomeWelcomeHeadline", default: "How can we help you?")
        label.font = .preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private lazy var viewConversationsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(KMHomeText.string("HomeViewConversations", default: "View conversations"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
        button.layer.cornerRadius = 26
        button.addTarget(self, action: #selector(viewConversationsTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "homeViewConversationsButton"
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        cardView.backgroundColor = accentColor
        viewConversationsButton.backgroundColor = accentColor

        let textStack = UIStackView(arrangedSubviews: [waveLabel, helloLabel, headlineLabel])
        textStack.axis = .vertical
        textStack.spacing = 12
        textStack.setCustomSpacing(20, after: waveLabel)
        textStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(textStack)
        NSLayoutConstraint.activate([
            textStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            textStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -32),
            textStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            textStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24)
        ])

        let contentStack = UIStackView(arrangedSubviews: [cardView, viewConversationsButton])
        contentStack.axis = .vertical
        contentStack.spacing = 20
        addScrollableContent(contentStack)
    }

    @objc private func viewConversationsTapped() {
        onViewConversations?()
    }
}
