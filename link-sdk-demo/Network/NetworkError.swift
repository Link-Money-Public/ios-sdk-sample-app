//
// SessionError.swift
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

protocol NetworkErrorProtocol: LocalizedError {
    var code: String { get }
    var message: String { get }
}

struct NetworkError: NetworkErrorProtocol {
    var code: String
    var message: String
    var errorDescription: String { return _description }

    private var _description: String

    init(
        code: String = "",
        errorMessage: String = "There was an error linking the customer account"
    ) {
        self.code = code
        self.message = errorMessage
        self._description = errorMessage
        if !code.isEmpty {
            self._description = "Status Code:\(code), \(errorMessage)"
        }
    }
}
