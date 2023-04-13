//
// WebViewWrapper.swift
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

import SwiftUI
import LinkAccount

struct WebViewWrapper: UIViewControllerRepresentable {
    let sessionKey: String
    let environment: LinkEnvironment
    let complete: LinkAccountComplete!
    typealias UIViewControllerType = LinkAccountController

    init(sessionKey: String, environment: LinkEnvironment, complete: @escaping LinkAccountComplete ) {
        self.sessionKey = sessionKey
        self.environment = environment
        self.complete = complete
    }

    // Intialise the controller
    func makeUIViewController(context: Context) -> LinkAccountController {
        let controller = LinkAccountController(sessionKey: sessionKey, host: environment)
        return controller
    }

    // Show the Webview once controller view is updated
    func updateUIViewController(_ uiViewController: LinkAccountController, context: Context) {
        uiViewController.display { result in
            switch result {
            case .success(let value): self.complete(.success(value))
            case .failure(let error): self.complete(.failure(error))
            }
        }
    }
}

