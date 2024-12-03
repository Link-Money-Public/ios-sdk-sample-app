//
// PaymentView.swift
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
import SampleAppShared
import LinkAccount

struct PaymentView: View {
    @ObservedObject var context: LinkPayContext
    @State private var paymentState: String
    @State private var isMakingPayment: Bool = false
    @State private var amount: String = ""
    
    private let authManager = AuthManager()
    private let paymentManager = PaymentManager()
    
    init(_ context: LinkPayContext) {
        self.context = context
        self.paymentState = "Make Payment"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            LinkTextField(title: "Customer ID", text: $context.customerID, isDisabled: true)
            LinkTextField(title: "Amount",
                          place: "$",
                          text: $amount,
                          keyboardType: .decimalPad)
            Button("", action: onButtonClick)
                .buttonStyle(LinkButtonStyle(title: paymentState, disabled: context.customerID.isEmpty || isMakingPayment, primary: false))
                .frame(maxWidth: .infinity)
        }
        .padding(.top, 20)
    }
    
    private func onButtonClick() {
        isMakingPayment.toggle()
        authManager.getAccessToken { result in
            switch result {
            case .success(let accessToken):
                paymentManager.processPayment(
                    accessToken: accessToken.accessToken,
                    customerID: context.customerID,
                    paymentAmount: Double(amount)!,
                    completionHandler: handlePaymentResult)
                break
            case .failure(let err):
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    context.info = LinkAlert(
                        id: .paymentFailure,
                        title: "Access Token Error",
                        message: err.errorDescription ?? "Error occurred retrieving access token"
                    )
                    isMakingPayment.toggle()
                })
                break
            }
        }
    }
    
    @Sendable
    private func handlePaymentResult(result: Result<Payment, SessionError>) {
        switch result {
        case .success(let value):
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                context.info = LinkAlert(id: .paymentSuccess, title: "Payment \(value.paymentStatus)", message: "Payment ID: \(value.paymentId)")
                paymentState = "Make Payment"
                isMakingPayment.toggle()
            })
            break
        case .failure(let error):
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                context.info = LinkAlert(id: .paymentFailure, title: "Payment Failed", message: error.errorDescription ?? "Failed to make payment")
                paymentState = "Make Payment"
                isMakingPayment.toggle()
            })
            break
        }
    }
}
