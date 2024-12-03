//
// APIClient.swift
//
// Copyright (c) 2024 Link Financial Technologies, Inc.
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

typealias ResponseHandler = @Sendable (Data?, HTTPURLResponse?, Error?) -> Void

public protocol APIClient {
    var session: URLSession { get }
    func request<T: Codable>(_ apiRequest: APIRequest, completionHandler: @escaping @Sendable (Result<T, SessionError>) -> Void)
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
    
    public func request<T: Codable> (_ apiRequest: APIRequest, completionHandler: @escaping @Sendable (Result<T, SessionError>) -> Void) {
        let request = self.createRequest(apiRequest)!

        self.execute(request, completionHandler: { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completionHandler(.failure(SessionError(errorMessage: error.localizedDescription)))
                }
            } else if let response = response {
                if response.statusCode > 399 {
                    let error = SessionError.parseError(response, data: data)
                    DispatchQueue.main.async {
                        completionHandler(.failure(error))
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(SessionError()))
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
                        completionHandler(.failure(SessionError(errorMessage: error.localizedDescription)))
                    }
                }
            }
        })
    }
    
    // Performing data task for given URL Request
    private func execute(_ request: URLRequest, completionHandler: @escaping ResponseHandler) {
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
