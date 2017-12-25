//
//  Created by Matteo Crespi on 25/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

@testable
import Stargazers
import XCTest

class LimiterTests: XCTestCase {
    
    func testLimitsCorrectly() {
        // GIVEN: three blocks
        let firstExpectation  = self.expectation(description: "first block content was not performed")
        let secondExpectation = self.expectation(description: "second block content was not performed")
        let thirdExpectation  = self.expectation(description: "third block content was not performed")
        let first: (DispatchWorkItem) -> Void = { item in
            self.delay(by: 0.2) { XCTAssertTrue(item.isCancelled) ; firstExpectation.fulfill() }
        }
        let second: (DispatchWorkItem) -> Void = { item in
            self.delay(by: 0.2) { XCTAssertTrue(item.isCancelled) ; secondExpectation.fulfill() }
        }
        let third: (DispatchWorkItem) -> Void = { item in
            self.delay(by: 0.2) { XCTAssertFalse(item.isCancelled) ; thirdExpectation.fulfill() }
        }
        // WHEN: asked to perform each one of them before the previous one completes
        let subject = Limiter()
        subject.execute(first)
        delay(by: 0.1) { subject.execute(second) }
        delay(by: 0.2) { subject.execute(third) }
        // THEN: it cancels first two and only the third one is completed
        wait(for: [firstExpectation, secondExpectation, thirdExpectation], timeout: 2)
    }
    
    func testDoesNotLimitCorrectly() {
        // GIVEN: Two blocks
        let firstExpectation  = self.expectation(description: "first block content was not performed")
        let secondExpectation = self.expectation(description: "second block content was not performed")
        let first: (DispatchWorkItem) -> Void = { item in
            self.delay(by: 0.05) { XCTAssertFalse(item.isCancelled) ; firstExpectation.fulfill() }
        }
        let second: (DispatchWorkItem) -> Void = { item in
            self.delay(by: 0.05) { XCTAssertFalse(item.isCancelled) ; secondExpectation.fulfill() }
        }
        // WHEN: asked to execute one after the other
        let subject = Limiter()
        subject.execute(first)
        delay(by: 0.1) { subject.execute(second) }
        // THEN: it does not cancel either of them
        wait(for: [firstExpectation, secondExpectation], timeout: 1)
    }
}
