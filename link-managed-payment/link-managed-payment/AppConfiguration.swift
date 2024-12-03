//
// AppConfiguration.swift
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

internal struct AppConfigContent: Codable {
    var clientID: String = ""
    var clientSecret: String = ""
    var merchantID: String = ""

    private enum CodingKeys: String, CodingKey {
        case clientID = "ClientID"
        case clientSecret = "ClientSecret"
        case merchantID = "MerchantID"
    }
}

internal class AppConfiguration {
    private static func contentOfFile(_ name: String = "AppConfig") throws -> AppConfigContent? {
        if let path = Bundle.main.url(forResource: name, withExtension: "plist"),
           let data = try? Data(contentsOf: path) {
            return try? PropertyListDecoder().decode(AppConfigContent.self, from: data)
        }
        return nil
    }
    
    static var clientID: String {
        let config = try? AppConfiguration.contentOfFile()
        return config?.clientID ?? ""
    }

    static var clientSecret: String {
        let config = try? AppConfiguration.contentOfFile()
        return config?.clientSecret ?? ""
    }

    static var merchantID: String {
        let config = try? AppConfiguration.contentOfFile()
        return config?.merchantID ?? ""
    }
}

