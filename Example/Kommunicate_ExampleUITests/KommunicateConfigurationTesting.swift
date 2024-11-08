//
//  KommunicateConfigurationTesting.swift
//  Kommunicate_ExampleUITests
//
//  Created by Abhijeet Ranjan on 04/11/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import XCTest

class KommunicateRegexConfigurationTesting: XCTestCase {
    enum GroupData {
        static let restrictedText = "This message is containg word restricted which is not allowed"
        static let validText = "This messaga dosen't contain any regex word."
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
        app.launchEnvironment["restrictedMessageRegexPattern"] = Configuration.resgexPattern
        if let appId = appIdFromEnvVars() {
            app.launchArguments = [GroupData.AppId, appId]
        }
        app.launch()
        sleep(5)
        guard !XCUIApplication().scrollViews.otherElements.buttons[InAppButton.LaunchScreen.getStarted].exists else {
            login()
            return
        }
    }
    
    func testRegexInChatBar() {
        let appInstance = beforeTest_Launch_NewConversation()
        waitFor(object: appInstance) { $0.exists }
        
        appInstance.typeText(GroupData.restrictedText)
        appInstance.buttons[InAppButton.ConversationScreen.send].tap()
        sleep(3) // Wait for response
        
        appInstance.buttons["Ok"].tap()
        
        appInstance.typeText(GroupData.validText)
        appInstance.buttons[InAppButton.ConversationScreen.send].tap()
        
        let sendMessage = appInstance.tables[AppScreen.innerChatScreenTableView]
            .textViews[GroupData.validText]
    }

    
    private func login() {
        let path = Bundle(for: KommunicateRichMessageUITests.self).url(forResource: "Info", withExtension: "plist")
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

    private func appIdFromEnvVars() -> String? {
        let path = Bundle(for: KommunicateRichMessageUITests.self).url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: path!) as? [String: Any]
        let appId = dict?[GroupData.AppId] as? String
        return appId
    }
}
