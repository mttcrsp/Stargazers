//
//  Created by Matteo Crespi on 24/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Dispatch

/// A class that can be used to ensure that, given multiple requests in rapid
/// succession, only the latter is actually performed and completed, cancelling
/// all previous ones. This is particularly useful to handle situations in which
/// the user may perform multiple conflicting actions. (e.g. tapping many cells
/// in rapid succession to open the detail screen of different users)
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
