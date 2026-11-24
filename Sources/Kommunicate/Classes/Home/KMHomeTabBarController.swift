//
//  KMHomeTabBarController.swift
//  Kommunicate
//
//  Home screen: Welcome, Conversations, FAQ and News tabs.
//

import KommunicateChatUI_iOS_SDK
import UIKit

enum KMHomeText {
    /// Looks in the app's strings file first, then in the SDK's strings, like `Localizable`.
    static func string(_ key: String, default defaultValue: String) -> String {
        let sdkValue = NSLocalizedString(key, tableName: nil, bundle: .kommunicate, value: defaultValue, comment: "")
        return NSLocalizedString(
            key,
            tableName: Kommunicate.defaultConfiguration.localizedStringFileName,
            bundle: .main,
            value: sdkValue,
            comment: ""
        )
    }

    static var welcome: String { string("HomeTabWelcome", default: "Welcome") }
    static var conversations: String { string("HomeTabConversations", default: "Conversations") }
    static var news: String { string("HomeTabNews", default: "News") }
    static var faq: String { string("FaqTitle", default: "FAQ") }
}

extension UIColor {
    /// Screen background of the home screen and the conversation list.
    static var kmHomeBackground: UIColor {
        .kmDynamicColor(light: .white, dark: UIColor.backgroundDarkColor())
    }
}

/// Base class of the Welcome, News and FAQ tabs. Gives them the same back button as the conversation list.
class KMHomeBaseViewController: UIViewController {
    let configuration: KMChatConfiguration

    init(configuration: KMChatConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var accentColor: UIColor {
        KMChatAppSettingsUserDefaults().getAppBarTintColor()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .kmHomeBackground
        setupBackButton()
    }

    /// Adds `content` to a vertical scroll view inset by 16pt on every side.
    func addScrollableContent(_ content: UIView) {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(content)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            content.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16)
        ])
    }

    private func setupBackButton() {
        guard !configuration.hideBackButtonInConversationList else { return }
        let button = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        button.tintColor = configuration.conversationListScreenBackButtonColor
        button.accessibilityLabel = KMHomeText.string("Back", default: "Back")
        if #available(iOS 26.0, *) {
            button.hidesSharedBackground = true
        }
        navigationItem.leftBarButtonItem = button
    }

    /// Closes the whole home screen.
    @objc func backTapped() {
        KMCustomEventHandler.shared.publish(triggeredEvent: KMCustomEvent.conversationListBackPress, data: nil)
        (tabBarController ?? self).dismiss(animated: true, completion: nil)
    }
}

final class KMHomeTabBarController: UITabBarController {
    private static let conversationsTabIndex = 1

    init(conversationListViewController: KMConversationListViewController) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        if !UIColor.isKMDarkModeEnabled {
            overrideUserInterfaceStyle = .light
        }

        let configuration = Kommunicate.defaultConfiguration
        let welcomeVC = KMHomeWelcomeViewController(configuration: configuration)
        welcomeVC.onViewConversations = { [weak self] in
            self?.selectedIndex = Self.conversationsTabIndex
        }
        conversationListViewController.hidesFaqNavigationItem = true

        let faqVC = KMHomeFaqViewController(configuration: configuration)
        let newsVC = KMHomeNewsViewController(configuration: configuration, items: KMHomeSettings.whatsNewList)

        let tabs: [(root: UIViewController, title: String, symbols: [String])] = [
            (welcomeVC, KMHomeText.welcome, ["face.smiling", "house"]),
            (conversationListViewController, KMHomeText.conversations, ["bubble.left"]),
            (faqVC, KMHomeText.faq, ["questionmark.circle"]),
            (newsVC, KMHomeText.news, ["sparkles", "star"])
        ]
        viewControllers = tabs.map { tab in
            let nav = KMBaseNavigationViewController(rootViewController: tab.root)
            nav.view.backgroundColor = .kmHomeBackground
            nav.tabBarItem = UITabBarItem(
                title: tab.title,
                image: tab.symbols.lazy.compactMap { UIImage(systemName: $0) }.first,
                selectedImage: nil
            )
            tab.root.title = tab.title
            return nav
        }

        view.backgroundColor = .kmHomeBackground
        tabBar.tintColor = KMChatAppSettingsUserDefaults().getAppBarTintColor()
        // iOS 26 keeps the system's floating glass bar.
        if #unavailable(iOS 26.0) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .kmHomeBackground
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        }
        selectedIndex = Self.conversationsTabIndex
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
