//
//  YetAnotherURLProtocol.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/7/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

public class YetAnotherURLProtocol: URLProtocol {
    public class func stubHTTP(_ configuration: URLSessionConfiguration? = nil, _ sessionBlock: (StubSession)->()) {
        let session = StubSessionManager.sharedSession()
        session.addProtocol(to: configuration)
        // Here we may want to register to XCTestObservation so we can reset the session
        sessionBlock(session)
    }
}

extension YetAnotherURLProtocol {
    public override class func canInit(with request:URLRequest) -> Bool {
        return (StubSessionManager.sharedSession().isProtocolRegistered && StubSessionManager.sharedSession().hasRequest)
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    public override func startLoading() {
        guard let stubRequest = StubSessionManager.sharedSession().find(by: request) else { return }
        guard let stubResponse = stubRequest.popResponse(for: request) else { return }
        if case .success(let urlResponse, let content) = stubResponse.builder(request) {
            client?.urlProtocol(self, didReceive: urlResponse, cacheStoragePolicy: .notAllowed)
            if case .data(let data) = content {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        if case .failure(let error) = stubResponse.builder(request) {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    public override func stopLoading() {
        print("stopLoading")
    }
}
