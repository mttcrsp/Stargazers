//
//  Created by Matteo Crespi on 24/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Foundation

/// A lightweight class that simplifies consumption of paginated APIs like the
/// repositories and stargazers ones. It ensures that the same page is not
/// loaded in parallel by multiple requests, that once all values from the API
/// are received no other request is performed and automatically handles page
/// progression based on page size.
final class Paginator<Value> {
    
    /// A page loading function takes 3 parameters:
    ///  1. the index of the page that should be loaded;
    ///  2. the number of values that should be requested;
    ///  3. a completion handle to handle incoming values and errors.
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
            // Check that loading has yet to be started and that there's more
            // content to be loaded by looking at the state property.
            guard let `self` = self, self.state == .waiting else { return }
            
            // Signal that loading has begun to prevent the execution of
            // multiple requests at the same time.
            self.state = .loading
            
            let pageSize = self.pageSize
            let currentPage = self.currentPage

            self.loadPage(currentPage, pageSize) { [weak self] result in
                guard let `self` = self else { return }
                
                switch result {
                case .failure:
                    self.state = .waiting
                case .success(let values):
                    // If the number of values received is lower than the number
                    // of values requested, you know that there should be no
                    // more values to be loaded.
                    //
                    // WARNING: This is a trivial implementation of a pagination
                    // handling algorithm:
                    //  1. it doesn't account for the fact that basically every
                    //     paginated API reports the actual number of pages
                    //     available (including the GitHub API);
                    //  2. makes an unnecessary request if the number of values
                    //     to be loaded matches a multiple of the page size;
                    //  3. ...
                    //
                    // I decided to go for this implementation fully knowing
                    // that this is not production level code because its very
                    // easy to implement and leads to a pretty simple API. It
                    // only has one `loadMore` function that can be overloaded
                    // with calls and it will automatically behave as intended,
                    // only performing the necessary API calls.
                    self.state = values.count < self.pageSize ? .done : .waiting
                    self.currentPage += 1
                }
                
                completion(result)
            }
        }
    }
}
