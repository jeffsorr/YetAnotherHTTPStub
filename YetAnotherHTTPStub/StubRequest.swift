//
//  YetAnotherStubRequest.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/8/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation

public typealias Matcher = (URLRequest) -> (Bool)

public class StubRequest {
    internal let matcher: Matcher
    internal var responses: [StubResponse]
    
    public init(_ matcher: @escaping Matcher) {
        self.matcher = matcher
        self.responses = []
    }
    
    @discardableResult
    public func thenResponse(responseBuilder: @escaping Builder) -> Self {
        let stubResponse = StubResponse(responseBuilder)
        self.responses.append(stubResponse)
        return self
    }
    
    public func popResponse(for request: URLRequest) -> StubResponse? {
        if matcher(request) {
            return responses.removeFirst()
        } else {
            return nil
        }
    }
}

// func ==(lhs:StubRequest, rhs:StubRequest) -> Bool {