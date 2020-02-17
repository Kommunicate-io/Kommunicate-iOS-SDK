//
//  KMConversationListViewController.swift
//  Kommunicate
//
//  Created by Sunil on 28/01/20.
//

import Foundation
import ApplozicSwift
import Applozic

public class KMConversationListViewController : ALKBaseViewController, Localizable {

    enum LocalizedText {
        static private let filename = Kommunicate.defaultConfiguration.localizedStringFileName
        static let title = localizedString(forKey: "ConversationListVCTitle", fileName: filename)
        static let NoConversationsLabelText = localizedString(forKey: "NoConversationsLabelText", fileName: filename)
        static let leftBarBackButtonText = localizedString(forKey: "Back", fileName: filename)
        static let unableToCreateConversationError = localizedString(forKey: "UnableToCreateConversationError", fileName: filename)
        static let okButton = localizedString(forKey: "OkButton", fileName: filename)
        static let waitMessage = localizedString(forKey: "WaitMessage", fileName: filename)
    }

    let conversationCreateIdentifier = 112233445
    let faqIdentifier =  11223346

    public var conversationViewController: KMConversationViewController?
    public var conversationViewModelType = ALKConversationViewModel.self
    public var conversationListTableViewController: ALKConversationListTableViewController

    var searchController: UISearchController!
    var searchBar: CustomSearchBar!
    lazy var resultVC = ALKSearchResultViewController(configuration: configuration)

    public var dbService = ALMessageDBService()
    public var viewModel = ALKConversationListViewModel()

    // To check if coming from push notification
    var channelKey: NSNumber?
    var tableView: UITableView

    private var converastionListNavBarItemToken: NotificationToken? = nil
    fileprivate var tapToDismiss: UITapGestureRecognizer!
    fileprivate var alMqttConversationService: ALMQTTConversationService!
    fileprivate let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    fileprivate var localizedStringFileName: String!

    public required init(configuration: ALKConfiguration) {
        conversationListTableViewController = ALKConversationListTableViewController(
            viewModel: viewModel,
            dbService: dbService,
            configuration: configuration,
            showSearch: false
        )
        tableView = conversationListTableViewController.tableView
        super.init(configuration: configuration)
        conversationListTableViewController.delegate = self
        localizedStringFileName = configuration.localizedStringFileName
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(addMessages(notification:)),
                                               name: Notification.Name.newMessageNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name:  UIResponder.keyboardDidHideNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(pushNotification(notification:)), name: Notification.Name.pushNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updateMessageList(notification:)), name: Notification.Name.reloadTable, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updateUserDetails(notification:)), name: Notification.Name.updateUserDetails, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updateChannelName(notification:)), name: Notification.Name.updateChannelName, object: nil)

        converastionListNavBarItemToken = NotificationCenter.default.observe(name: NSNotification.Name(ALKNavigationItem.NSNotificationForConversationListNavigationTap), object: nil, queue: nil) { notification in

            let pushAssist = ALPushAssist()
            guard let notificationInfo = notification.userInfo, let topVc = pushAssist.topViewController, topVc is KMConversationListViewController else {
                return
            }
            let identifier = notificationInfo["identifier"] as? Int
            if identifier == self.conversationCreateIdentifier {
                self.createConversationAndLaunch(notification: notification)
            } else if identifier == self.faqIdentifier {
                guard let vc = notification.object as? KMConversationListViewController else {
                    return
                }
                Kommunicate.openFaq(from: vc, with: Kommunicate.defaultConfiguration)
            }
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        edgesForExtendedLayout = []
        viewModel.prepareController(dbService: dbService)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupMqtt()
        subscribeToConversation()
        dbService.delegate = self
        viewModel.delegate = self
        setupSearchController()
        setupView()
        extendedLayoutIncludesOpaqueBars = true
    }

    open override func viewDidAppear(_: Bool) {
        if  channelKey != nil {
            launchChat(groupId: channelKey)
            channelKey = nil
        }
    }

    private func setupView() {
        setupNavigationRightButtons()
        setupBackButton()
        title = LocalizedText.title

        addChild(conversationListTableViewController)
        view.addSubview(conversationListTableViewController.view)
        conversationListTableViewController.didMove(toParent: self)

        conversationListTableViewController.view.frame = view.bounds
        conversationListTableViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        conversationListTableViewController.view.translatesAutoresizingMaskIntoConstraints = true

        activityIndicator.center = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
        activityIndicator.color = UIColor.gray
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
        self.viewModel.addMessages(messages: list)
    }

    @objc func keyboardDidHide(notification: NSNotification) {
        guard let _ = notification.object  else { return }
        if self.navigationController?.visibleViewController as? KMConversationListViewController != nil, self.configuration.isMessageSearchEnabled, self.searchBar.searchBar.text == "" {
            self.showNavigationItems()
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
        if updateUI == Int(APP_STATE_ACTIVE.rawValue), self.isViewLoaded, self.view.window != nil {
            guard let alert = alertValue as? String else { return }
            let alertComponents = alert.components(separatedBy: ":")
            if alertComponents.count > 1 {
                message.message = alertComponents[1]
            } else {
                message.message = alertComponents.first
            }
            self.viewModel.addMessages(messages: [message])
        } else if updateUI == Int(APP_STATE_INACTIVE.rawValue) {
            // Coming from background

            guard groupId != nil || conversationId != nil else { return }
            self.launchChat(groupId: groupId)
        }
    }

    @objc func updateMessageList(notification: NSNotification) {
        print("Reloadtable notification received")
        guard let list = notification.object as? [Any] else { return }
        self.viewModel.updateMessageList(messages: list)
    }

    @objc func updateUserDetails(notification: NSNotification) {
        print("update user detail notification received")
        guard let userId = notification.object as? String else { return }
        print("update user detail")
        self.viewModel.updateUserDetail(userId: userId) { (success) in
            if success {
                self.tableView.reloadData()
            }
        }
    }

    @objc func updateChannelName(notification: NSNotification) {
        print("update group name notification received")
        guard self.view.window != nil else { return }
        print("update group detail")
        self.tableView.reloadData()
    }

    public override func removeObserver() {
        if alMqttConversationService != nil {
            alMqttConversationService.unsubscribeToConversation()
        }
    }

    func setupBackButton() {
        let back = LocalizedText.leftBarBackButtonText

        let leftBarButtonItem = UIBarButtonItem(title: back, style: .plain, target: self, action: #selector(customBackAction))

        if !configuration.hideBackButtonInConversationList {
            navigationItem.leftBarButtonItem = leftBarButtonItem
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
        searchBar = CustomSearchBar(searchBar: searchController.searchBar)
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
            viewController = KMConversationViewController(configuration: configuration)
            viewController.viewModel = conversationViewModel
        } else {
            viewController = conversationViewController
            viewController.viewModel.channelKey = conversationViewModel.channelKey
            viewController.viewModel.contactId = nil
        }
        push(conversationVC: viewController, with: conversationViewModel)
    }

    @objc func customButtonEvent(_ sender: AnyObject) {
        guard let identifier = sender.tag else {
            return
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ALKNavigationItem.NSNotificationForConversationListNavigationTap), object: self, userInfo: ["identifier": identifier])
    }

    func sync(message: ALMessage) {
        if let viewController = conversationViewController,
            viewController.viewModel != nil,
            viewController.viewModel.contactId == message.contactId,
            viewController.viewModel.channelKey == message.groupId {
            print("Contact id matched1")
            viewController.viewModel.addMessagesToList([message])
        }
        viewModel.prepareController(dbService: dbService)
    }

    @objc func customBackAction() {
        guard let nav = navigationController else { return }
        let poppedVC = nav.popViewController(animated: true)
        if poppedVC == nil {
            dismiss(animated: true, completion: nil)
        }
    }

    override public func showAccountSuspensionView() {
        let accountVC = ALKAccountSuspensionController()
        present(accountVC, animated: false, completion: nil)
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
            navigationController?.pushViewController(conversationVC, animated: false)
        }
    }

    private func showAlert(viewController:KMConversationListViewController) {
        let alertMessage = LocalizedText.unableToCreateConversationError
        let okText = LocalizedText.okButton
        let alert = UIAlertController(
            title: "",
            message: alertMessage,
            preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: okText, style: UIAlertAction.Style.default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }

    private func createConversationAndLaunch(notification:Notification){

        guard let vc = notification.object as? KMConversationListViewController else {
            return
        }
        vc.view.isUserInteractionEnabled = false
        vc.navigationController?.view.isUserInteractionEnabled = false
        let alertView =  displayAlert(viewController : vc)

        Kommunicate.createConversation() { (result) in
            switch result {
            case .success(let conversationId):
                DispatchQueue.main.async {
                    vc.view.isUserInteractionEnabled = true
                    vc.navigationController?.view.isUserInteractionEnabled = true
                    alertView.dismiss(animated: false, completion: nil)
                    Kommunicate.showConversationWith(groupId: conversationId, from: vc, completionHandler: { (success) in
                        print("Conversation was shown")
                    })
                }
            case .failure( _):
                DispatchQueue.main.async {
                    vc.view.isUserInteractionEnabled = true
                    vc.navigationController?.view.isUserInteractionEnabled = true
                    alertView.dismiss(animated: false, completion: {
                        self.showAlert(viewController: vc)
                    })
                }
            }
        }
    }

    private func displayAlert(viewController:KMConversationListViewController) -> UIAlertController {

        let alertTitle = LocalizedText.waitMessage
        let loadingAlertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)

        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        loadingAlertController.view.addSubview(activityIndicator)

        let xConstraint: NSLayoutConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: loadingAlertController.view, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint: NSLayoutConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: loadingAlertController.view, attribute: .centerY, multiplier: 1.4, constant: 0)

        NSLayoutConstraint.activate([ xConstraint, yConstraint])
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()

        let height: NSLayoutConstraint = NSLayoutConstraint(item: loadingAlertController.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 80)
        loadingAlertController.view.addConstraint(height);

        viewController.present(loadingAlertController, animated: true, completion: nil)

        return loadingAlertController
    }
}

extension KMConversationListViewController: ALMessagesDelegate {
    public func getMessagesArray(_ messagesArray: NSMutableArray!) {
        guard let messages = messagesArray as? [Any] else {
            return
        }
        print("Messages loaded: \(messages)")
        viewModel.updateMessageList(messages: messages)
    }

    public func updateMessageList(_ messagesArray: NSMutableArray!) {
        print("updated message array: ", messagesArray)
    }
}

extension KMConversationListViewController: ALKConversationListViewModelDelegate {
    open func startedLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.tableView.isUserInteractionEnabled = false
        }
    }

    open func listUpdated() {
        DispatchQueue.main.async {
            print("Number of rows \(self.tableView.numberOfRows(inSection: 0))")
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.tableView.isUserInteractionEnabled = true
        }
    }

    open func rowUpdatedAt(position: Int) {
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

    open func updateUserDetail(_ userId: String!) {
        guard let userId = userId else { return }
        print("update user detail")
        viewModel.updateUserDetail(userId: userId) { (success) in
            if (success) {
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
        print("sync call: ", alMessage.message)
        guard let message = alMessage else { return }
        let viewController = navigationController?.visibleViewController as? ALKConversationViewController
        if let vm = viewController?.viewModel, vm.contactId != nil || vm.channelKey != nil,
            let visibleController = navigationController?.visibleViewController,
            visibleController.isKind(of: ALKConversationViewController.self),
            isNewMessageForActiveThread(alMessage: alMessage, vm: vm) {
            viewModel.syncCall(viewController: viewController, message: message, isChatOpen: true)

        } else if !isMessageSentByLoggedInUser(alMessage: alMessage) {
            let notificationView = ALNotificationView(alMessage: message, withAlertMessage: message.message)
            notificationView?.showNativeNotificationWithcompletionHandler {
                _ in
                let kmNotificationHelper = KMPushNotificationHelper()
                let  notificationData =  kmNotificationHelper.notificationData(message: message)

                guard !KMPushNotificationHelper().isKommunicateVCAtTop() else {
                    KMPushNotificationHelper().handleNotificationTap(notificationData)
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
        let userDetail = ALUserDetail()
        userDetail.userId = userId
        viewModel.updateStatusFor(userDetail: userDetail)
        guard let viewController = navigationController?.visibleViewController as? KMConversationViewController else {
            return
        }
        viewController.checkUserBlock()
    }

    open func updateLastSeen(atStatus alUserDetail: ALUserDetail!) {
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
    public func tapped(_ chat: ALKChatViewModelProtocol, at index: Int) {

        let convViewModel = conversationViewModelType.init(contactId: chat.contactId, channelKey: chat.channelKey, localizedStringFileName: configuration.localizedStringFileName)
        let convService = ALConversationService()
        if let convId = chat.conversationId, let convProxy = convService.getConversationByKey(convId) {
            convViewModel.conversationProxy = convProxy
        }
        let viewController = conversationViewController ?? KMConversationViewController(configuration: configuration)
        viewController.viewModel = convViewModel
        navigationController?.pushViewController(viewController, animated: false)
    }

    public func emptyChatCellTapped() {

    }

    public func scrolledToBottom() {
        viewModel.fetchMoreMessages(dbService: dbService)
    }

    public func userBlockNotification(userId: String, isBlocked: Bool) {
        viewModel.userBlockNotification(userId : userId,  isBlocked: isBlocked)
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

