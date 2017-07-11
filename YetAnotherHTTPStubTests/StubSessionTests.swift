//
//  StubSessionTests.swift
//  YetAnotherHTTPStub
//
//  Created by Darren Lai on 7/8/17.
//  Copyright © 2017 KinWahLai. All rights reserved.
//

import Foundation
import XCTest
@testable import YetAnotherHTTPStub


class StubSessionTests: XCTestCase {
    var session: StubSession!
    override func setUp() {
        super.setUp()
        session = StubSession()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testEachSessionHasUUID() {
        let hardcodedUUIDString = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
        let uuid = UUID(uuidString: hardcodedUUIDString)!
        let session = StubSession(uuid: uuid)
        XCTAssertEqual(hardcodedUUIDString, session.uuid.uuidString)
    }
    
    func testEmptyRequestWhenSessionStarts() {
        XCTAssertEqual(session.stubRequests.count, 0)
    }
    
    // 1 session -> n matcher
    func testEachSessionCanHaveMultipleStubRequest() {
        let google = URLRequest(url: URL(string: "https://www.google.com/")!)
        let httpbin = URLRequest(url: URL(string: "https://www.httpbin.org/")!)
        
        session.whenRequest { (urlrequest: URLRequest) -> Bool in
            return urlrequest == google
        }
        session.whenRequest { (urlrequest: URLRequest) -> Bool in
            return urlrequest == google
        }
        
        XCTAssertEqual(session.stubRequests.count, 2)
    }
    
    func testAddProtocolToDefaultConfiguration() {
        let configuration = URLSessionConfiguration.default
        session.addProtocol(to: configuration)
        let protocolClasses = (configuration.protocolClasses!).map({ "\($0)" })
        XCTAssertEqual(protocolClasses.first!, "YetAnotherURLProtocol")
    }
    
    func testAddProtocolToEphemeralConfiguration() {
        let configuration = URLSessionConfiguration.ephemeral
        session.addProtocol(to: configuration)
        let protocolClasses = (configuration.protocolClasses!).map({ "\($0)" })
        XCTAssertEqual(protocolClasses.first!, "YetAnotherURLProtocol")
    }
    
    func testRemoveProtocolToDefaultConfiguration() {
        let configuration = URLSessionConfiguration.default
        session.addProtocol(to: configuration)
        let protocolClasses = (configuration.protocolClasses!).map({ "\($0)" })
        XCTAssertEqual(protocolClasses.first!, "YetAnotherURLProtocol")
        
        session.removeProtocol(from: configuration)
        let newProtocolClasses = (configuration.protocolClasses!).map({ "\($0)" })
        XCTAssertFalse(newProtocolClasses.contains("YetAnotherURLProtocol"))
    }
    
    func testSessionCannotFindStubRequest() {
        let google = URLRequest(url: URL(string: "https://www.google.com/")!)
        let stubRequest = session.find(by: google)
        XCTAssertNil(stubRequest)
    }
    
    func testStubRequestFound() {
        var google = URLRequest(url: URL(string: "https://www.google.com/")!)
        google.httpMethod = "POST"
        let httpbin = URLRequest(url: URL(string: "https://www.httpbin.org/")!)
        
        session.whenRequest(matcher: http(.get, uri: "https://www.google.com/"))
        session.whenRequest { (urlrequest: URLRequest) -> Bool in
            return http(.get, uri: "https://www.httpbin.org/")(urlrequest)
        }
        
        let stubRequest = session.find(by: httpbin)
        XCTAssertNotNil(stubRequest)
        let anotherStubRequest = session.find(by: google)
        XCTAssertNil(anotherStubRequest)
    }
}
