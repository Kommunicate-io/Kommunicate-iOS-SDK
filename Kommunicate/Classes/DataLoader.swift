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
    }

    static func request(url: URL, completion: @escaping (Result<Data>) -> Void) {

        let urlRequest = URLRequest(url: url)

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
