//
//  Created by Matteo Crespi on 24/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Foundation

final class Paginator<Value> {
    
    typealias Loader = (Int, Int, @escaping (Result<[Value], Error>) -> Void) -> Void
    
    enum State { case waiting, loading, done }
    
    private (set) var state: State = .waiting
    private (set) var values: [Value] = []
    
    private let syncQueue: DispatchQueue = .global()
    private let loadPage: Loader
    private let pageSize: Int
    
    init(size: Int, block: @escaping Loader) {
        pageSize = size
        loadPage = block
    }
    
    func loadMore(_ completion: @escaping (Error?) -> Void) {
        syncQueue.async { [weak self] in
            guard let `self` = self, self.state == .waiting else { return }
            
            let values = self.values
            let pageSize = self.pageSize
            let currentPage = values.count / pageSize
            
            self.state = .loading
            self.loadPage(currentPage + 1, pageSize) { [weak self] response in
                guard let `self` = self else { return }
                
                switch response {
                case .failure(let error):
                    completion(error)
                    self.state = .waiting
                case .success(let values):
                    self.state = values.count < self.pageSize ? .done : .waiting
                    self.values += values
                    completion(nil)
                }
            }
        }
    }
}
