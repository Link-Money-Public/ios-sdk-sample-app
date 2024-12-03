//
// PaymentManager.swift
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
import SampleAppShared

class PaymentManager: APIClient {
    private let baseURL = "https://api.link-sandbox.money"
    public let session: URLSession
    
    private let authManager = AuthManager()
    
    init() {
        session = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    func processPayment(
        accessToken: String,
        customerID: String,
        paymentAmount: Double,
        clientReferenceID: String = "",
        softDescription: String = "",
        completionHandler: @escaping @Sendable (Result<Payment, SessionError>) -> Void
    ) {
        let apiRequest = buildPaymentRequest(
            accessToken: accessToken,
            customerID: customerID,
            amount: paymentAmount,
            clientReferenceID: clientReferenceID,
            softDescriptor: softDescription
        )
        self.request(apiRequest, completionHandler: completionHandler)
    }
    
    private func buildPaymentRequest(
        accessToken: String,
        customerID: String,
        amount: Double,
        clientReferenceID: String,
        softDescriptor: String
    ) -> APIRequest {
        var paymentJSON: [String: Any] = [:]
        paymentJSON["clientReferenceId"] = clientReferenceID
        paymentJSON["softDescriptor"] = softDescriptor
        paymentJSON["requestKey"] = UUID().uuidString.lowercased()
        
        // Amount
        var amountJSON: [String: Any] = [:]
        amountJSON["currency"] = "USD"
        amountJSON["value"] = amount
        paymentJSON["amount"] = amountJSON

        // Source
        var sourceJSON: [String: Any] = [:]
        sourceJSON["id"] = customerID
        sourceJSON["type"] = "CUSTOMER"
        paymentJSON["source"] = sourceJSON

        // Destination
        var destinationJSON: [String: Any] = [:]
        destinationJSON["type"] = "MERCHANT"
        destinationJSON["id"] = AppConfiguration.merchantID
        paymentJSON["destination"] = destinationJSON

        var headers: [String:String] = [:]
        headers["Authorization"] = "Bearer \(accessToken)"
        
        return APIRequest(url: URL(string: baseURL + "/v1/payments")!, httpMethod: .post, body: paymentJSON, headers: headers)
    }
}
