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
    static var testAppID: String {
        guard let appID = ProcessInfo.processInfo.environment["MY_SECRET_APP_ID"] else {
            return "<Enter-Your-AppID>" /// Enter your appID here
        }
        return appID
    }
    static var userID: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMyyyy" // Format: 02Jan2025
        let currentDate = dateFormatter.string(from: Date())
        let prefix = "Automation"
        return "\(currentDate)_\(prefix)"
    }
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
        static let doneButton = "DONE"
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
    static let kmVideoPlayerView = "AVPlayerViewController"
    static let autoSuggestionTableView = "KMAutoCompletionTableView"
    static let videoPlayerCell = "KMVideoPlayer"
}

enum AppTextFeild {
    static let userId = "User id (Use a random id for the first time login)"
    static let password = "Password"
    static let chatTextView = "chatTextView"
    static let HeadlineText = "Hi, how can we help you?"
    static let Helpcenter = "Helpcenter | Helpcenter"
}

enum FormData {
    static let name = "Alex Williams"
    static let password = "12345678"
    static let email = "alex@gmail.com"
    static let phoneNumber = "1234567890"
    static let address = "123 Maplewood Avenue, Apt 4B, Springfield, IL 62704, USA"
}

enum FormIdentifier {
    static let name = "Enter your name"
    static let password = "Enter your password"
    static let email = "Enter your email"
    static let phoneNumber = "Enter your phone number"
    static let address = "Enter your address"
    static let dateTime = "dd/MM/yyyy, hh:mm a"
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
    static let customWelcomeMessage = "Hi \(loginCreadentials.userID), how can we help you?"
    static let suggestedButtonResponse = "Cool! send me more."
    static let linkButtonResponse = "Link Button Rich Message"
    static let differentButtonResponse1 = "optional- this message will be used as acknowledgement text when user clicks the button"
    static let differentButtonResponse2 = "text will be sent as message"
    static let submitButtonResponse = "optional, will be used as acknowledgement message to user in case of requestType JSON. Default value is same as name parameter"
    static let formTemplateResponse1 = "optional- this message will be used as acknowledgement text when user clicks the button"
    static let formTemplateResponse2 = "Thank you for submitting your details!"
    static let imageResponse = "IRON MAN"
    static let listTemplateResponse = "List template Rich Message"
    static let singleCardResponse = "Single card template"
    static let cardCarouselResponse = "Carousel"
    static let htlmResponse = "This is a HTML Message."
    static let videoMessageResponse = "This is a Video Message."
    static let youtubeVideoMessageResponse = "This is a YouTube Video Message."
    static let videoCaptionMessage = "Video Example"
    static let autoSuggestionResponse = "This is Auto Suggestion"
    static let submitFirstResponse = "Submit Button Rich Message"
    static let sugggestedRepliesFirstMessage = "Suggested Replies Rich Message"
    static let formFirstResponse = "Submit your details"
}

struct AutoSuggestionReply {
    static let searchKey1 = ["searchKey": "Karnataka", "message": "India"]
    static let searchKey2 = ["searchKey": "Maharashtra", "message": "India"]
    static let searchKey3 = ["searchKey": "California", "message": "USA"]
    static let searchKey4 = ["searchKey": "Texas", "message": "USA"]
    static let searchKey5 = ["searchKey": "Ontario", "message": "Canada"]
    static let searchKey6 = ["searchKey": "British", "message": "Canada"]
    static let searchKey7 = ["searchKey": "England", "message": "UK"]
    static let searchKey8 = ["searchKey": "New", "message": "Australia"]
    static let searchKey9 = ["searchKey": "Bavaria", "message": "Germany"]
    static let searchKey10 = ["searchKey": "Tokyo", "message": "Japan"]
    
    static func getRandomSearchKey() -> [String: String] {
        let allKeys = [
            searchKey1, searchKey2, searchKey3, searchKey4, searchKey5,
            searchKey6, searchKey7, searchKey8, searchKey9, searchKey10
        ]
        return allKeys.randomElement() ?? [:]
    }
}

enum CusotomInputField {
    static let nameFieldResponse = "Hey, what's your name?"
    static let emailFieldResponse = "Enter the email"
    static let phoneNumberFieldResponse = "Enter your phone number"
    static let otpFieldResponse = "Enter the OTP"
    static let finalSuccessResponse = "Hi \(CusotomInputFieldReply.nameFieldResponse), your Email is \(CusotomInputFieldReply.emailFieldResponse) and your  Phone Number \(CusotomInputFieldReply.phoneNumberFieldResponse)"
}

enum CusotomInputFieldReply {
    static let nameFieldResponse = "<Enter Custom Name>"
    static let emailFieldResponse = "<Enter Custom Email>"
    static let phoneNumberFieldResponse = "<Enter Custom Phone Number>"
    static let otpFieldResponse = "<Enter Custom OTP>"
}
