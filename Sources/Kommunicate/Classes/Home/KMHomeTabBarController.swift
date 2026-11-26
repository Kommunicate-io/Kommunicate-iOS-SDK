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

    private static var tabInfo: [(title: String, symbols: [String])] {
        [
            (KMHomeText.welcome, ["face.smiling", "house"]),
            (KMHomeText.conversations, ["bubble.left"]),
            (KMHomeText.faq, ["questionmark.circle"]),
            (KMHomeText.news, ["sparkles", "star"])
        ]
    }

    private let bottomBar: KMHomeBottomBar

    init(conversationListViewController: KMConversationListViewController) {
        let tabInfo = Self.tabInfo
        bottomBar = KMHomeBottomBar(
            items: tabInfo.map { info in
                KMHomeBottomBar.Item(
                    title: info.title,
                    image: info.symbols.lazy.compactMap { UIImage(systemName: $0) }.first
                )
            },
            accentColor: KMChatAppSettingsUserDefaults().getAppBarTintColor()
        )
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

        let roots: [UIViewController] = [welcomeVC, conversationListViewController, faqVC, newsVC]
        let tabs = zip(roots, tabInfo).map { pair in (root: pair.0, title: pair.1.title) }

        viewControllers = tabs.map { tab in
            let nav = KMBaseNavigationViewController(rootViewController: tab.root)
            nav.view.backgroundColor = .kmHomeBackground
            nav.tabBarItem = UITabBarItem(title: tab.title, image: nil, selectedImage: nil)
            nav.delegate = self
            tab.root.title = tab.title
            tab.root.additionalSafeAreaInsets.bottom = KMHomeBottomBar.contentHeight
            return nav
        }

        view.backgroundColor = .kmHomeBackground
        selectedIndex = Self.conversationsTabIndex
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var selectedIndex: Int {
        didSet { selectionChanged() }
    }

    override var selectedViewController: UIViewController? {
        didSet { selectionChanged() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bottomBar.onSelect = { [weak self] index in
            self?.bottomBarSelected(index)
        }
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)
        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -KMHomeBottomBar.contentHeight
            )
        ])
        hideSystemTabBar()
        selectionChanged()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hideSystemTabBar()
        view.bringSubviewToFront(bottomBar)
    }

    /// Selects the Conversations tab at its root and returns the conversation list.
    func showConversationsTab() -> KMConversationListViewController? {
        selectedIndex = Self.conversationsTabIndex
        let nav = selectedViewController as? UINavigationController
        nav?.popToRootViewController(animated: false)
        return nav?.viewControllers.first as? KMConversationListViewController
    }

    private func bottomBarSelected(_ index: Int) {
        guard let controllers = viewControllers, controllers.indices.contains(index) else { return }
        let target = controllers[index]
        if target === selectedViewController {
            (target as? UINavigationController)?.popToRootViewController(animated: true)
            return
        }
        if delegate?.tabBarController?(self, shouldSelect: target) == false { return }
        selectedIndex = index
        delegate?.tabBarController?(self, didSelect: target)
    }

    private func selectionChanged() {
        guard isViewLoaded, bottomBar.superview != nil else { return }
        bottomBar.selectedIndex = selectedIndex
        setBottomBarHidden(shouldHideBottomBar(in: selectedViewController as? UINavigationController))
    }

    private func hideSystemTabBar() {
        if #available(iOS 18.0, *), !isTabBarHidden {
            setTabBarHidden(true, animated: false)
        }
        if !tabBar.isHidden {
            tabBar.isHidden = true
        }
    }

    private func shouldHideBottomBar(in nav: UINavigationController?) -> Bool {
        nav?.viewControllers.contains { $0.hidesBottomBarWhenPushed } ?? false
    }

    private func setBottomBarHidden(_ hidden: Bool) {
        bottomBar.isHidden = hidden
        bottomBar.alpha = 1
        bottomBar.transform = .identity
    }
}

extension KMHomeTabBarController: UINavigationControllerDelegate {
    func navigationController(_ nav: UINavigationController, willShow _: UIViewController, animated: Bool) {
        guard nav === selectedViewController else { return }
        let hide = shouldHideBottomBar(in: nav)
        guard hide != bottomBar.isHidden else { return }

        guard animated, let coordinator = nav.transitionCoordinator else {
            setBottomBarHidden(hide)
            return
        }
        let offscreen = CGAffineTransform(translationX: 0, y: bottomBar.bounds.height)
        bottomBar.isHidden = false
        if !hide {
            bottomBar.transform = offscreen
        }
        coordinator.animate(alongsideTransition: { _ in
            self.bottomBar.transform = hide ? offscreen : .identity
        }, completion: { _ in
            self.setBottomBarHidden(self.shouldHideBottomBar(in: nav))
        })
    }

    func navigationController(_: UINavigationController, didShow _: UIViewController, animated _: Bool) {
        hideSystemTabBar()
    }
}
