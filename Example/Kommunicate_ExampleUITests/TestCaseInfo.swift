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
        for bundle in Bundle.allBundles {
            if let value = bundle.object(forInfoDictionaryKey: "KOMMUNICATE_APP_ID") as? String {
                return value
            }
        }
        return "<SET_YOUR_APP_ID>"
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


enum loginWelcomeMessageCredentialsTest {
    private static let _userID: String = generateRandomName()

    static let userID: String = _userID

    static let password = "password"

    private static func generateRandomName() -> String {
        let firstNames = ["John", "Emily", "Michael", "Sophia", "David"]
        let lastNames = ["Smith", "Johnson", "Brown", "Taylor", "Anderson"]
        let number = (0...999).randomElement()!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMyyyy" // Format: 02Jan2025
        let currentDate = dateFormatter.string(from: Date())
        let randomFirstName = firstNames.randomElement()!
        let randomLastName = lastNames.randomElement()!
        return "\(randomFirstName)_\(randomLastName)_\(number)_\(currentDate)"
    }
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
        static let restartConversation = "Restart conversation"
        static let moreButton = "more_button"
        static let ratingButtonTitle = "Rate this conversation"
        static let ratingSubmitButton = "Submit your rating"
        static let cancelRatingButton = "cancel icon"
    }
    
    enum RatingOptions {
        static let ratingOptions: [RatingFeedback] = [
            RatingFeedback(rating: "sad emoji", comment: "The conversation was not handled properly. Not satisfied with the result."),
            RatingFeedback(rating: "confused emoji", comment: "The response was unclear. Need better clarification."),
            RatingFeedback(rating: "happy emoji", comment: "Great experience! Satisfied with the support.")
        ]

        static var randomRating: RatingFeedback {
            return ratingOptions.randomElement() ?? RatingFeedback(rating: "confused emoji", comment: "The response was unclear. Need better clarification.")
        }
    }
}

enum AppScreen {
    static let myChatScreen = "My Chats"
    static let chatBar = "chatBar"
    static let awayMessageView = "awayMessageView"
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
    static let awayMessageLabel = "awayMessageLabel"
    static let emailMessageLabel = "emailMessageLabel"
    static let HeadlineText = "Hi, how can we help you?"
    static let Helpcenter = "Helpcenter | Helpcenter"
    static let ratingCommnetTextView = "KMRatingCommentsTextView"
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
    static let resolveButton = "Resolve Conversation"
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
    static let welcomeMessage = "how can we help you?"
    static let customWelcomeMessage = "Hi \(loginWelcomeMessageCredentialsTest.userID),"
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
    static let formFirstResponse = "Input your details"
    static let resolveConversationSuggestedButtonMessage = "Are you sure you want to close the conversation."
    static let resolveConversationButtonResponseMessage = "We are resolving this conversation. Please reach out to us in case of any more queries."
    static let restartConversationResponse = "The conversation restarted successfully."
    static let assignementMessageResponse = "Now this conversation is Assigned to Human."
    static let awayMessageResponse = "The agent is currently unavailable. Please wait for sometime the agent will connect with you."
    static let csatResponseMessage = "Please share the Rating for the Conversation."
    static let csatIntentResponseMessage = "We are resolving this conversation. Please reach out to us in case of any more queries."
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

enum CustomInputField {
    static let nameFieldResponse = "Hey, what's your name?"
    static let emailFieldResponse = "Enter the email"
    static let phoneNumberFieldResponse = "Enter your phone number"
    static let otpFieldResponse = "Enter the OTP"
    static let finalSuccessResponse = "Hi \(CustomInputFieldReply.nameFieldResponse), your Email is \(CustomInputFieldReply.emailFieldResponse) and your Phone Number \(CustomInputFieldReply.phoneNumberFieldResponse)"
}

enum CustomInputFieldReply {
     private static let name: String = generateRandomName()
     private static let email: String = generateRandomEmail()
     private static let phoneNumber: String = generateRandomPhoneNumber()
     private static let otp: String = generateRandomOTP()

     static let nameFieldResponse: String = name
     static let emailFieldResponse: String = email
     static let phoneNumberFieldResponse: String = phoneNumber
     static let otpFieldResponse: String = otp

     private static func generateRandomName() -> String {
         let firstNames = ["John", "Emily", "Michael", "Sophia", "David"]
         let lastNames = ["Smith", "Johnson", "Brown", "Taylor", "Anderson"]
         let randomFirstName = firstNames.randomElement()!
         let randomLastName = lastNames.randomElement()!
         return "\(randomFirstName) \(randomLastName)"
     }

     private static func generateRandomEmail() -> String {
         let domains = ["example.com", "mail.com", "test.com", "demo.org", "sample.net"]
         let name = name.lowercased().replacingOccurrences(of: " ", with: ".")
         let randomDomain = domains.randomElement()!
         return "\(name)@\(randomDomain)"
     }

     private static func generateRandomPhoneNumber() -> String {
         let countryCode = "+1"
         let number = (100_000_0000...999_999_9999).randomElement()!
         return "\(number)"
     }

     private static func generateRandomOTP() -> String {
         return String((1000...9999).randomElement()!)
     }
}

enum PreChatFormText {
    static let email = "Email"
    static let name = "Name"
    static let phoneNumber = "Phone number"
    static let submit = "SUBMIT"
    static let startConversation =  "Start Conversation"
}

enum PreChatFormReply {
    private static let name: String = generateRandomName()
    private static let email: String = generateRandomEmail()
    private static let phoneNumber: String = generateRandomPhoneNumber()
    
    
    static let nameFieldResponse: String = name
    static let emailFieldResponse: String = email
    static let phoneNumberFieldResponse: String = phoneNumber
    
    
    private static func generateRandomEmail() -> String {
        let domains = ["gmail.com", "yahoo.com", "outlook.com", "icloud.com"]
        let randomString = UUID().uuidString.prefix(8)
        let randomNumber = Int.random(in: 100...999)

        return "user\(randomString)\(randomNumber)@\(domains.randomElement()!)"
    }
    
    private static func generateRandomName() -> String {
        let firstNames = ["Alice", "Bob", "Charlie", "David", "Emma"]
        let lastNames = ["Anderson", "Brown", "Clark", "Davis", "Evans"]
        
        return "\(firstNames.randomElement()!) \(lastNames.randomElement()!)"
    }
    
    private static func generateRandomPhoneNumber() -> String {
        let firstDigit = Int.random(in: 6...9)
        let remainingDigits = (1...9).map { _ in String(Int.random(in: 0...9)) }.joined()
        
        return "\(firstDigit)\(remainingDigits)"
    }
}

struct RatingFeedback {
    let rating: String
    let comment: String
}
