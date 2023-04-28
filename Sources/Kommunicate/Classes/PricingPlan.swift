//
//  PricingPlan.swift
//  Kommunicate
//
//  Created by Mukesh on 27/12/18.
//

import Foundation
import KommunicateCore_iOS_SDK

struct PricingPlan {
    static let shared = PricingPlan()

    // Dependencies
    let utility: ALUtilityClass.Type
    let userDefaultsHandler: ALUserDefaultsHandler.Type

    // Constants
    let startupPlan = 101
    let startMonthlyPlan = 112
    let startYearlyPlan = 113
    init(
        utility: ALUtilityClass.Type = ALUtilityClass.self,
        userDefaultsHandler: ALUserDefaultsHandler.Type = ALUserDefaultsHandler.self
    ) {
        self.utility = utility
        self.userDefaultsHandler = userDefaultsHandler
    }

    func showSuspensionScreen() -> Bool {
        let isReleaseBuild = !utility.isThisDebugBuild()
        let isFreePlan = userDefaultsHandler.getUserPricingPackage() == startupPlan
        let isStartPlan = (userDefaultsHandler.getUserPricingPackage() == startMonthlyPlan || userDefaultsHandler.getUserPricingPackage() == startYearlyPlan)
        let isNotAgent = userDefaultsHandler.getUserRoleType() != Int16(AL_APPLICATION_WEB_ADMIN.rawValue)
        guard isReleaseBuild, isNotAgent, (isFreePlan || isStartPlan) else { return false }
        return true
    }
}
