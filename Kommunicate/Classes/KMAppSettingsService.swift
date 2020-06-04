//
//  KMAppSettingsService.swift
//  Kommunicate
//
//  Created by apple on 13/04/20.
//

import Foundation

class KMAppSettingService {
    
    func appSetting(
        applicationKey: String = KMUserDefaultHandler.getApplicationKey(),
        completion: @escaping (Result<AppSetting, KMAppSettingsError>)->()) {
        guard let url = URLBuilder.appSettings(for: applicationKey).url else {
            completion(.failure(.api(.urlBuilding)))
            return
        }
        DataLoader.request(url: url, completion: {
            result in
            switch result {
            case .success(let data):
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
            case .failure(let error):
                completion(.failure(.api(.network(error))))
            }
        })
    }

}
