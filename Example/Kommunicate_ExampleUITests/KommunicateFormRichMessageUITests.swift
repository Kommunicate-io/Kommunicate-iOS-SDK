//
//  KommunicateFormRichMessageUITests.swift
//  Kommunicate_ExampleUITests
//
//  Created by Kommunicate on 29/08/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

class KommunicateFormRichMessageUITests: XCTestCase {
    enum GroupData {
        static let typeText = "Form"
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
    
    func testFormTemplate() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        app.typeText(GroupData.typeText) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        let innerchatscreentableviewTable = app.tables[AppScreen.innerChatScreenTableView]
        innerchatscreentableviewTable.staticTexts[RichMessageButtons.male].tap()
        innerchatscreentableviewTable.staticTexts[RichMessageButtons.metal].tap()
        innerchatscreentableviewTable.staticTexts[RichMessageButtons.pop].tap()
        app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageButtons.submit].tap()
        app.tables[AppScreen.innerChatScreenTableView].textViews.staticTexts[RichMessageResponseText.formTemplateResponse].tap()
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
