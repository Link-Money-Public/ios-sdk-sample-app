//
// SessionConstant.swift
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

typealias HTTPHeaders = [String: String]

enum HTTPMethod: String {
    case get   = "GET"
    case post  = "POST"
}

enum APIService {
    case getAccessToken(params: [String: Any])
    case getSessionKey(params: [String: Any])
    case makePayment(params: [String: Any])
}

enum APIEndpoint {
    static let baseURL = "\(AppConfiguration.baseURL)"
    static let accessToken = "\(AppConfiguration.accessTokenPath)"
    static let sessionKey = "\(AppConfiguration.sessionKeyPath)"
    static let makePayment = "\(AppConfiguration.paymentPath)"
}

protocol Requestable {
  var baseURL: String { get }
  var path: URL { get }
  var httpMethod: HTTPMethod { get }
  var parameters: [String: Any] { get }
  var headers: HTTPHeaders? { get }
}

extension APIService: Requestable {
    var baseURL: String {
        return APIEndpoint.baseURL
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getAccessToken, .getSessionKey, .makePayment:
            return .post
        }
    }

    var headers: HTTPHeaders? {
        switch self {
        default:
            return ["Content-Type": "application/json"]
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .getAccessToken(let params):
            return params
        case .getSessionKey(let params):
            return params
        case .makePayment(let params):
            return params
        }
    }

    var path: URL {
        let path: String?
        switch self {
        case .getSessionKey:
            path =  APIEndpoint.sessionKey
        case .getAccessToken:
            path = APIEndpoint.accessToken
        case .makePayment:
            path = APIEndpoint.makePayment
        }
        return URL(string: baseURL + path!)!
    }
}
