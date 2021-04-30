//
//  PricingPlan.swift
//  Kommunicate
//
//  Created by Mukesh on 27/12/18.
//

import Foundation
import ApplozicCore

struct PricingPlan {

    static let shared = PricingPlan()

    // Dependencies
    let utility: ALUtilityClass.Type
    let userDefaultsHandler: ALUserDefaultsHandler.Type

    // Constants
    let startupPlan = 101

    init(
        utility: ALUtilityClass.Type = ALUtilityClass.self,
        userDefaultsHandler: ALUserDefaultsHandler.Type = ALUserDefaultsHandler.self) {
        self.utility = utility
        self.userDefaultsHandler = userDefaultsHandler
    }

    func showSuspensionScreen() -> Bool {
        let isReleaseBuild = !utility.isThisDebugBuild()
        let isFreePlan = userDefaultsHandler.getUserPricingPackage() == startupPlan
        let isNotAgent = userDefaultsHandler.getUserRoleType() != Int16(AL_APPLICATION_WEB_ADMIN.rawValue)
        guard isReleaseBuild && isNotAgent && isFreePlan else { return false }
        return true
    }
}
