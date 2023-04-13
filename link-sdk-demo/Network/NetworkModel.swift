//
// SessionModel.swift
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

struct AccessTokenModel: Codable {
    let accessToken: TokenModel?
}

struct TokenModel: Codable {
    var accesstoken: String
    var expiresIn: Int64
    var scope: String
    var tokenType: String

    private enum CodingKeys: String, CodingKey {
        case accesstoken        = "access_token"
        case expiresIn          = "expires_in"
        case scope              = "scope"
        case tokenType          = "token_type"
    }
}

// Session Model
struct SessionModel: Codable {
    let sessionKey: SessionDataModel?
}

struct SessionDataModel: Codable {
    let sessionKey: String?
}

struct PaymentModel: Codable {
    let parsed: Payment?
}

struct Payment: Codable {
    let paymentId: String
    let paymentStatus: String
    let clientReferenceId: String
}
