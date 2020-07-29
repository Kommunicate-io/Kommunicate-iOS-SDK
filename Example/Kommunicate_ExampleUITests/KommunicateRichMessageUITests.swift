//
//  KommunicateRichMessageUITests.swift
//  Kommunicate_ExampleUITests
//
//  Created by Kommunicate on 18/07/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

class KommunicateRichMessageUITests: XCTestCase {
    enum GroupData {
        static let typeText1 = "Suggested Replies"
        static let typeText2 = "Link Button"
        static let typeText3 = "Submit Button"
        static let typeText4 = "Different Button"
        static let typeText5 = "Image"
        static let typeText6 = "List Template"
        static let typeText7 = "Single card"
        static let typeText8 = "Card Carousel"
        static let AppId = "TestAppId"
        static let fillUserId = "TestUserId"
        static let fillPassword = "TestUserPassword"
    }
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        addUIInterruptionMonitor(withDescription: AppPermission.AlertMessage.accessNotificationInApplication) { (alerts) -> Bool in
            if alerts.buttons[AppPermission.AlertButton.allow].exists {
                alerts.buttons[AppPermission.AlertButton.allow].tap()
            }
            return true
        }
        let app = XCUIApplication()
        if let appId = appIdFromEnvVars() {
            app.launchArguments = ["-appId", appId]
        }
        app.launch()
        sleep(5)
        guard !XCUIApplication().scrollViews.otherElements.buttons[InAppButton.LaunchScreen.getStarted].exists else {
            login()
            return
        }
    }
    
    func testSuggestedRepliesTemplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText1) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageButtons.button].tap()
        let _ = app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageResponseText.suggestedButtonResponse].exists
    }
    
    func testLinkbuttonTemplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText2) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageButtons.goToGoogle].tap()
        let _ = app.statusBars.buttons[RichMessageResponseText.linkButtonResponse].exists
    }
    
    func testSubmitButtonTemplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText3) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageButtons.pay].tap()
        let _ = app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageResponseText.submitButtonResponse].exists
    }
    
    func testDifferentButtonTemplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText4) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        let innerchatscreentableviewTable = app.tables[AppScreen.innerChatScreenTableView]
        innerchatscreentableviewTable.staticTexts[RichMessageButtons.submitButton].tap()
        innerchatscreentableviewTable.staticTexts[RichMessageButtons.suggestedReplyButton].tap()
        let _ =  app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageResponseText.differentButtonResponse1].exists
        let _ = app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageResponseText.differentButtonResponse2].exists
        innerchatscreentableviewTable.staticTexts[RichMessageButtons.linkButton].tap()
        let _ = app.statusBars.buttons[RichMessageResponseText.linkButtonResponse].exists
    }
    
    func testImageTemplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText5) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        let ironManStaticText = XCUIApplication().tables[AppScreen.innerChatScreenTableView]
        waitFor(object: ironManStaticText) { $0.exists }
        ironManStaticText.staticTexts[RichMessageResponseText.imageResponse].tap()
    }
    
    func testListTemplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText6) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageButtons.seeUsOnFacebook].tap()
        let _ = app.statusBars.buttons[RichMessageResponseText.linkButtonResponse].exists
    }
    
    func testSingleCardTemplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText7) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageButtons.linkButton].tap()
        let _ = app.statusBars.buttons[RichMessageResponseText.linkButtonResponse].exists
    }
    
    func testCardCarouselTemplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText8) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
    }
    
    private func login() {
        let path = Bundle(for: KommunicateRichMessageUITests.self).url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: path!) as? [String: Any]
        let userId = dict?[GroupData.fillUserId]
        let password = dict?[GroupData.fillPassword]
        XCUIApplication().tap()
        let elementsQuery = XCUIApplication().scrollViews.otherElements
        let userIdTextField = elementsQuery.textFields[AppTextFeild.userId]
        userIdTextField.tap()
        userIdTextField.typeText(userId as! String)
        let passwordSecureTextField = elementsQuery.secureTextFields[AppTextFeild.password]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password as! String)
        elementsQuery.buttons[InAppButton.LaunchScreen.getStarted].tap()
    }
    
    private func beforeTest_Launch_NewConversation () -> (XCUIApplication) {
        let app = XCUIApplication()
        let launchConversationButton = app.buttons[InAppButton.EditGroup.launch]
        waitFor(object: launchConversationButton) { $0.exists }
        launchConversationButton.tap()
        let createConversationButton = app.navigationBars[AppScreen.myChatScreen]
        waitFor(object: createConversationButton) { $0.exists }
        createConversationButton.buttons[InAppButton.CreatingGroup.startNewIcon].tap()
        let inputView = app.otherElements[AppScreen.chatBar].children(matching: .textView).matching(identifier: AppTextFeild.chatTextView).firstMatch
        waitFor(object: inputView) { $0.exists }
        inputView.tap()
        inputView.tap()
        inputView.tap()
        return app
    }
    
    private func appIdFromEnvVars() -> String? {
        let path = Bundle(for: KommunicateRichMessageUITests.self).url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: path!) as? [String: Any]
        let appId = dict?[GroupData.AppId] as? String
        return appId
    }
}
