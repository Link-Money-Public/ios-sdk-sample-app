//
// SessionManager.swift
//
// Copyright (c) 2023 Link Financial Technologies, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

// MARK: - SessionManager
class NetworkManager {
    // URLSession
    private var session: URLSession?

    // Initialisation
    init(){
        // Creating the URLSession onbject
        self.session = URLSession(configuration: URLSessionConfiguration.default)
    }

    // creating URLRequest
    private func create(method: HTTPMethod, params: [String: Any], url: URL, headers: HTTPHeaders) -> URLRequest? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        var request = components?.url.map({ URLRequest(url: $0) })
        request?.httpMethod = method.rawValue

        for header in headers {
            request?.addValue(header.value, forHTTPHeaderField: header.key)
        }

        request?.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if method == .get {
            return request
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            request?.httpBody = jsonData
        } catch { }
        request?.cachePolicy = .reloadIgnoringCacheData
        return request
    }

    // Creating Session URL Request and Perform API Call
    func request<T: Codable> (_ request: Requestable, completionHandler: @escaping (Result<T, NetworkError>) -> Void) {
        let request = self.create(method: request.httpMethod,
                                        params: request.parameters,
                                        url: request.path, headers: request.headers!)!

        self.execute(request: request, completionHandler: { (data, response, error) in
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

    // Performing data task for given URL Request
    func execute(request: URLRequest, completionHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        self.session?.dataTask(with: request, completionHandler: { (data, response, error) in
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
}

// MARK: - API
extension NetworkManager {

    func generateAccessToken(
        clientId: String,
        clientSecret: String,
        completionHandler: @escaping (Result<AccessTokenModel?, NetworkError>) -> Void
    ) {
        var accessJson: [String: Any] = [:]
        accessJson["clientId"] = clientId
        accessJson["clientSecret"] = clientSecret
            
        let request = APIService.getAccessToken(params: accessJson)
        print(request)
        self.request(request, completionHandler: completionHandler)
    }

    // Creating the Link Session for User
    func createSessionKey(
        firstName: String,
        lastName: String,
        email: String,
        accessToken: String,
        completionHandler: @escaping (Result<SessionModel?, NetworkError>) -> Void
    ) {
        var sessionJson: [String: Any] = [:]
        sessionJson["first"] = firstName
        sessionJson["last"] = lastName
        sessionJson["email"] = email
        sessionJson["access_token"] = accessToken
        let request = APIService.getSessionKey(params: sessionJson)
        self.request(request, completionHandler: completionHandler)
    }

    func processPayment(
        customerId: String,
        paymentAmount: Double,
        merchantId: String,
        accessToken: String,
        referenceId: String,
        softDescription: String,
        completionHandler: @escaping (Result<PaymentModel, NetworkError>) -> Void
    ) {
        var paymentJson: [String: Any] = [:]
        paymentJson["clientReferenceId"] = referenceId
        paymentJson["softDescriptor"] = softDescription//"Order id: \(UUID().uuidString.lowercased())"

        // Amount
        var amountJSON: [String: Any] = [:]
        amountJSON["currency"] = "USD"
        amountJSON["value"] = paymentAmount
        paymentJson["amount"] = amountJSON

        // Source
        var sourceJSON: [String: Any] = [:]
        sourceJSON["id"] = customerId
        sourceJSON["type"] = "CUSTOMER"
        paymentJson["source"] = sourceJSON

        // Destination
        var destinationJSON: [String: Any] = [:]
        destinationJSON["type"] = "MERCHANT"
        destinationJSON["id"] = merchantId
        paymentJson["destination"] = destinationJSON

        // Access Token
        paymentJson["accessToken"] = accessToken
        
        let request = APIService.makePayment(params: paymentJson)
        self.request(request, completionHandler: completionHandler)
    }
}
