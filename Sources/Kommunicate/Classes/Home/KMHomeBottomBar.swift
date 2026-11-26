//
//  KMHomeBottomBar.swift
//  Kommunicate
//

import KommunicateChatUI_iOS_SDK
import UIKit

final class KMHomeBottomBar: UIView {
    struct Item {
        let title: String
        let image: UIImage?
    }

    static let contentHeight: CGFloat = 64

    var onSelect: ((Int) -> Void)?

    var accentColor: UIColor {
        didSet { updateSelection() }
    }

    var selectedIndex: Int = 0 {
        didSet { updateSelection() }
    }

    private let buttons: [KMHomeBottomBarButton]

    init(items: [Item], accentColor: UIColor) {
        self.accentColor = accentColor
        buttons = items.map { KMHomeBottomBarButton(item: $0) }
        super.init(frame: .zero)

        backgroundColor = .kmHomeBackground

        let separator = UIView()
        separator.backgroundColor = .kmDynamicColor(
            light: UIColor(white: 0, alpha: 0.08),
            dark: UIColor(white: 1, alpha: 0.12)
        )

        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill

        separator.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        addSubview(stack)

        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: topAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),

            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            stack.heightAnchor.constraint(equalToConstant: Self.contentHeight)
        ])

        for button in buttons {
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
        accessibilityTraits = .tabBar
        updateSelection()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc fileprivate func buttonTapped(_ sender: KMHomeBottomBarButton) {
        guard let index = buttons.firstIndex(of: sender) else { return }
        onSelect?(index)
    }

    private func updateSelection() {
        for (index, button) in buttons.enumerated() {
            button.setSelected(index == selectedIndex, accentColor: accentColor)
        }
    }
}

private final class KMHomeBottomBarButton: UIControl {
    private enum Size {
        static let circle: CGFloat = 36
        static let icon: CGFloat = 17
        static let spacing: CGFloat = 4
    }

    private static let unselectedCircleColor = UIColor.kmDynamicColor(
        light: UIColor(white: 0.94, alpha: 1),
        dark: UIColor(white: 1, alpha: 0.12)
    )
    private static let unselectedIconColor = UIColor.kmDynamicColor(
        light: UIColor(white: 0.2, alpha: 1),
        dark: UIColor(white: 0.9, alpha: 1)
    )
    private static let titleColor = UIColor.kmDynamicColor(
        light: UIColor(white: 0.13, alpha: 1),
        dark: UIColor(white: 0.9, alpha: 1)
    )

    private let circleView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    init(item: KMHomeBottomBar.Item) {
        super.init(frame: .zero)

        circleView.layer.cornerRadius = Size.circle / 2
        circleView.isUserInteractionEnabled = false

        iconView.image = item.image?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: Size.icon, weight: .regular)
        )
        iconView.contentMode = .scaleAspectFit

        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = Self.titleColor
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8

        [circleView, iconView, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        addSubview(circleView)
        circleView.addSubview(iconView)
        addSubview(titleLabel)

        let contentHeight = Size.circle + Size.spacing + titleLabel.font.lineHeight
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            circleView.centerYAnchor.constraint(
                equalTo: centerYAnchor,
                constant: (Size.circle - contentHeight) / 2
            ),
            circleView.widthAnchor.constraint(equalToConstant: Size.circle),
            circleView.heightAnchor.constraint(equalToConstant: Size.circle),

            iconView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: Size.spacing),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2)
        ])

        isAccessibilityElement = true
        accessibilityLabel = item.title
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelected(_ selected: Bool, accentColor: UIColor) {
        isSelected = selected
        circleView.backgroundColor = selected ? accentColor : Self.unselectedCircleColor
        iconView.tintColor = selected ? .white : Self.unselectedIconColor
        accessibilityTraits = selected ? [.button, .selected] : .button
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.6 : 1 }
    }
}
