//
//  ExcRouter.swift
//  CurrencyConvert
//
//  Created by John Paul Manoza on 11/8/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import Foundation
import Alamofire

enum ExcRouter: URLRequestConvertible {

    case loadExchangeRates
    
    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .loadExchangeRates:
            return .get
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .loadExchangeRates:
            return "latest"
        }
    }
    
    private var parameters: Parameters? {
        return nil
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let manager = APIManager()
        let url = try manager.baseUrl().asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))

        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        // Parameters
        if let params = parameters {
            // limited to get only
            urlRequest = try URLEncoding.queryString.encode(urlRequest, with: params)
        }
        
        return urlRequest
    }
}

