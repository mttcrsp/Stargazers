//
//  Created by Matteo Crespi on 24/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Dispatch

final class Limiter {
    
    let queue: DispatchQueue
    
    private var item: DispatchWorkItem?
    private let syncQueue: DispatchQueue = .global()
    
    init(queue: DispatchQueue = .main) {
        self.queue = queue
    }
    
    func execute(_ block: @escaping (DispatchWorkItem) -> Void) {
        syncQueue.async { [weak self] in
            guard let `self` = self else { return }
            
            self.cancel()
            
            let _block = { [weak self] in
                if let item = self?.item { block(item) }
            }
            
            let item = DispatchWorkItem(block: _block)
            self.queue.async(execute: item)
            self.item = item
        }
    }
    
    func cancel() {
        item?.cancel()
        item = nil
    }
}
