//
//  KMConversationListViewController.swift
//  Kommunicate
//
//  Created by Sunil on 28/01/20.
//

import Foundation
import KommunicateChatUI_iOS_SDK
import KommunicateCore_iOS_SDK

public class KMConversationListViewController: ALKBaseViewController, Localizable {
    enum LocalizedText {
        private static let filename = Kommunicate.defaultConfiguration.localizedStringFileName
        static let title = localizedString(forKey: "ConversationListVCTitle", fileName: filename)
        static let NoConversationsLabelText = localizedString(forKey: "NoConversationsLabelText", fileName: filename)
        static let leftBarBackButtonText = localizedString(forKey: "Back", fileName: filename)
        static let unableToCreateConversationError = localizedString(forKey: "UnableToCreateConversationError", fileName: filename)
        static let okButton = localizedString(forKey: "OkButton", fileName: filename)
        static let waitMessage = localizedString(forKey: "WaitMessage", fileName: filename)
        static let startNewConversationTitle = localizedString(forKey: "StartNewConversationButtonTitle", fileName: filename)
    }

    let faqIdentifier = 11_223_346

    public var conversationViewController: KMConversationViewController?
    public var conversationViewModelType = ALKConversationViewModel.self
    public var conversationListTableViewController: ALKConversationListTableViewController
    private let registerUserClientService = ALRegisterUserClientService()

    let channelService = ALChannelService()
    var searchController: UISearchController!
    var searchBar: KMCustomSearchBar!
    lazy var resultVC = ALKSearchResultViewController(configuration: configuration)

    public var dbService = ALMessageDBService()
    public var viewModel = ALKConversationListViewModel()
    
    var isSingleThreadedEnabled = KMCoreSettings.getIsSingleThreadedEnabled()

    enum Padding {
        enum NoConversationLabel {
            static let leading: CGFloat = 10.0
            static let trailing: CGFloat = 10.0
        }

        enum StartNewButton {
            static let height: CGFloat = 50
            static let width: CGFloat = 50
        }
        
        // Start New Conversation Button at the botton
        enum StartNewConversationButton {
            static let width = 260.0
            static let height: CGFloat = 48.0
            static let cornorRadius: CGFloat = height/2
            static let bottom: CGFloat = -50.0
            static let leading: CGFloat = -32
        }
    }

    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .kmDynamicColor(light: .white, dark: UIColor.backgroundDarkColor())
        return view
    }()

    lazy var startNewButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(compose), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }()

    lazy var startNewConversationBottomButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(compose), for: .touchUpInside)
        let lightColor = kmConversationViewConfiguration.startNewConversationButtonBackgroundColor ?? ALKAppSettingsUserDefaults().getAppBarTintColor()
        let darkColor = kmConversationViewConfiguration.startNewConversationButtonDarkBackgroundColor ?? ALKAppSettingsUserDefaults().getAppBarTintColor()
        let backgroundColor = UIColor.kmDynamicColor(light: lightColor, dark: darkColor)
        button.backgroundColor = backgroundColor
        button.setTitle(LocalizedText.startNewConversationTitle, for: .normal)
        let darkTitleColor = kmConversationViewConfiguration.startNewConversationButtonDarkTextColor ?? kmConversationViewConfiguration.startNewConversationButtonTextColor
        button.setTitleColor(UIColor.kmDynamicColor(light: kmConversationViewConfiguration.startNewConversationButtonTextColor, dark: darkTitleColor), for: .normal)
        button.isUserInteractionEnabled = true
        if configuration.hideBottomStartNewConversationButton || isSingleThreadedEnabled {
            button.isHidden = true
        }
        return button
    }()
    
    lazy var noConversationLabel: UILabel = {
        let label = UILabel()
        label.text = localizedString(forKey: "NoConversationsLabelText", fileName: configuration.localizedStringFileName)
        label.textColor = UIColor.kmDynamicColor(light: .black, dark: .white)
        label.textAlignment = .center
        label.numberOfLines = 3
        label.font = Font.normal(size: 18).font()
        return label
    }()

    // To check if coming from push notification
    var channelKey: NSNumber?
    var tableView: UITableView

    private let kmConversationViewConfiguration: KMConversationViewConfiguration

    lazy var rightBarButtonItem: UIBarButtonItem = {
        let icon = UIImage(named: "startNewIcon", in: Bundle.kommunicate, compatibleWith: nil)
        let barButton = UIBarButtonItem(
            image: icon,
            style: .plain,
            target: self, action: #selector(compose)
        )
        barButton.accessibilityIdentifier = "startNewIcon"
        return barButton
    }()

    private var converastionListNavBarItemToken: NotificationToken?
    fileprivate var tapToDismiss: UITapGestureRecognizer!
    fileprivate var alMqttConversationService: ALMQTTConversationService!
    fileprivate let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    fileprivate var localizedStringFileName: String!

    public required init(configuration: ALKConfiguration, kmConversationViewConfiguration: KMConversationViewConfiguration) {
        conversationListTableViewController = ALKConversationListTableViewController(
            viewModel: viewModel,
            dbService: dbService,
            configuration: configuration,
            showSearch: false
        )
        conversationListTableViewController.hideNoConversationView = true
        tableView = conversationListTableViewController.tableView
        self.kmConversationViewConfiguration = kmConversationViewConfiguration
        tableView.isHidden = true
        super.init(configuration: configuration)
        conversationListTableViewController.delegate = self
        localizedStringFileName = configuration.localizedStringFileName
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(configuration _: ALKConfiguration) {
        fatalError("init(configuration:) has not been implemented")
    }

    override public func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(addMessages(notification:)),
                                               name: Notification.Name.newMessageNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(pushNotification(notification:)), name: Notification.Name.pushNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updateMessageList(notification:)), name: Notification.Name.reloadTable, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updateUserDetails(notification:)), name: Notification.Name.updateUserDetails, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updateChannelName(notification:)), name: Notification.Name.updateChannelName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(conversationDeleted(notification: )), name: Notification.Name.conversationDeletion, object: nil)

        converastionListNavBarItemToken = NotificationCenter.default.observe(name: NSNotification.Name(ALKNavigationItem.NSNotificationForConversationListNavigationTap), object: nil, queue: nil) { notification in

            let pushAssist = ALPushAssist()
            guard let notificationInfo = notification.userInfo,
                  let topVc = pushAssist.topViewController,
                  topVc is KMConversationListViewController
            else {
                return
            }
            let identifier = notificationInfo["identifier"] as? Int
            if identifier == self.faqIdentifier {
                guard let vc = notification.object as? KMConversationListViewController else {
                    return
                }
                Kommunicate.openFaq(from: vc, with: self.configuration)
            }
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        edgesForExtendedLayout = []
        viewModel.prepareController(dbService: dbService)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setupMqtt()
        subscribeToConversation()
        isSingleThreadedEnabled = KMCoreSettings.getIsSingleThreadedEnabled()
        dbService.delegate = self
        viewModel.delegate = self
        setupSearchController()
        setupView()
        checkPlanAndShowSuspensionScreen()
        extendedLayoutIncludesOpaqueBars = true
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if channelKey != nil {
            launchChat(groupId: channelKey)
            channelKey = nil
        }
    }

    private func setupView() {
        setupNavigationRightButtons()
        setupBackButton()
        title = LocalizedText.title
        setupViewAndConstraints()
    }

    func setupViewAndConstraints() {
        view.isUserInteractionEnabled = false
        var image = kmConversationViewConfiguration.startNewButtonIcon?.scale(with: CGSize(width: Padding.StartNewButton.width, height: Padding.StartNewButton.height))
        image = image?.withRenderingMode(.alwaysTemplate)
        startNewButton.setImage(image, for: .normal)

        backgroundView.addViewsForAutolayout(views: [startNewButton, noConversationLabel, startNewConversationBottomButton, conversationListTableViewController.view])
        view.addViewsForAutolayout(views: [backgroundView])

        activityIndicator.color = UIColor.gray
        backgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        
        if configuration.hideEmptyStateStartNewButtonInConversationList || kmConversationViewConfiguration.startNewButtonIcon == nil {
            noConversationLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
            noConversationLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
        } else {
            startNewButton.widthAnchor.constraint(equalToConstant: Padding.StartNewButton.width).isActive = true
            startNewButton.heightAnchor.constraint(equalToConstant: Padding.StartNewButton.height).isActive = true
            startNewButton.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
            startNewButton.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
            noConversationLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: Padding.NoConversationLabel.leading).isActive = true
            noConversationLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -Padding.NoConversationLabel.trailing).isActive = true
            noConversationLabel.topAnchor.constraint(equalTo: startNewButton.bottomAnchor, constant: 10.0).isActive = true
        }
       
        if !(configuration.hideBottomStartNewConversationButton || isSingleThreadedEnabled) {
            startNewConversationBottomButton.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
            startNewConversationBottomButton.widthAnchor.constraint(equalToConstant: Padding.StartNewConversationButton.width).isActive = true
            startNewConversationBottomButton.heightAnchor.constraint(equalToConstant: Padding.StartNewConversationButton.height).isActive = true
            startNewConversationBottomButton.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: Padding.StartNewConversationButton.bottom).isActive = true
            startNewConversationBottomButton.layer.cornerRadius = Padding.StartNewConversationButton.cornorRadius
            backgroundView.bringSubviewToFront(startNewConversationBottomButton)
        }
    
        conversationListTableViewController.view.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        conversationListTableViewController.view.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        conversationListTableViewController.view.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        conversationListTableViewController.view.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true

        activityIndicator.center = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
    }

    func setupMqtt() {
        alMqttConversationService = ALMQTTConversationService.sharedInstance()
        alMqttConversationService.mqttConversationDelegate = self
    }

    func subscribeToConversation() {
        alMqttConversationService.subscribeToConversation()
    }

    @objc func addMessages(notification: NSNotification) {
        guard let msgArray = notification.object as? [ALMessage] else { return }
        print("new notification received: ", msgArray.first?.message ?? "")
        guard let list = notification.object as? [Any], !list.isEmpty else { return }
        viewModel.addMessages(messages: list)
    }

    @objc func keyboardDidHide(notification: NSNotification) {
        guard let _ = notification.object else { return }
        if navigationController?.visibleViewController is KMConversationListViewController, configuration.isMessageSearchEnabled, searchBar.searchBar.text == "" {
            showNavigationItems()
        }
    }

    @objc func pushNotification(notification: NSNotification) {
        print("push notification received: ", notification.object ?? "")
        guard let object = notification.object as? String else { return }
        let components = object.components(separatedBy: ":")
        var groupId: NSNumber?
        var contactId: String?
        var conversationId: NSNumber?

        if components.count > 2 {
            let groupComponent = Int(components[1])
            groupId = NSNumber(integerLiteral: groupComponent!)
        } else if components.count == 2 {
            let conversationComponent = Int(components[1])
            conversationId = NSNumber(integerLiteral: conversationComponent!)
            contactId = components[0]
        } else {
            contactId = object
        }

        let message = ALMessage()
        message.contactIds = contactId
        message.groupId = groupId
        let info = notification.userInfo
        let alertValue = info?["alertValue"]
        guard let updateUI = info?["updateUI"] as? Int else { return }
        if updateUI == Int(APP_STATE_ACTIVE.rawValue), isViewLoaded, view.window != nil {
            guard let alert = alertValue as? String else { return }
            let alertComponents = alert.components(separatedBy: ":")
            if alertComponents.count > 1 {
                message.message = alertComponents[1]
            } else {
                message.message = alertComponents.first
            }
            viewModel.addMessages(messages: [message])
        } else if updateUI == Int(APP_STATE_INACTIVE.rawValue) {
            // Coming from background

            guard groupId != nil || conversationId != nil else { return }
            launchChat(groupId: groupId)
        }
    }

    @objc func updateMessageList(notification: NSNotification) {
        print("Reloadtable notification received")
        guard let list = notification.object as? [Any] else { return }
        viewModel.updateMessageList(messages: list)
    }

    @objc func updateUserDetails(notification: NSNotification) {
        print("update user detail notification received")
        guard let userId = notification.object as? String else { return }
        print("update user detail")
        viewModel.updateUserDetail(userId: userId) { success in
            if success {
                self.tableView.reloadData()
            }
        }
    }

    @objc func updateChannelName(notification _: NSNotification) {
        print("update group name notification received")
        guard view.window != nil else { return }
        print("update group detail")
        tableView.reloadData()
    }
    
    @objc func conversationDeleted(notification: NSNotification) {
        guard let conversation = notification.object as? ALMessage else { return }
        deleteConversation(conversation: conversation)
    }
    
    private func deleteConversation(conversation: ALMessage) {
        ALMessageService().deleteMessageThread(nil, orChannelKey: conversation.groupId, withCompletion: {
            _, error in
            guard error == nil else {
                print("Failed to delete the conversation: \(error.debugDescription)")
                return
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            let channelDbService = ALChannelDBService()
            channelDbService.deleteChannel(conversation.groupId)
            self.viewModel.remove(message: conversation)
            self.tableView.reloadData()
        })
    }

    override public func removeObserver() {
        if alMqttConversationService != nil {
            alMqttConversationService.unsubscribeToConversation()
        }
    }

    func setupBackButton() {
        guard !configuration.hideBackButtonInConversationList else { return }
        
        if configuration.enableBackArrowOnConversationListScreen {
            navigationItem.leftBarButtonItem = getBackArrowButton(target: self, action: #selector(customBackAction))
        } else {
            navigationItem.leftBarButtonItem = getBackTextButton(title: LocalizedText.leftBarBackButtonText, target: self, action: #selector(customBackAction))
        }
    }

    func setupNavigationRightButtons() {
        let navigationItems = configuration.navigationItemsForConversationList

        var rightBarButtonItems: [UIBarButtonItem] = []
        if configuration.isMessageSearchEnabled {
            let barButton = UIBarButtonItem(
                image: UIImage(named: "search", in: Bundle.kommunicate, compatibleWith: nil),
                style: .plain,
                target: self, action: #selector(searchTapped)
            )
            rightBarButtonItems.append(barButton)
        }

        if !configuration.hideStartChatButton {
            rightBarButtonItems.append(rightBarButtonItem)
        }

        for item in navigationItems {
            let uiBarButtonItem = item.barButton(target: self, action: #selector(customButtonEvent(_:)))

            if let barButtonItem = uiBarButtonItem {
                rightBarButtonItems.append(barButtonItem)
            }
        }
        if !rightBarButtonItems.isEmpty {
            let rightButtons = rightBarButtonItems.prefix(3)
            navigationItem.rightBarButtonItems = Array(rightButtons)
        }
    }

    func setupSearchController() {
        searchController = resultVC.setUpSearchViewController()
        searchController.searchBar.delegate = self
        searchBar = KMCustomSearchBar(searchBar: searchController.searchBar)
        definesPresentationContext = true
    }

    @objc private func searchTapped() {
        navigationItem.rightBarButtonItems = nil
        navigationItem.leftBarButtonItems = nil
        navigationItem.titleView = searchBar

        UIView.animate(
            withDuration: 0.5,
            animations: { self.searchBar.show(true) },
            completion: { _ in self.searchBar.becomeFirstResponder() }
        )
    }

    func launchChat(groupId: NSNumber?) {
        let conversationViewModel = viewModel.conversationViewModelOf(type: conversationViewModelType, contactId: nil, channelId: groupId, conversationId: nil, localizedStringFileName: localizedStringFileName)

        let viewController: KMConversationViewController!
        if conversationViewController == nil {
            viewController = KMConversationViewController(configuration: configuration, conversationViewConfiguration: kmConversationViewConfiguration, individualLaunch: false)
            viewController.viewModel = conversationViewModel
        } else {
            viewController = conversationViewController
            viewController.viewModel.channelKey = conversationViewModel.channelKey
            viewController.viewModel.contactId = nil
        }
        viewController.individualLaunch = false
        push(conversationVC: viewController, with: conversationViewModel)
    }

    @objc func customButtonEvent(_ sender: AnyObject) {
        guard let identifier = sender.tag else {
            return
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ALKNavigationItem.NSNotificationForConversationListNavigationTap), object: self, userInfo: ["identifier": identifier])
    }

    @objc func compose() {
        createConversationAndLaunch()
    }

    func sync(message: ALMessage) {
        if let viewController = conversationViewController,
           ALPushAssist().topViewController is KMConversationViewController,
           viewController.viewModel != nil,
           viewController.viewModel.channelKey == message.groupId {
            viewController.viewModel.addMessagesToList([message])
        }
        viewModel.prepareController(dbService: dbService)
    }

    @objc func customBackAction() {
        KMCustomEventHandler.shared.publish(triggeredEvent: KMCustomEvent.conversationListBackPress, data: nil)
        guard let nav = navigationController else { return }
        let poppedVC = nav.popViewController(animated: true)
        if poppedVC == nil {
            dismiss(animated: true, completion: nil)
        }
    }

    override public func showAccountSuspensionView() {
        let accountVC = ALKAccountSuspensionController()
        present(accountVC, animated: true, completion: nil)
        accountVC.isModalInPresentation = true
        accountVC.closePressed = { [weak self] in
            let popVC = self?.navigationController?.popViewController(animated: true)
            if popVC == nil {
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }

    func conversationVC() -> KMConversationViewController? {
        return navigationController?.topViewController as? KMConversationViewController
    }

    fileprivate func push(conversationVC: KMConversationViewController, with viewModel: ALKConversationViewModel) {
        if let topVC = navigationController?.topViewController as? KMConversationViewController {
            // Update the details and refresh
            topVC.unsubscribingChannel()
            topVC.viewModel.contactId = viewModel.contactId
            topVC.viewModel.channelKey = viewModel.channelKey
            topVC.viewModel.conversationProxy = viewModel.conversationProxy
            topVC.viewWillLoadFromTappingOnNotification()
            topVC.refreshViewController()
        } else {
            // push conversation VC
            conversationVC.viewWillLoadFromTappingOnNotification()
            navigationController?.pushViewController(conversationVC, animated: true)
        }
    }

    func showNoConversationsView(_ show: Bool) {
        view.isUserInteractionEnabled = true
        conversationListTableViewController.tableView.isHidden = show
        noConversationLabel.isHidden = !show
        if configuration.hideBottomStartNewConversationButton || isSingleThreadedEnabled {
            startNewConversationBottomButton.isHidden = true
        }
        startNewButton.isHidden = configuration.hideEmptyStateStartNewButtonInConversationList
    }

    private func showAlert() {
        guard let topVC = ALPushAssist().topViewController,
              topVC is KMConversationListViewController
        else {
            return
        }
        let alertMessage = LocalizedText.unableToCreateConversationError
        let okText = LocalizedText.okButton
        let alert = UIAlertController(
            title: "",
            message: alertMessage,
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: okText, style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func createConversationAndLaunch() {
        view.isUserInteractionEnabled = false
        let alertView = displayAlert(viewController: self)
        
        let conversationBuilder = KMConversationBuilder()
        let configuration = Kommunicate.defaultConfiguration
        
        // Check for default Setting & update the conversation.
        if let defaultBotIds = configuration.defaultBotIds, !defaultBotIds.isEmpty {
            conversationBuilder.withBotIds(defaultBotIds)
        }
        
        if let defaultAgentIds = configuration.defaultAgentIds, !defaultAgentIds.isEmpty {
            conversationBuilder.withAgentIds(defaultAgentIds)
        }
        
        if configuration.defaultSkipRouting {
            conversationBuilder.skipRouting(true)
        }
        
        if let defaultTeamId = configuration.defaultTeamId, !defaultTeamId.isEmpty {
            conversationBuilder.withTeamId(defaultTeamId)
        }
        
        if let defaultAssignee = configuration.defaultAssignee, !defaultAssignee.isEmpty {
            conversationBuilder.withDefaultConversationAssignee(defaultAssignee)
        }
        
        Kommunicate.createConversation(conversation: conversationBuilder.build()) { result in
            switch result {
            case let .success(conversationId):
                self.channelService.getChannelInformation(byResponse: nil, orClientChannelKey: conversationId, withCompletion: { _, channel, _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                        self.view.isUserInteractionEnabled = true
                        alertView.dismiss(animated: true, completion: nil)

                        guard let alChannel = channel else {
                            print("Failed to launch the conversation")
                            return
                        }
                        self.launchChat(groupId: alChannel.key)
                    })
                })
            case .failure:
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    alertView.dismiss(animated: true, completion: {
                        self.showAlert()
                    })
                }
            }
        }
    }

    private func displayAlert(viewController: KMConversationListViewController) -> UIAlertController {
        let alertTitle = LocalizedText.waitMessage
        let loadingAlertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        loadingAlertController.view.addSubview(activityIndicator)

        let xConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: loadingAlertController.view, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: loadingAlertController.view, attribute: .centerY, multiplier: 1.4, constant: 0)

        NSLayoutConstraint.activate([xConstraint, yConstraint])
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()

        let height = NSLayoutConstraint(item: loadingAlertController.view as Any, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 80)
        loadingAlertController.view.addConstraint(height)

        viewController.present(loadingAlertController, animated: true, completion: nil)

        return loadingAlertController
    }

    private func checkPlanAndShowSuspensionScreen() {
        let accountVC = ALKAccountSuspensionController()
        accountVC.isModalInPresentation = true
        guard PricingPlan.shared.showSuspensionScreen() else { return }
        present(accountVC, animated: true, completion: nil)
        accountVC.closePressed = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        registerUserClientService.syncAccountStatus { response, error in
            guard error == nil, let response = response, response.isRegisteredSuccessfully() else {
                print("Failed to sync the account package status")
                return
            }
            print("Successfuly synced the account package status")
        }
    }
}

extension KMConversationListViewController: ALMessagesDelegate {
    public func getMessagesArray(_ messagesArray: NSMutableArray!) {
        guard let messages = messagesArray as? [Any], !messages.isEmpty else {
            viewModel.delegate?.listUpdated()
            return
        }
        showNoConversationsView(false)
        print("Messages loaded: \(messages)")
        viewModel.updateMessageList(messages: messages)
    }

    public func updateMessageList(_ messagesArray: NSMutableArray!) {
        print("Updated message array: ", messagesArray ?? "empty")
    }
}

extension KMConversationListViewController: ALKConversationListViewModelDelegate {
    public func startedLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.tableView.isUserInteractionEnabled = false
        }
    }

    public func listUpdated() {
        DispatchQueue.main.async {
            print("Number of rows \(self.tableView.numberOfRows(inSection: 0))")
            if self.viewModel.getChatList().isEmpty {
                self.showNoConversationsView(true)
            }
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.tableView.isUserInteractionEnabled = true
        }
    }

    public func rowUpdatedAt(position: Int) {
        tableView.reloadRows(at: [IndexPath(row: position, section: 0)], with: .automatic)
    }
}

extension KMConversationListViewController: ALMQTTConversationDelegate {
    open func mqttDidConnected() {
        if let viewController = navigationController?.visibleViewController as? KMConversationViewController {
            viewController.subscribeChannelToMqtt()
        }
        print("MQTT did connected")
    }
    
    public func userOnlineStatusChanged(_ contactId: String!, status: String!) {
        guard let viewcontroller = navigationController?.visibleViewController as? KMConversationViewController else {
               print("Unable to update agent online status : No KMConversationViewController available")
               return
              }
        viewcontroller.updateAssigneeOnlineStatus(userId: contactId)
    }

    open func updateUserDetail(_ userId: String!) {
        guard let userId = userId else { return }
        print("update user detail")
        viewModel.updateUserDetail(userId: userId) { success in
            if success {
                self.tableView.reloadData()
            }
        }
    }

    public func isNewMessageForActiveThread(alMessage: ALMessage, vm: ALKConversationViewModel) -> Bool {
        let isGroupMessage = alMessage.groupId != nil && alMessage.groupId == vm.channelKey
        let isOneToOneMessage = alMessage.groupId == nil && vm.channelKey == nil && alMessage.contactId == vm.contactId
        if isGroupMessage || isOneToOneMessage {
            return true
        }
        return false
    }

    func isMessageSentByLoggedInUser(alMessage: ALMessage) -> Bool {
        if alMessage.isSentMessage() {
            return true
        }
        return false
    }

    open func syncCall(_ alMessage: ALMessage!, andMessageList _: NSMutableArray!) {
        print("sync call: ", alMessage.message ?? "empty")
        guard let message = alMessage else { return }
        let viewController = navigationController?.visibleViewController as? KMConversationViewController
        if let vm = viewController?.viewModel, vm.contactId != nil || vm.channelKey != nil,
           let visibleController = navigationController?.visibleViewController,
           visibleController.isKind(of: KMConversationViewController.self),
           isNewMessageForActiveThread(alMessage: alMessage, vm: vm) {
            viewModel.syncCall(viewController: viewController, message: message, isChatOpen: true)

        } else if !isMessageSentByLoggedInUser(alMessage: alMessage) {
            let notificationView = ALNotificationView(alMessage: message, withAlertMessage: message.message)
            notificationView?.showNativeNotificationWithcompletionHandler {
                _ in
                let kmNotificationHelper = KMPushNotificationHelper(self.configuration, self.kmConversationViewConfiguration)
                let notificationData = kmNotificationHelper.notificationData(message: message)

                guard !kmNotificationHelper.isKommunicateVCAtTop() else {
                    kmNotificationHelper.handleNotificationTap(notificationData)
                    return
                }
                self.launchChat(groupId: message.groupId)
            }
        }
        if let visibleController = navigationController?.visibleViewController,
           visibleController.isKind(of: KMConversationListViewController.self) {
            sync(message: alMessage)
        }
    }

    open func delivered(_ messageKey: String!, contactId: String!, withStatus status: Int32) {
        guard let viewController = conversationViewController ?? conversationVC(), viewController.viewModel != nil else {
            return
        }

        viewModel.updateDeliveryReport(convVC: viewController, messageKey: messageKey, contactId: contactId, status: status)
    }

    open func updateStatus(forContact contactId: String!, withStatus status: Int32) {
        guard let viewController = conversationViewController ?? conversationVC(), viewController.viewModel != nil else {
            return
        }

        viewModel.updateStatusReport(convVC: viewController, forContact: contactId, status: status)
    }

    open func updateTypingStatus(_: String!, userId: String!, status: Bool) {
        print("Typing status is", status)

        guard let viewController = conversationViewController ?? conversationVC(), let vm = viewController.viewModel else { return
        }
        guard (vm.contactId != nil && vm.contactId == userId) || vm.channelKey != nil else {
            return
        }
        print("Contact id matched")
        viewModel.updateTypingStatus(in: viewController, userId: userId, status: status)
    }

    open func reloadData(forUserBlockNotification userId: String!, andBlockFlag _: Bool) {
        print("reload data")
        let userDetail = KMCoreUserDetail()
        userDetail.userId = userId
        viewModel.updateStatusFor(userDetail: userDetail)
        guard let viewController = navigationController?.visibleViewController as? KMConversationViewController else {
            return
        }
        viewController.checkUserBlock()
    }

    open func updateLastSeen(atStatus alUserDetail: KMCoreUserDetail!) {
        print("Last seen updated")
        viewModel.updateStatusFor(userDetail: alUserDetail)
        guard let viewController = navigationController?.visibleViewController as? KMConversationViewController else {
            return
        }
        viewController.updateLastSeen(atStatus: alUserDetail)
    }

    open func mqttConnectionClosed() {
        print("ALKConversationListVC mqtt connection closed.")
        alMqttConversationService.retryConnection()
    }

}

extension KMConversationListViewController: ALKConversationListTableViewDelegate {
    public func tapped(_ chat: ALKChatViewModelProtocol, at _: Int) {
        let convViewModel = conversationViewModelType.init(contactId: chat.contactId, channelKey: chat.channelKey, localizedStringFileName: configuration.localizedStringFileName)
        let viewController = conversationViewController ?? KMConversationViewController(configuration: configuration, conversationViewConfiguration: kmConversationViewConfiguration, individualLaunch: false)
        viewController.viewModel = convViewModel
        viewController.individualLaunch = false
        navigationController?.pushViewController(viewController, animated: true)
    }

    public func emptyChatCellTapped() {}

    public func scrolledToBottom() {
        viewModel.fetchMoreMessages(dbService: dbService)
    }

    public func userBlockNotification(userId: String, isBlocked: Bool) {
        viewModel.userBlockNotification(userId: userId, isBlocked: isBlocked)
    }

    public func muteNotification(conversation: ALMessage, isMuted: Bool) {
        viewModel.muteNotification(conversation: conversation, isMuted: isMuted)
    }

    func showNavigationItems() {
        searchBar.show(false)
        searchBar.resignFirstResponder()
        navigationItem.titleView = nil
        setupBackButton()
        setupNavigationRightButtons()
    }
}

extension KMConversationListViewController: UISearchBarDelegate {
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchKey = searchBar.text, !searchKey.isEmpty else {
            return
        }
        resultVC.search(key: searchKey)
    }

    public func searchBar(_: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            resultVC.clearAndReload()
        }
    }

    public func searchBarCancelButtonClicked(_: UISearchBar) {
        showNavigationItems()
        resultVC.clear()
    }
}
