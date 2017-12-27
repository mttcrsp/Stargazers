//
//  Created by Matteo Crespi on 24/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Foundation

final class Paginator<Value> {
    
    typealias Loader = (Int, Int, @escaping (Result<[Value], Error>) -> Void) -> Void
    
    enum State { case waiting, loading, done }
    
    private (set) var state: State = .waiting
    
    private let syncQueue: DispatchQueue = .global()
    private let loadPage: Loader
    private var currentPage: Int
    private let pageSize: Int
    
    init(size: Int, initialPage: Int = 1, block: @escaping Loader) {
        currentPage = initialPage
        loadPage = block
        pageSize = size
    }
    
    func loadMore(_ completion: @escaping (Result<[Value], Error>) -> Void) {
        syncQueue.async { [weak self] in
            guard let `self` = self, self.state == .waiting else { return }
            
            self.state = .loading
            
            let pageSize = self.pageSize
            let currentPage = self.currentPage

            self.loadPage(currentPage, pageSize) { [weak self] result in
                guard let `self` = self else { return }
                
                switch result {
                case .failure:
                    self.state = .waiting
                case .success(let values):
                    self.state = values.count < self.pageSize ? .done : .waiting
                    self.currentPage += 1
                }
                
                completion(result)
            }
        }
    }
}
