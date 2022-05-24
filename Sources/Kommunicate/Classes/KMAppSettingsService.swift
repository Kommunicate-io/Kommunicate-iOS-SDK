//
//  KMAppSettingsService.swift
//  Kommunicate
//
//  Created by apple on 13/04/20.
//

import Foundation
import KommunicateChatUI_iOS_SDK
import UIKit

class KMAppSettingService {
    let appSettingsUserDefaults = ALKAppSettingsUserDefaults()

    func appSetting(
        applicationKey: String = KMUserDefaultHandler.getApplicationKey(),
        completion: @escaping (Result<AppSetting, KMAppSettingsError>) -> Void
    ) {
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

    func updateAppsettings(chatWidgetResponse: ChatWidgetResponse?) {
        guard let chatWidget = chatWidgetResponse else {
                   return
               }

       KMAppUserDefaultHandler.shared.botMessageDelayInterval = chatWidget.botMessageDelayInterval ?? 0
       
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
       appSettings.hidePostCTAEnabled = chatWidget.hidePostCTAEnabled ?? false
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
