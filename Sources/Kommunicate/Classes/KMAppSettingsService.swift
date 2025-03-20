//
//  KMAppSettingsService.swift
//  Kommunicate
//
//  Created by apple on 13/04/20.
//

import Foundation
import KommunicateChatUI_iOS_SDK
import KommunicateCore_iOS_SDK
import UIKit

class KMAppSettingService {
    let appSettingsUserDefaults = ALKAppSettingsUserDefaults()
    let appSettingCacheMemoryKey = "KM_APP_SETTING_CACHE_MEMORY"
    let cacheTimeInterval: TimeInterval = 5 * 60 // 5 minutes in seconds
    
    /*
     By default, this method utilizes in-memory caching with a 5-minute retention period. When the `forceRefresh` parameter is set to `true`, the system will bypass the existing cache and retrieve the most current data directly from the appSetting Api.
     
     Key Behaviors:
     - Default Behavior: Cache data for 5 minutes
     - Forced Refresh: Retrieve real-time data by setting `forceRefresh = true`
     - App Launch Behavior: Upon app launch, real-time data is fetched as the cache is cleared during app closure or termination.
     */
    func appSetting(
        applicationKey: String = KMUserDefaultHandler.getApplicationKey(),
        forceRefresh: Bool = false,
        completion: @escaping (Result<AppSetting, KMAppSettingsError>) -> Void
    ) {
        
        if let cacheAppSettingData = Kommunicate.appSettingCache.getItem(forKey: appSettingCacheMemoryKey), !forceRefresh {
            completion(.success(cacheAppSettingData))
            return
        }

        guard let url = URLBuilder.appSettings(for: applicationKey).url else {
            completion(.failure(.api(.urlBuilding)))
            return
        }
        DataLoader.request(url: url, completion: {
            result in
            switch result {
            case let .success(data):
                guard let appSettingResponse = try? KMAppSettingsResponse(data: data) else {
                    completion(.failure(.api(.jsonConversion)))
                    return
                }
                do {
                    let appSetting = try appSettingResponse.appSettings()
                    Kommunicate.appSettingCache.setItem(forKey: self.appSettingCacheMemoryKey, value: appSetting, expiry: self.cacheTimeInterval)
                    completion(.success(appSetting))
                } catch let error as KMAppSettingsError {
                    completion(.failure(error))
                } catch {
                    completion(.failure(.notFound))
                }
            case let .failure(error):
                completion(.failure(.api(.network(error))))
            }
        })
    }
    
    func updateAppsettings(appSettingsResponse: AppSetting?) {
        guard let appSettings = appSettingsResponse else {
            return
        }
        KMAppUserDefaultHandler.shared.currentActivatedPlan = appSettings.currentActivatedPlan ?? "trial"
    }

    func updateChatWidgetAppsettings(chatWidgetResponse: ChatWidgetResponse?) {
        guard let chatWidget = chatWidgetResponse else {
                   return
               }

       KMAppUserDefaultHandler.shared.botMessageDelayInterval = chatWidget.botMessageDelayInterval ?? 0
       KMAppUserDefaultHandler.shared.botTypingIndicatorInterval = chatWidget.botTypingIndicatorInterval ?? 0
       KMAppUserDefaultHandler.shared.csatRatingBase = chatWidget.csatRatingBase ?? 3
       
       guard let primaryColor = chatWidget.primaryColor else {
           setupDefaultSettings()
           return
       }
        
        let decodedPrimaryColor = primaryColor.replacingOccurrences(of: "#", with: "")
        let appSettings = ALKAppSettings(primaryColor: decodedPrimaryColor)

       /// Primary color for sent message background
       appSettings.sentMessageBackgroundColor = decodedPrimaryColor

       /// Primary color for attachment tint color
       appSettings.attachmentIconsTintColor = decodedPrimaryColor

       if let secondaryColor = chatWidget.secondaryColor, !secondaryColor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
           appSettings.secondaryColor = secondaryColor.replacingOccurrences(of: "#", with: "")
       }
       appSettings.buttonPrimaryColor = primaryColor
       appSettings.showPoweredBy = chatWidget.showPoweredBy ?? false
       appSettings.hidePostCTAEnabled = chatWidget.hidePostCTA ?? false
       appSettings.defaultUploadOverrideUrl = chatWidget.defaultUploadOverride?.url ?? ""
       appSettings.defaultUploadOverrideHeaders = chatWidget.defaultUploadOverride?.headers ?? [:]
       appSettings.csatRatingBase = chatWidget.csatRatingBase ?? 3
       appSettings.botTypingIndicatorInterval = chatWidget.botTypingIndicatorInterval ?? 0
       appSettingsUserDefaults.updateOrSetAppSettings(appSettings: appSettings)
    }

    func clearAppSettingsData() {
        /// Clearing the app settings data
        appSettingsUserDefaults.clear()

        /// Clearing the app navigationBar color
        let navigationBarProxy = UINavigationBar.appearance(whenContainedInInstancesOf: [ALKBaseNavigationViewController.self])
        navigationBarProxy.barTintColor = nil
    }

    private func setupDefaultSettings(primaryColor: String = UIColor.background(.primary).toHexString()) {
        let appSettings = ALKAppSettings(primaryColor: primaryColor)
        appSettings.sentMessageBackgroundColor = primaryColor
        appSettings.attachmentIconsTintColor = primaryColor
        appSettings.buttonPrimaryColor = primaryColor
        appSettingsUserDefaults.updateOrSetAppSettings(appSettings: appSettings)
    }
}
