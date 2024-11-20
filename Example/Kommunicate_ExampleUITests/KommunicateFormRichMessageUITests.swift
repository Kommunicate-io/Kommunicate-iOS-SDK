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
        static let typeText1 = "Form Template 1"
        static let typeText2 = "Form Template 2"
        static let typeText3 = "Form Template 3"
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
        guard !XCUIApplication().scrollViews.otherElements.buttons[InAppButton.LaunchScreen.getStarted].exists else {
            login()
            return
        }
    }

    func testFormTemplate1() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        sleep(4)
        app.typeText(GroupData.typeText1) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        let formFirstResponse = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.formFirstResponse]
        waitFor(object: formFirstResponse) { $0.exists }
        let nameField = app.tables.textFields[FormIdentifier.name]
        let passwordField = app.tables.secureTextFields[FormIdentifier.password]
        waitFor(object: nameField) { $0.exists }
        nameField.tap()
        nameField.typeText(FormData.name)
        passwordField.tap()
        passwordField.typeText(FormData.password)
        let innerchatscreentableviewTable = app.tables[AppScreen.innerChatScreenTableView]
        innerchatscreentableviewTable.staticTexts[RichMessageButtons.male].tap()
        innerchatscreentableviewTable.staticTexts[RichMessageButtons.metal].tap()
        innerchatscreentableviewTable.staticTexts[RichMessageButtons.pop].tap()
        app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageButtons.submit].tap()
        let submitResponse = innerchatscreentableviewTable.textViews[RichMessageResponseText.formTemplateResponse1]
        waitFor(object: submitResponse) { $0.exists }
    }
    
    func testFormTemplate2() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        sleep(4)
        app.typeText(GroupData.typeText2) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        let formFirstResponse = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.formFirstResponse]
        waitFor(object: formFirstResponse) { $0.exists }
        let nameField = app.tables.textFields[FormIdentifier.name]
        let passwordField = app.tables.secureTextFields[FormIdentifier.password]
        let emailField = app.tables.textFields[FormIdentifier.email]
        let phoneField = app.tables.textFields[FormIdentifier.phoneNumber]
        let addressField = app.tables.textFields[FormIdentifier.address]
        waitFor(object: nameField) { $0.exists }
        nameField.tap()
        nameField.typeText(FormData.name)
        passwordField.tap()
        passwordField.typeText(FormData.password)
        emailField.tap()
        emailField.typeText(FormData.email)
        phoneField.tap()
        phoneField.typeText(FormData.phoneNumber)
        addressField.tap()
        addressField.typeText(FormData.address)
        let innerchatscreentableviewTable = app.tables[AppScreen.innerChatScreenTableView]
        app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageButtons.submit].tap()
        let submitResponse = innerchatscreentableviewTable.textViews[RichMessageResponseText.formTemplateResponse2]
        waitFor(object: submitResponse) { $0.exists }
    }
    
    func testFormTemplate3() {
        let app = beforeTest_Launch_NewConversation()
        waitFor(object: app) { $0.exists }
        sleep(4)
        app.typeText(GroupData.typeText3) // typing message
        app.buttons[InAppButton.ConversationScreen.send].tap() // sending message in group
        let formFirstResponse = app.tables[AppScreen.innerChatScreenTableView]
            .textViews[RichMessageResponseText.formFirstResponse]
        waitFor(object: formFirstResponse) { $0.exists }
        let nameField = app.tables.textFields[FormIdentifier.name]
        let passwordField = app.tables.secureTextFields[FormIdentifier.password]
        waitFor(object: nameField) { $0.exists }
        nameField.tap()
        nameField.typeText(FormData.name)
        passwordField.tap()
        passwordField.typeText(FormData.password)
        
        let dateField = app.tables.textFields[FormIdentifier.dateTime]
        dateField.tap()
        sleep(1)
        app.buttons[InAppButton.ConversationScreen.doneButton].tap()
        sleep(1)
        let innerchatscreentableviewTable = app.tables[AppScreen.innerChatScreenTableView]
        innerchatscreentableviewTable.staticTexts[RichMessageButtons.male].tap()
        app.tables[AppScreen.innerChatScreenTableView].staticTexts[RichMessageButtons.submit].tap()
        let submitResponse = innerchatscreentableviewTable.textViews[RichMessageResponseText.formTemplateResponse1]
        waitFor(object: submitResponse) { $0.exists }
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
        if app.buttons[InAppButton.LaunchScreen.logoutButton].exists {
            app.buttons[InAppButton.LaunchScreen.logoutButton].tap()
            sleep(5)
            let loginAsVisitorButton = app.scrollViews.otherElements
            loginAsVisitorButton.buttons[InAppButton.LaunchScreen.loginAsVisitor].tap()
        }
        
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
        let appId = GroupData.AppId
        return appId
    }
}
