//
//  KommunicatePreChatUITests.swift
//  Kommunicate_ExampleUITests
//
//  Created by Abhijeet Ranjan on 21/02/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import XCTest

class KommunicatePreChatUITests: XCTestCase {
    enum GroupData {
        static let AppId = loginCreadentials.testAppID
    }
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        sleep(10)
        addUIInterruptionMonitor(withDescription: AppPermission.AlertMessage.accessNotificationInApplication) { alerts -> Bool in
            if alerts.buttons[AppPermission.AlertButton.allow].exists {
                alerts.buttons[AppPermission.AlertButton.allow].tap()
            }
            return true
        }
        let app = XCUIApplication()
        app.launchEnvironment["isFaqUITestEnabled"] = "true"
        if let appId = appIdFromEnvVars() {
            app.launchArguments = [GroupData.AppId, appId]
        }
        app.launch()
        sleep(5)
        guard XCUIApplication().scrollViews.otherElements.buttons[InAppButton.LaunchScreen.getStarted].exists else {
            logout()
            return
        }
    }
    
    func testPreChatLeadCollection() {
        let app = XCUIApplication()
        
        if app.buttons[InAppButton.LaunchScreen.logoutButton].exists {
            app.buttons[InAppButton.LaunchScreen.logoutButton].tap()
        }
        
        let loginAsVisitorButton = app.buttons[InAppButton.LaunchScreen.loginAsVisitor]
        waitFor(object: loginAsVisitorButton) { $0.exists }
        loginAsVisitorButton.tap()
        
        sleep(2)
        
        let emailField = app.textFields[PreChatFormText.email]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5), "Email field not found")
        emailField.tap()
        app.typeText(PreChatFormReply.emailFieldResponse)

        let nameField = app.textFields[PreChatFormText.name]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5), "Name field not found")
        nameField.tap()
        app.typeText(PreChatFormReply.nameFieldResponse)

        let phoneField = app.textFields[PreChatFormText.phoneNumber]
        XCTAssertTrue(phoneField.waitForExistence(timeout: 5), "Phone number field not found")
        phoneField.tap()
        app.typeText(PreChatFormReply.phoneNumberFieldResponse)

        app.swipeUp()
        sleep(5)

        tapSubmitButtonIfNeeded()
        sleep(5)
        
        let launchConversationButton = app.buttons[InAppButton.EditGroup.launch]
        waitFor(object: launchConversationButton) { $0.exists }
    }
    
    func testPreChatLeadCollectionFromDashborad() {
        let app = XCUIApplication()
        app.launchEnvironment["isFaqUIFromDashboardTestEnabled"] = "true"
        if let appId = appIdFromEnvVars() {
            app.launchArguments = [GroupData.AppId, appId]
        }
        app.launch()
        
        if app.buttons[InAppButton.LaunchScreen.logoutButton].exists {
            app.buttons[InAppButton.LaunchScreen.logoutButton].tap()
        }
        
        let loginAsVisitorButton = app.buttons[InAppButton.LaunchScreen.loginAsVisitor]
        waitFor(object: loginAsVisitorButton) { $0.exists }
        loginAsVisitorButton.tap()
        
        let emailField = app.textFields[PreChatFormText.email]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5), "Email field not found")
        emailField.tap()
        app.typeText(PreChatFormReply.emailFieldResponse)

        let nameField = app.textFields[PreChatFormText.name]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5), "Name field not found")
        nameField.tap()
        app.typeText(PreChatFormReply.nameFieldResponse)

        let phoneField = app.textFields[PreChatFormText.phoneNumber]
        XCTAssertTrue(phoneField.waitForExistence(timeout: 5), "Phone number field not found")
        phoneField.tap()
        app.typeText(PreChatFormReply.phoneNumberFieldResponse)

        app.swipeUp()
        sleep(5)
        
        app.buttons[PreChatFormText.startConversation].tap()
        sleep(10)
        
        let innerchatscreentableviewTable = app.tables[AppScreen.innerChatScreenTableView]
        let welcomMessageResponse = innerchatscreentableviewTable.textViews[RichMessageResponseText.welcomeMessage]
        waitFor(object: welcomMessageResponse) { $0.exists }
    }
    
    func tapSubmitButtonIfNeeded() {
        let app = XCUIApplication()
        let submitButton = app.buttons[PreChatFormText.submit]
        
        if submitButton.waitForExistence(timeout: 5) {
            var attempts = 0
            
            while attempts < 5 {
                if submitButton.isHittable {
                    submitButton.tap()
                    print("Tapped Submit Button - Attempt \(attempts + 1)")
                    sleep(1)
                    
                    if !submitButton.exists {
                        print("Submit Button disappeared after tapping")
                        break
                    }
                } else {
                    print("Submit Button is not tappable - Attempt \(attempts + 1)")
                }
                
                attempts += 1
            }
        } else {
            XCTFail("Submit Button not found within 5 seconds")
        }
    }
    
    private func logout() {
        let app = XCUIApplication()
        if app.buttons[InAppButton.LaunchScreen.logoutButton].exists {
            app.buttons[InAppButton.LaunchScreen.logoutButton].tap()
        }
    }
    
    private func appIdFromEnvVars() -> String? {
        let path = Bundle(for: KommunicateCreateConversationAndSendMessagesTests.self).url(forResource: "Info", withExtension: "plist")
        let appId = GroupData.AppId
        return appId
    }
}

