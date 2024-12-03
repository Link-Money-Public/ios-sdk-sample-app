//
// UserDataView.swift
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

struct UserDataView: View {
    @ObservedObject var context: LinkPayContext
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var amountValue: String = ""
    @State private var phoneNumber: String = ""
    @State private var generateState: String
    @State private var isMerchantMenu = false
    @State private var isGenerating: Bool = false
    
    private let generateLabel = "Generate Session Key"
    private let sessionManager: SessionManager = SessionManager()
    
    init(_ context: LinkPayContext) {
        self.context = context
        self.generateState = generateLabel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            LinkTextField(title: "First Name", text: $firstName)
            LinkTextField(title: "Last Name", text: $lastName)
            LinkTextField(title: "Email", text: $email, keyboardType: .emailAddress)
            Spacer(minLength: 10)
            Button("", action: onButtonClick)
                .buttonStyle(LinkButtonStyle(title: generateState, disabled: isGenerating, primary: false))
                .frame(maxWidth: .infinity)
        }
    }
        
    private func onButtonClick() {
        isGenerating.toggle()
        generateState = "Generating"
        sessionManager.createSession(firstName: firstName, lastName: lastName, email: email) { result in
            switch result {
            case .success(let value):
                context.sessionKey = value!.sessionKey
                isGenerating.toggle()
                generateState = generateLabel
            case .failure(let error):
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    context.info = LinkAlert(
                        id: .sessionFailure,
                        title: "Session Failed",
                        message: error.errorDescription ?? "Unable to create session"
                    )
                    isGenerating.toggle()
                    generateState = generateLabel
                })
            }
        }
    }
}
