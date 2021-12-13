//
//  DataLoader.swift
//  Kommunicate
//
//  Created by Mukesh on 15/01/19.
//

import Foundation

class DataLoader {

    enum LoadingError: Error {
        case network(Error?)
        case invalidParam
    }

    static func request(url: URL, completion: @escaping (Result<Data, LoadingError>) -> Void) {

        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        urlRequest.timeoutInterval = 600
        urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(KMUserDefaultHandler.getAuthToken(), forHTTPHeaderField: "X-Authorization")

        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            let result = data.map(Result.success) ??
                .failure(LoadingError.network(error))

            completion(result)
        }
        task.resume()
    }

    static func postRequest(
        url: URL,
        params: [String: Any],
        completion: @escaping (Result<Data, LoadingError>) -> Void
    ) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = 600
        urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization
            .data(withJSONObject: params, options: .prettyPrinted) else {
                completion(.failure(.invalidParam))
                return
        }
        let contentLength = String(format: "%lu", UInt(httpBody.count))
        urlRequest.setValue(contentLength, forHTTPHeaderField: "Content-Length")
        urlRequest.httpBody = httpBody

        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            let result = data.map(Result.success) ??
                .failure(LoadingError.network(error))
            completion(result)
        }
        task.resume()
    }
}
