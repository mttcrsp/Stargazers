//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Foundation

final class Throttler {
    
    let block: () -> Void
    let limit: TimeInterval
    let queue: DispatchQueue
    
    private var item: DispatchWorkItem?
    private let syncQueue: DispatchQueue = .global()
    
    init(limit: TimeInterval, queue: DispatchQueue = .main, block: @escaping () -> Void) {
        self.limit = limit
        self.block = block
        self.queue = queue
    }
    
    func execute() {
        syncQueue.async { [weak self] in
            guard let `self` = self else { return }
            
            self.cancel()
            
            let block = self.block
            let limit = self.limit
            let queue = self.queue
            
            let item = DispatchWorkItem(block: block)
            queue.asyncAfter(deadline: .now() + limit, execute: item)
            self.item = item
        }
    }
    
    func reset() {
        syncQueue.async { [weak self] in self?.cancel() }
    }
    
    private func cancel() {
        item?.cancel()
        item = nil
    }
}
