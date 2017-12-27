//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit

/// The controller that manages flow within the requested functionality. It
/// receives user generated events from the different view controller and
/// responds to them by triggering API requests and presenting more view
/// controllers.
final class StargazersController: NSObject {
    
    private (set) var query = ""
    private (set) var users: [User] = []
    private (set) var stargazers: [User] = []
    private (set) var repositories: [Repository] = []
    
    private weak var usersViewController: UsersViewController?
    private weak var splitViewController: UISplitViewController?
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search user", comment: "Users search bar placeholder")
        return searchController
    }()
    
    private lazy var searchThrottler: Throttler = {
        return Throttler(limit: 0.5) { [weak self] in
            // If a non empty input for a search was provided by the user,
            // perform a new request to the users search API.
            guard let `self` = self, !self.query.isEmpty else { return }
            
            self.gitHubAPIClient.users(for: self.query) { [weak self] result in
                switch result {
                case .success(let users):
                    self?.users = users
                    self?.usersViewController?.reloadData()
                case .failure(let error):
                    self?.usersViewController?.display(error)
                }
            }
        }
    }()
    
    private var stargazersPaginator: Paginator<User>?
    private var repositoriesPaginator: Paginator<Repository>?
    
    private let limiter = Limiter()
    private var gitHubAPIClient: GitHubAPIClient
    
    init(session: URLSessionType = URLSession.shared) {
        self.gitHubAPIClient = GitHubAPIClient(session: session)
    }
    
    func startFlow(from window: UIWindow) {
        // Build the view controllers users view controller
        let usersViewController = UsersViewController()
        usersViewController.delegate = self
        usersViewController.dataSource = self
        
        // Make it the presenting view controller during searches
        usersViewController.definesPresentationContext = true
        
        let navigationController = UINavigationController(rootViewController: usersViewController)
        if #available(iOS 11.0, *) {
            // On iOS 11+ use large titles and display the users search bar
            // within the navigation controller navigation bar.
            navigationController.navigationBar.prefersLargeTitles = true
            usersViewController.navigationItem.hidesSearchBarWhenScrolling = false
            usersViewController.navigationItem.searchController = searchController
        } else {
            // On older versions of the OS display the search bar as users view
            // controller table view header view.
            usersViewController.tableView.tableHeaderView = searchController.searchBar
        }
        
        let splitViewController = UISplitViewController()
        splitViewController.viewControllers = [navigationController]
        
        // Set the newly create view controller as the root of the provided
        // window to start the functionality flow.
        window.rootViewController = splitViewController
        
        // Keep references to both the users view controller and the split view
        // controller as they will be needed later in the flow.
        self.splitViewController = splitViewController
        self.usersViewController = usersViewController
    }
}

extension StargazersController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // If the user input in within the search bar changed trigger a new
        // search request.
        let newQuery = searchController.searchBar.text ?? ""
        if query != newQuery {
            query = newQuery
            searchThrottler.execute()
        }
    }
}

extension StargazersController: UsersViewControllerDataSource, UsersViewControllerDelegate {
    
    func usersViewController(_ usersViewController: UsersViewController, didSelect user: User) {
        limiter.execute { [weak self] item in
            // Build a new object to manage requests to the users repositories
            // paginated API.
            self?.repositoriesPaginator = Paginator(size: 50, block: { page, perPage, completion in
                self?.gitHubAPIClient.repositories(for: user, page: page, perPage: perPage, completion: completion)
            })
            
            // Trigger loading of the first page of user repositories
            self?.repositoriesPaginator?.loadMore { result in
                guard let `self` = self, let splitViewController = self.splitViewController else { return }
                
                switch result {
                case .failure(let error):
                    splitViewController.display(error)
                case .success(let repositories):
                    let detailViewController: UIViewController
                    
                    self.repositories = repositories
                    
                    if self.repositories.isEmpty {
                        // If a user has yet to create its first repository (aka the
                        // request to the pagination API returned no results and no
                        // errors), display a message stating the there are no
                        // repositories for this user.
                        let messageViewController = MessageViewController()
                        messageViewController.message = .localizedStringWithFormat(NSLocalizedString("%@ has no repositories", comment: "displayed as an empty screen message"), user.login)
                        detailViewController = messageViewController
                    } else {
                        // Otherwise, show the list of repositories with the result
                        // from the first request to the pagination API.
                        let repositoriesViewController = RepositoriesViewController()
                        repositoriesViewController.delegate = self
                        repositoriesViewController.dataSource = self
                        detailViewController = repositoriesViewController
                    }
                    
                    detailViewController.title = user.login
                    
                    if #available(iOS 11.0, *) {
                        detailViewController.navigationItem.largeTitleDisplayMode = .never
                    }
                    
                    let navigationController = UINavigationController(rootViewController: detailViewController)
                    splitViewController.showDetailViewController(navigationController, sender: self)
                }
            }
        }
    }
}

extension StargazersController: RepositoriesViewControllerDataSource, RepositoriesViewControllerDelegate {
    
    func repositoriesViewController(_ repositoriesViewController: RepositoriesViewController, didSelect repository: Repository) {
        // Wrapping the following piece of code in this call to the limiter
        // object prevents multiple selection events generated by the user to
        // trigger multiple requests at the same time, which could potentially
        // lead to inconsistent states.
        limiter.execute { [weak self, weak repositoriesViewController] item in
            self?.stargazersPaginator = Paginator(size: 100, block: { page, perPage, completion in
                self?.gitHubAPIClient.stargazers(for: repository, page: page, perPage: perPage, completion: completion)
            })
            
            self?.stargazersPaginator?.loadMore { result in
                guard let `self` = self, let repositoriesViewController = repositoriesViewController else { return }
                
                switch result {
                case .failure(let error):
                    repositoriesViewController.display(error)
                case .success(let stargazers):
                    self.stargazers = stargazers
                    
                    let stargazersViewController = StargazersViewController()
                    stargazersViewController.delegate = self
                    stargazersViewController.dataSource = self
                    stargazersViewController.title = repository.name
                    repositoriesViewController.show(stargazersViewController, sender: self)
                }
            }
        }
    }
    
    func repositoriesViewControllerWillReachBottom(_ repositoriesViewController: RepositoriesViewController) {
        // When the user is about to reach the bottom of the repositories view
        // controller trigger a new paginated request to the repositories API.
        repositoriesPaginator?.loadMore { [weak self, weak repositoriesViewController] result in
            switch result {
            case .failure(let error):
                repositoriesViewController?.display(error)
            case .success(let repositories):
                self?.repositories += repositories
                repositoriesViewController?.reloadData()
            }
        }
    }
}

extension StargazersController: StargazersViewControllerDataSource, StargazersViewControllerDelegate {
    
    func stargazersViewControllerWillReachBottom(_ stargazersViewController: StargazersViewController) {
        stargazersPaginator?.loadMore { [weak self, weak stargazersViewController] result in
            switch result {
            case .failure(let error):
                stargazersViewController?.display(error)
            case .success(let stargazers):
                self?.stargazers += stargazers
                stargazersViewController?.reloadData()
            }
        }
    }
}
