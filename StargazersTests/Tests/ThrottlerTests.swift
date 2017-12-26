//
//  Created by Matteo Crespi on 25/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

@testable
import Stargazers
import XCTest

class ThrottlerTests: XCTestCase {
    
    func testThrottlesCorrectly() {
        // GIVEN: a block and a time limit
        let expectation = self.expectation(description: "completion was not performed")
        var invocationCount = 0, completionsCount = 0
        let limit: TimeInterval = 0.2, block = {
            completionsCount += 1
            XCTAssertEqual(invocationCount, 3)
            XCTAssertEqual(completionsCount, 1)
            expectation.fulfill()
        }
        // WHEN: asked to perform each of them within a time interval shorter
        // that the specified one
        let subject = Throttler(limit: limit, block: block)
        subject.execute(); invocationCount += 1
        delay(by: 0.1, block: { subject.execute() ; invocationCount += 1 })
        delay(by: 0.2, block: { subject.execute() ; invocationCount += 1 })
        // THEN: Only the last one is performed after the specified interval
        // since its addition
        wait(for: [expectation], timeout: 1)
    }
    
    func testDoesThrottlesCorrectly() {
        // GIVEN: Three blocks and a time limit
        let firstExpectation  = self.expectation(description: "never performed the block")
        let secondExpectation = self.expectation(description: "only performed the block once")
        let thirdExpectation  = self.expectation(description: "only performed the block twice")
        var invocationCount = 0, completionsCount = 0
        let limit: TimeInterval = 0.1
        let block = {
            completionsCount += 1
            XCTAssertEqual(completionsCount, invocationCount)
            switch completionsCount {
            case 1: firstExpectation.fulfill()
            case 2: secondExpectation.fulfill()
            case 3: thirdExpectation.fulfill()
            default: XCTFail()
            }
        }
        // WHEN: asked to execute one after the other
        let subject = Throttler(limit: limit, block: block)
        subject.execute() ; invocationCount += 1
        delay(by: 0.15) { subject.execute() ; invocationCount += 1 }
        delay(by: 0.30) { subject.execute() ; invocationCount += 1  }
        // THEN: it does not cancel either of them
        wait(for: [firstExpectation, secondExpectation, thirdExpectation], timeout: 1)
    }
}
