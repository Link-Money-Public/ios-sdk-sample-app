//
// ContentView.swift
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

struct ContentView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var amount: String = ""
    
    @State private var processingPayment = false
    @State private var presentAccountLinking = false
    
    @State private var sessionKey: String = ""
    @State private var accessToken: String = ""
    
    @State private var info: DemoAlert?
    
    private let networkManager:NetworkManager = NetworkManager()
    
    var body: some View {
        VStack {
            HStack {
                TextField("First Name", text: $firstName)
                    .padding([.bottom,.top, .leading], 5)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 2)
                    })
                    .keyboardType(UIKeyboardType.numberPad)
                
            }
            Divider()
            HStack {
                TextField("Last Name", text: $lastName)
                    .padding([.bottom,.top, .leading], 5)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 2)
                    })
                    .keyboardType(UIKeyboardType.default)
                
            }
            Divider()
            HStack {
                TextField("Email", text: $email)
                    .padding([.bottom,.top, .leading], 5)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 2)
                    })
                    .keyboardType(UIKeyboardType.emailAddress)
                
            }
            Divider()
            HStack {
                TextField("Amount", text: $amount)
                    .padding([.bottom,.top, .leading], 5)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 2)
                    })
                    .keyboardType(UIKeyboardType.numberPad)
                
            }
            Button("Process Payment"){
                DispatchQueue.global(qos: .userInitiated).async {
                    self.startPaymentProcess()
                }
            }.padding([.top],20).disabled(processingPayment)
            if processingPayment {
                ProgressView()
            }
        }
        .padding()
        .alert(item: $info, content: { item in
            if item.id == .paymentSuccess {
                return Alert(title: Text(item.title),
                             message: Text(item.message),
                             dismissButton: .cancel(Text("OK"))
                )
            }else {
                return Alert(title: Text(item.title),
                             message: Text(item.message),
                             dismissButton: .default(Text("OK"))
                )
            }
        })
        .fullScreenCover(isPresented: $presentAccountLinking, content: {
            LinkWebView(sessionKey: $sessionKey, isPresenting: $presentAccountLinking, onComplete: { result in
                    switch result {
                    case .success(let returnedCustomerId):
                        guard let customerId = returnedCustomerId,
                              let amountToCharge = Double(amount)
                        else {
                            self.info = DemoAlert(id: .sessionFailure,
                                         title: "Link Account Error",
                                         message: "Customer Id is empty or the amount to charge is not valid.")
                            return
                        }
                        networkManager.processPayment(
                            customerId: customerId,
                            paymentAmount: amountToCharge,
                            merchantId: AppConfiguration.merchantId,
                            accessToken: accessToken,
                            referenceId: "",
                            softDescription: ""
                        ) { result in
                            self.processingPayment = false
                            switch result {
                            case .success(let paymentModel):
                                self.info = DemoAlert(id: .paymentSuccess,
                                             title: "Payment Success",
                                             message: "Payment Id: \(paymentModel.parsed?.paymentId ?? "")"
                                )
                                break
                            case .failure(let err):
                                self.info = DemoAlert(id: .sessionFailure,
                                             title: "Payment Process Error",
                                             message: err.errorDescription ?? "Error occurred"
                                )
                            }
                        }
                        break
                    case .failure(let err):
                        // Hanlde error
                        self.processingPayment = false
                        self.info = DemoAlert(id: .sessionFailure,
                                     title: "Link Account Error",
                                     message: err.errorDescription ?? "Error occurred"
                        )
                        break
                    }
                }).equatable()
        })
    }
    
    func startPaymentProcess(){
        self.processingPayment = true
        networkManager.generateAccessToken(clientId: AppConfiguration.clientId, clientSecret: AppConfiguration.clientSecret) { result in
            switch result {
            case .success(let accessTokenModel):
                self.generateSessionKey(accessToken: accessTokenModel?.accessToken?.accesstoken ?? "")
                break
            case .failure(let err):
                // Handle error
                self.processingPayment = false
                self.info = DemoAlert(
                    id: .sessionFailure,
                    title: "Access Token Error",
                    message: err.errorDescription ?? "Error occurred"
                )
                break
            
            }
        }
    }
    
    func generateSessionKey(accessToken: String){
        networkManager.createSessionKey(firstName: firstName, lastName: lastName, email: email, accessToken: accessToken) { result in
            switch result {
            case .success(let sessionModel):
                startLinkAccountFlow(sessionKey: sessionModel?.sessionKey?.sessionKey ?? "")
                break
            case .failure(let err):
                // Handle error
                self.processingPayment = false
                self.info = DemoAlert(
                    id: .sessionFailure,
                    title: "Generate session error",
                    message: err.errorDescription ?? "Error occurred"
                )
                break
            }
        }
    }
    
    func startLinkAccountFlow(sessionKey: String){
        self.sessionKey = sessionKey
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1){
            self.presentAccountLinking.toggle()
        }
    }
    
    struct LinkWebView: View, Equatable {
        @Binding var sessionKey: String
        @Binding var isPresenting: Bool

        var onComplete: LinkAccountComplete

        static func == (lhs: LinkWebView, rhs: LinkWebView) -> Bool {
            return lhs.sessionKey == rhs.sessionKey
        }

        var body: some View {
            return WebViewWrapper(sessionKey: sessionKey,
                                  environment: AppConfiguration.environment) { result in
                self.isPresenting.toggle()
                onComplete(result)
            }
            .background(Color("BackgroundColor").ignoresSafeArea())
            .ignoresSafeArea()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
