//
//  Created by Matteo Crespi on 25/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

@testable
import Stargazers
import XCTest

class WebserviceTests: XCTestCase {
    
    func testReportsValues() {
        // GIVEN: a valid request with a valid response
        let expectation = self.expectation(description: "no response received")
        let url: URL = "https://api.github.com/Subito-it"
        let response: (Data?, Swift.Error?) = (Data(forResource: "User", withExtension: "json"), nil)
        let session = URLSessionFake(responses: [url: response])
        let request = Webservice.Request<User>(url: url)
        // WHEN: its asked to perfom it
        let subject = Webservice(session: session)
        subject.load(request) { response in
            // THEN: completes signaling a success with the appropriate value
            switch response {
            case .failure:
                XCTFail()
            case .success(let user):
                XCTAssertEqual(user.login, "Subito-it")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testReportsDecodingErrors() {
        // GIVEN: a valid request with an unexpected response type
        let expectation = self.expectation(description: "no response received")
        let url: URL = "https://api.github.com/Subito-it"
        let response: (Data?, Swift.Error?) = (Data(forResource: "User", withExtension: "json"), nil)
        let session = URLSessionFake(responses: [url: response])
        let request = Webservice.Request<Repository>(url: url)
        // WHEN: its asked to perfom it
        let subject = Webservice(session: session)
        subject.load(request) { response in
            // THEN: completes signaling a networking error
            switch response {
            case .failure(let error):
                XCTAssertEqual(error, Error.networking)
            case .success:
                XCTFail()
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testReportsNoInternetErrors() {
        // GIVEN: a valid request with an unexpected response type
        let expectation = self.expectation(description: "no response received")
        let url: URL = "https://api.github.com/Subito-it"
        let response: (Data?, Swift.Error?) = (nil, NSError(domain: URLError.errorDomain, code: URLError.notConnectedToInternet.rawValue, userInfo: nil))
        let session = URLSessionFake(responses: [url: response])
        let request = Webservice.Request<Repository>(url: url)
        // WHEN: its asked to perfom it
        let subject = Webservice(session: session)
        subject.load(request) { response in
            // THEN: completes signaling a networking error
            switch response {
            case .failure(let error):
                XCTAssertEqual(error, Error.noInternet)
            case .success:
                XCTFail()
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testReportsOnCallbackQueue() {
        // GIVEN: a request
        let expectation = self.expectation(description: "no response received")
        let url: URL = "https://api.github.com/Subito-it"
        let response: (Data?, Swift.Error?) = (nil, nil)
        let session = URLSessionFake(responses: [url: response])
        let request = Webservice.Request<User>(url: url)
        // WHEN: its asked to perfom it and dispatch the response on a specific queue
        let subject = Webservice(session: session, callbackQueue: .main)
        subject.load(request) { response in
            // THEN: the response callback is invoked on the apppropriate queue
            XCTAssertEqual(OperationQueue.current, OperationQueue.main)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
    }
}
