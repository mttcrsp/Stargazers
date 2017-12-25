//
//  PaginatorTests.swift
//  StargazersTests
//
//  Created by Matteo Crespi on 25/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

@testable
import Stargazers
import XCTest

class PaginatorTests: XCTestCase {
    
    class LoaderFake {
        
        let values: [Int]
        
        init(values: [Int]) { self.values = values }
        
        func load(page: Int, size: Int, completion: @escaping (Result<[Int], Stargazers.Error>) -> Void) {
            let proposedStartIndex = (page - 1) * size
            let proposedEndIndex = page * size
            let startIndex = proposedStartIndex >= 0 ? proposedStartIndex : 0
            let endIndex = proposedEndIndex < values.count ? proposedEndIndex : values.count
            let result = Array(values[startIndex ..< endIndex])
            DispatchQueue.global().async { completion(.success(result)) }
        }
    }
    
    func testRequestsNextPage() {
        // GIVEN: a data source with 5 values and a page size of 2
        let expection = self.expectation(description: "did not complete all requests")
        let loader = LoaderFake(values: Array(1...5))
        let size = 2
        // WHEN: asked to load twice sequentially
        let subject = Paginator(size: size) { page, size, completion in
            loader.load(page: page, size: size, completion: completion)
        }
        subject.loadMore { error in XCTAssertNil(error)
            XCTAssertEqual(subject.values, [1, 2])
            subject.loadMore { error in XCTAssertNil(error)
                // THEN: it progressively loads the appropriate values
                XCTAssertEqual(subject.values, [1, 2, 3, 4])
                expection.fulfill()
            }
        }
        wait(for: [expection], timeout: 1)
    }
    
    func testLoadsSerially() {
        // GIVEN: a data source with 5 values and a page size of 2
        let expection = self.expectation(description: "did not complete the request")
        let loader = LoaderFake(values: Array(1...5))
        let size = 2
        // WHEN: asked to load twice in parallel
        let subject = Paginator(size: size) { page, size, completion in
            loader.load(page: page, size: size, completion: completion)
        }
        subject.loadMore { error in XCTAssertNil(error)
            // THEN: the first load request completes and the second one is cancelled
            XCTAssertEqual(subject.values, [1, 2])
            expection.fulfill()
        }
        subject.loadMore { _ in XCTFail() }
        wait(for: [expection], timeout: 5)
    }
    
    func testLoadsEverythingThenStops() {
        // GIVEN: a data source with 5 values and a page size of 2
        let expection = self.expectation(description: "did not complete all requests")
        let loader = LoaderFake(values: Array(1...5))
        let size = 2
        // WHEN: asked to load twice sequentially
        let subject = Paginator(size: size) { page, size, completion in
            loader.load(page: page, size: size, completion: completion)
        }
        subject.loadMore { error in XCTAssertNil(error)
            XCTAssertEqual(subject.values, [1, 2])
            subject.loadMore { error in XCTAssertNil(error)
                XCTAssertEqual(subject.values, [1, 2, 3, 4])
                subject.loadMore { error in XCTAssertNil(error)
                    // THEN: it progressively loads all values and cancels all
                    // requests when all have been loaded
                    XCTAssertEqual(subject.values, [1, 2, 3, 4, 5])
                    expection.fulfill()
                    subject.loadMore { _ in XCTFail() }
                }
            }
        }
        wait(for: [expection], timeout: 1)
    }
}
