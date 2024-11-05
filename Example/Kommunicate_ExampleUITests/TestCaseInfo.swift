//
//  TestCaseInfo.swift
//  Kommunicate_ExampleUITests
//
//  Created by Archit on 11/06/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

enum AppPermission {
    enum AlertMessage {
        static let accessNotificationInApplication = "“KommunicateDemo” Would Like to Send You Notifications"
        static let accessPhoto = "“KommunicateDemo” Would Like to Access Your Photo Library"
        static let accessContact = "“KommunicateDemo” Would Like to Access Your Contacts"
        static let accessLocation = "“KommunicateDemo” to access your location while you are using the app?"
    }

    enum AlertButton {
        static let allowAllPhotos = "Allow Full Access"
        static let allow = "Allow"
        static let ok = "OK"
        static let allowLoation = "Allow While Using App"
    }
}

enum Configuration {
    static let resgexPattern = "restricted"
}

enum loginCreadentials {
    static let testAppID = "<Enter-Your-AppID>" /// Enter your AppID here
    static let userID = "<Enter-Your-UserID>" /// Enter your UserID for testing
    static let password = "password" /// Enter your password or you can use the same for all users.
}

enum InAppButton {
    enum LaunchScreen {
        static let getStarted = "Get Started"
        static let launchChat = "Launch Chat"
        static let loginAsVisitor = "Login as Visitor"
        static let logoutButton = "Logout"
    }

    enum CreatingGroup {
        static let startNewIcon = "startNewIcon"
    }

    enum EditGroup {
        static let launch = "Launch Conversations"
        static let iconSendWhite = "icon send white"
    }

    enum ConversationScreen {
        static let openCamera = "photoButtonInConversationScreen"
        static let send = "sendButton"
        static let openPhotos = "galleryButtonInConversationScreen"
        static let selectPhoto = "Photos"
        static let openLocation = "locationButtonInConversationScreen"
        static let sendLocation = "Send Location"
        static let done = "Done"
        static let back = "Back"
        static let backButton = "BackButton"
        static let faqButton = "FAQ"
        static let loadingIndicator = "loadingIndicator"
        static let activityIndicator = "activityIndicator"
    }
}

enum AppScreen {
    static let myChatScreen = "My Chats"
    static let chatBar = "chatBar"
    static let innerChatScreenTableView = "InnerChatScreenTableView"
    static let inneritemListView = "InneritemListView"
    static let kMConversationView = "Kommunicate.KMConversationView"
}

enum AppTextFeild {
    static let userId = "User id (Use a random id for the first time login)"
    static let password = "Password"
    static let chatTextView = "chatTextView"
    static let HeadlineText = "Hi, how can we help you?"
    static let Helpcenter = "Helpcenter | Helpcenter"
}

enum RichMessageButtons {
    static let button = "Button"
    static let goToGoogle = "Go To Google"
    static let pay = "Pay"
    static let male = "Male"
    static let metal = "Metal"
    static let pop = "Pop"
    static let submit = "Submit"
    static let suggestedReplyButton = "Suggested reply Button"
    static let submitButton = "submit button"
    static let seeUsOnFacebook = "See us on facebook"
    static let linkButton = "Link Button"
}

enum RichMessageResponseText {
    static let welcomeMessage = "Hi, how can we help you?"
    static let suggestedButtonResponse = "Cool! send me more."
    static let linkButtonResponse = "Link Button Rich Message"
    static let differentButtonResponse1 = "optional- this message will be used as acknowledgement text when user clicks the button"
    static let differentButtonResponse2 = "text will be sent as message"
    static let submitButtonResponse = "optional, will be used as acknowledgement message to user in case of requestType JSON. Default value is same as name parameter"
    static let formTemplateResponse = "optional- this message will be used as acknowledgement text when user clicks the button"
    static let imageResponse = "IRON MAN"
    static let listTemplateResponse = "List template Rich Message"
    static let singleCardResponse = "Single card template"
    static let cardCarouselResponse = "Carousel"
    static let submitFirstResponse = "Submit Button Rich Message"
    static let sugggestedRepliesFirstMessage = "Suggested Replies Rich Message"
    static let formFirstResponse = "Submit your details"
}
