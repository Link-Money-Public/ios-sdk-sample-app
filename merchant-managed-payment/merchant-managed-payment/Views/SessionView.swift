//
// SessionView.swift
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
import SwiftUI
import LinkAccount
import SampleAppShared

struct SessionView: View {
    @ObservedObject var context: LinkPayContext
    @State private var isPresenting = false
    
    private let clientService = ClientService()
    
    init(_ context: LinkPayContext) {
        self.context = context
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            LinkTextField(title: "Session Key", text: $context.sessionKey, isDisabled: true)
        }
        .padding(.top, 20)
        Button("") {
            isPresenting = true
        }
        .buttonStyle(LinkButtonStyle(title: "Link Account", disabled: context.sessionKey.isEmpty, primary: false))
            .frame(maxWidth: .infinity)
        .alert(item: $context.info) { item in
            return Alert(title: Text(item.title),
                         message: Text(item.message),
                         dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $isPresenting, content: {
            LinkWebView(
                sessionKey: context.sessionKey,
                isPresenting: $isPresenting,
                onComplete: { result in
                    switch result {
                    case .success(let value):
                        if let customerID = value?.customerID {
                            context.customerID = customerID
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                context.info = LinkAlert(
                                    id: .sessionFailure,
                                    title: "Error",
                                    message: "Linking error occurred"
                                )
                            })
                        }
                    case .failure(let error):
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            context.info = LinkAlert(
                                id: .sessionFailure,
                                title: "Error",
                                message: error.errorDescription ?? "Linking error occurred"
                            )
                        })
                    }
                }
            ).equatable()
        })
    }
}
