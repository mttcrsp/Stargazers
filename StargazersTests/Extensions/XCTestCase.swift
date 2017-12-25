//
//  XCTestCase.swift
//  StargazersTests
//
//  Created by Matteo Crespi on 25/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import XCTest

extension XCTestCase {
    func delay(by interval: TimeInterval, on queue: DispatchQueue = .global(), block: @escaping () -> Void) {
        queue.asyncAfter(deadline: .now() + interval, execute: block)
    }
}
