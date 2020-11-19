//
//  APIManager.swift
//  AppDemo
//
//  Created by John Paul Manoza on 11/19/20.
//

import Foundation
import Alamofire
import RxSwift
import ObjectMapper
import AlamofireObjectMapper
import RealmSwift

class APIManager {

    private var manager: Alamofire.SessionManager
    
    public func baseUrl() -> String {
        var url = ""
        // Add env checking here if to switch from dev to production base url
        #if RELEASE
            url = "specify production url here"
        #else
            url = "https://api.exchangeratesapi.io"
        #endif
        return url
    }
    
    init() {

        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 50
        // 10 seconds request timeout
        config.timeoutIntervalForResource = 30.0
        config.timeoutIntervalForRequest = 30.0
        // disable response caching
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil

        manager = Alamofire.SessionManager(configuration: config)
    }
    
    // NOTE: When this fnx received a response, it will automatically map the object and convert the response to Realm Object
    public func requestObject<T: Mappable>(_ urlConvertible: URLRequestConvertible, _ type: T.Type? = nil) -> Observable<Any> {
        // Create an RxSwift observable, which will be the one to call the request when subscribed to
        return Observable<Any>.create { [weak this = self] observer in
            
            guard let this = this else { return  Disposables.create() }
            
            this.manager.request(urlConvertible).responseObject(completionHandler: { (response: DataResponse<T>) in
                switch response.result {
                case .success(let value):
                    observer.onNext(value); observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            })
            
            return Disposables.create()
        }
    }
}
