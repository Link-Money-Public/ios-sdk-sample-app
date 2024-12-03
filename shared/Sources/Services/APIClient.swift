//
//  APIClient.swift
//  merchant-managed-payment
//
//  Created by James Bail on 11/27/24.
//
import Foundation

protocol APIClient {
    var session: URLSession { get }
    func request<T: Codable>(_ apiRequest: APIRequest, completionHandler: @escaping (Result<T, NetworkError>) -> Void)
}

extension APIClient {
    private func createRequest(_ apiRequest: APIRequest) -> URLRequest? {
        let components = URLComponents(url: apiRequest.url, resolvingAgainstBaseURL: false)
        
        var request = components?.url.map({ URLRequest(url: $0) })
        request?.httpMethod = apiRequest.httpMethod.rawValue
        
        for header in apiRequest.headers ?? [:] {
            request?.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        if apiRequest.httpMethod == .get {
            return request
        }
        
        if let params = apiRequest.params {
            request?.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request?.httpBody = params.data(using: .utf8)
        } else if let body = apiRequest.body {
            request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                request?.httpBody = jsonData
            } catch {}
        }
        
        request?.cachePolicy = .reloadIgnoringCacheData
        return request
    }
    
    func request<T: Codable> (_ apiRequest: APIRequest, completionHandler: @escaping (Result<T, NetworkError>) -> Void) {
        let request = self.createRequest(apiRequest)!

        self.execute(request, completionHandler: { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completionHandler(.failure(NetworkError(errorMessage: error.localizedDescription)))
                }
            } else if let response = response {
                if response.statusCode > 399 {
                    let error = self.parseError(response, data: data)
                    DispatchQueue.main.async {
                        completionHandler(.failure(error))
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(NetworkError()))
                    }
                    return
                }

                let decoder = JSONDecoder.init()
                do {
                    let values  = try decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completionHandler(.success(values))
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        completionHandler(.failure(NetworkError(errorMessage: error.localizedDescription)))
                    }
                }
            }
        })
    }
    
    private func parseError(_ response: HTTPURLResponse, data: Data?) -> NetworkError {
        if let data = data {
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments)

                if let dict = jsonData as? [String: Any], let errorMessage = dict["error"] as? String {
                    return NetworkError(code: "\(response.statusCode)", errorMessage: errorMessage)
                }
                return NetworkError(code: "\(response.statusCode)")
            } catch let error {
                return NetworkError(code: "\(response.statusCode)", errorMessage: error.localizedDescription)
            }
        }
        return NetworkError(code: "\(response.statusCode)")
    }
    
    // Performing data task for given URL Request
    func execute(_ request: URLRequest, completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        self.session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                completionHandler(nil, nil, error)
                return
            }

            guard let response = response, let data = data else {
                completionHandler(nil, nil, error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(data, nil, error)
                return
            }

            completionHandler(data, httpResponse, error)
        }).resume()
    }
}
