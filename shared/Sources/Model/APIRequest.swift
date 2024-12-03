//
//  HTTPMethod.swift
//  shared
//
//  Created by James Bail on 11/29/24.
//


//
//  APIRequest.swift
//  merchant-managed-payment
//
//  Created by James Bail on 11/27/24.
//
import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

struct APIRequest {
    var url: URL
    var httpMethod: HTTPMethod
    var params: String?
    var body: [String:Any]?
    var headers: [String:String]?
    
    init(url: URL, httpMethod: HTTPMethod, params: String? = nil, headers: [String : String]? = nil) {
        self.url = url
        self.httpMethod = httpMethod
        self.params = params
        self.headers = headers
    }
    
    init(url: URL, httpMethod: HTTPMethod, body: [String : Any], headers: [String : String]? = nil) {
        self.url = url
        self.httpMethod = httpMethod
        self.body = body
        self.headers = headers
    }
}
