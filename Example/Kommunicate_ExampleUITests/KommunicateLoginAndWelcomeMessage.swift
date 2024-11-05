//
//  KommunicateLoginAndWelcomeMessage.swift
//  Kommunicate_ExampleUITests
//
//  Created by Abhijeet Ranjan on 05/11/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import XCTest

class KommunicateLoginAndWelcomeMessage: XCTestCase {
    enum GroupData {
        static let AppId = loginCreadentials.testAppID
        static let fillUserId = loginCreadentials.userID
        static let fillPassword = loginCreadentials.password
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        addUIInterruptionMonitor(withDescription: AppPermission.AlertMessage.accessNotificationInApplication) { alerts -> Bool in
            if alerts.buttons[AppPermission.AlertButton.allow].exists {
                alerts.buttons[AppPermission.AlertButton.allow].tap()
            }
            return true
        }
        let app = XCUIApplication()
        if let appId = appIdFromEnvVars() {
            app.launchArguments = [GroupData.AppId, appId]
        }
        app.launch()
        sleep(5)
        if app.buttons[InAppButton.LaunchScreen.logoutButton].exists {
            app.buttons[InAppButton.LaunchScreen.logoutButton].tap()
        }
        guard !XCUIApplication().scrollViews.otherElements.buttons[InAppButton.LaunchScreen.getStarted].exists else {
            login()
            return
        }
    }

    func testLoginAndCustomWelcomeMessage() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        let innerchatscreentableviewTable = app.tables[AppScreen.innerChatScreenTableView]
        let welcomMessageResponse = innerchatscreentableviewTable.textViews[RichMessageResponseText.customWelcomeMessage]
        waitFor(object: welcomMessageResponse) { $0.exists }
    }
    
    private func beforeTest_Launch_NewConversation() -> (XCUIApplication) {
        let app = XCUIApplication()
        let launchConversationButton = app.buttons[InAppButton.EditGroup.launch]
        waitFor(object: launchConversationButton) { $0.exists }
        launchConversationButton.tap()
        sleep(3)
        // Check if the specific screen is on top
        let isScreenOnTop = app.navigationBars[AppScreen.myChatScreen].exists

        if isScreenOnTop {
            // Perform actions only if the screen is not on top
            let createConversationButton = app.navigationBars[AppScreen.myChatScreen]
            waitFor(object: createConversationButton) { $0.exists }
            createConversationButton.buttons[InAppButton.CreatingGroup.startNewIcon].tap()

            let inputView = app.otherElements[AppScreen.chatBar].children(matching: .textView).matching(identifier: AppTextFeild.chatTextView).firstMatch
            waitFor(object: inputView) { $0.exists }
            inputView.tap()
            inputView.tap()
            inputView.tap()
        } else {
            
            let inputView = app.otherElements[AppScreen.chatBar].children(matching: .textView).matching(identifier: AppTextFeild.chatTextView).firstMatch
            waitFor(object: inputView) { $0.exists }
            inputView.tap()
            inputView.tap()
            inputView.tap()
        }

        return app
    }
    
    private func login() {
        sleep(5)
        let path = Bundle(for: KommunicateLoginAndWelcomeMessage.self).url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: path!) as? [String: Any]
        let userId = GroupData.fillUserId
        let password = GroupData.fillPassword
        XCUIApplication().tap()
        let elementsQuery = XCUIApplication().scrollViews.otherElements
        let userIdTextField = elementsQuery.textFields[AppTextFeild.userId]
        userIdTextField.tap()
        userIdTextField.typeText(userId)
        let passwordSecureTextField = elementsQuery.secureTextFields[AppTextFeild.password]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText(password)
        elementsQuery.buttons[InAppButton.LaunchScreen.getStarted].tap()
    }

    private func appIdFromEnvVars() -> String? {
        let path = Bundle(for: KommunicateLoginAndWelcomeMessage.self).url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: path!) as? [String: Any]
        let appId = dict?[GroupData.AppId] as? String
        return appId
    }
}
    

