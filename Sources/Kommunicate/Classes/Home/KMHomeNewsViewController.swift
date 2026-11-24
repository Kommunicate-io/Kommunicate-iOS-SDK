//
//  KMHomeNewsViewController.swift
//  Kommunicate
//

import KommunicateChatUI_iOS_SDK
import UIKit

/// Shows the cards configured with `whatsNewList` in the settings json.
final class KMHomeNewsViewController: KMHomeBaseViewController {
    private let items: [KMWhatsNewItem]

    // Follow the SDK's light/dark mode like the card background, not the system's.
    private let primaryTextColor = UIColor.kmDynamicColor(light: UIColor(white: 0.1, alpha: 1), dark: .white)
    private let secondaryTextColor = UIColor.kmDynamicColor(light: UIColor(white: 0.42, alpha: 1), dark: UIColor(white: 0.7, alpha: 1))

    init(configuration: KMChatConfiguration, items: [KMWhatsNewItem]) {
        self.items = items
        super.init(configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        items.isEmpty ? showEmptyState() : showCards()
    }

    private func showEmptyState() {
        guard let label = makeLabel(
            KMHomeText.string("HomeNewsEmpty", default: "No news available right now."),
            style: .body,
            color: secondaryTextColor
        ) else { return }
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func showCards() {
        let stack = UIStackView(arrangedSubviews: items.enumerated().map { makeCard(for: $1, index: $0) })
        stack.axis = .vertical
        stack.spacing = 16
        addScrollableContent(stack)
    }

    private func makeLabel(_ text: String, style: UIFont.TextStyle, color: UIColor, weight: UIFont.Weight? = nil) -> UILabel? {
        guard !text.isEmpty else { return nil }
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.textColor = color
        label.adjustsFontForContentSizeCategory = true
        let base = UIFont.preferredFont(forTextStyle: style)
        label.font = weight.map { .systemFont(ofSize: base.pointSize, weight: $0) } ?? base
        return label
    }

    private func makeCard(for item: KMWhatsNewItem, index: Int) -> UIView {
        let card = UIView()
        card.backgroundColor = .kmDynamicColor(light: .white, dark: UIColor(white: 0.14, alpha: 1))
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.12
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 2)

        var views: [UIView?] = [
            makeLabel(item.title, style: .title3, color: primaryTextColor),
            makeLabel(item.meta.uppercased(), style: .subheadline, color: secondaryTextColor, weight: .semibold),
            makeLabel(item.description, style: .body, color: secondaryTextColor)
        ]
        if item.openableURL != nil, !item.linkText.isEmpty {
            let button = UIButton(type: .system)
            button.setTitle(item.linkText, for: .normal)
            button.setTitleColor(accentColor, for: .normal)
            button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
            button.titleLabel?.adjustsFontForContentSizeCategory = true
            button.titleLabel?.numberOfLines = 0
            button.contentHorizontalAlignment = .leading
            button.tag = index
            button.addTarget(self, action: #selector(linkTapped(_:)), for: .touchUpInside)
            views.append(button)
        }

        let content = UIStackView(arrangedSubviews: views.compactMap { $0 })
        content.axis = .vertical
        content.spacing = 10
        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20)
        ])
        return card
    }

    @objc private func linkTapped(_ sender: UIButton) {
        guard items.indices.contains(sender.tag), let url = items[sender.tag].openableURL else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
