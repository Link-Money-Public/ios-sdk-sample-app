//
// SessionManager.swift
//
// Copyright (c) 2023-2024 Link Financial Technologies, Inc.
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
import SampleAppShared

class SessionManager: APIClient {
    private let baseURL: String = "https://api.link-sandbox.money/session"
    internal let session: URLSession
    
    init() {
        self.session = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    func createSession(
        firstName: String,
        lastName: String,
        email: String,
        completionHandler: @escaping @Sendable (Result<Session?, SessionError>) -> Void
    ) {
        var sessionJSON: [String: Any] = [:]
        var headers: [String: String] = [:]
        let auth: String = "\(AppConfiguration.clientID):\(AppConfiguration.clientSecret)".data(using: .utf8)?.base64EncodedString() ?? ""
        sessionJSON["firstName"] = firstName
        sessionJSON["lastName"] = lastName
        sessionJSON["email"] = email
        sessionJSON["experienceId"] = "ONBOARD_WITH_DONE"
        sessionJSON["customerProfile"] = ["guestCheckout":true]
        headers["Authorization"] = "Basic \(auth)"
        let apiRequest = APIRequest(url: URL(string: baseURL + "/v2/sessions")!, httpMethod: .post, body: sessionJSON, headers: headers)
        self.request(apiRequest, completionHandler: completionHandler)
    }
}
