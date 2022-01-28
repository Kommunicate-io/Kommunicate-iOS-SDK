//
//  KMConversationViewControllerTests.swift
//  Kommunicate_Tests
//
//  Created by Shivam Pokhriyal on 05/03/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

@testable import Kommunicate
import KommunicateChatUI_iOS_SDK
import Nimble
import Quick

class KMConversationViewControllerTests: QuickSpec {
    override func spec() {
        describe("KMConversationVC") {
            context("while fetching conversation details") {
                var viewController: KMConversationViewController!
                var viewModel: ALKConversationViewModel!
                var conversationDetailMock: ConversationDetailMock!
                let groupId = NSNumber(integerLiteral: 100)

                beforeEach {
                    conversationDetailMock = ConversationDetailMock()
                    viewModel = ALKConversationViewModel(contactId: nil, channelKey: groupId, localizedStringFileName: Kommunicate.defaultConfiguration.localizedStringFileName)
                    viewController = KMConversationViewController(configuration: Kommunicate.defaultConfiguration, conversationViewConfiguration: KMConversationViewConfiguration())
                    viewController.viewModel = viewModel
                    viewController.conversationDetail = conversationDetailMock
                }

                it("uses groupId from viewModel") {
                    viewController.updateAssigneeDetails()
                    expect(conversationDetailMock.groupId).to(equal(groupId))
                }

                context("if viewModel is changed") {
                    it("uses groupId from new viewModel") {
                        let newGroupId = NSNumber(integerLiteral: 101)
                        viewModel = ALKConversationViewModel(contactId: nil, channelKey: newGroupId, localizedStringFileName: Kommunicate.defaultConfiguration.localizedStringFileName)
                        viewController.viewModel = viewModel
                        viewController.updateAssigneeDetails()
                        expect(conversationDetailMock.groupId).to(equal(newGroupId))
                    }
                }
            }
        }
    }
}
