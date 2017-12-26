//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit

final class StargazersController: NSObject {
    
    private (set) var query = ""
    private (set) var users: [User] = []
    
    private var stargazersPaginator: Paginator<User>?
    private var repositoriesPaginator: Paginator<Repository>?
    
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
            guard let `self` = self, !self.query.isEmpty else { return }
            
            self.gitHubClient.users(for: self.query) { [weak self] result in
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
    
    private let interactionLimiter = Limiter()
    private var gitHubClient: GitHubAPIClient
    
    init(session: URLSessionType = URLSession.shared) {
        self.gitHubClient = GitHubAPIClient(session: session)
    }
    
    func startFlow(from window: UIWindow) {
        let usersViewController = UsersViewController()
        usersViewController.delegate = self
        usersViewController.dataSource = self
        usersViewController.definesPresentationContext = true
        
        let navigationController = UINavigationController(rootViewController: usersViewController)
        
        if #available(iOS 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
            usersViewController.navigationItem.hidesSearchBarWhenScrolling = false
            usersViewController.navigationItem.searchController = searchController
        } else {
            usersViewController.tableView.tableHeaderView = searchController.searchBar
        }
        
        let splitViewController = UISplitViewController()
        splitViewController.viewControllers = [navigationController]
        
        self.splitViewController = splitViewController
        self.usersViewController = usersViewController
        
        window.rootViewController = splitViewController
    }
}

extension StargazersController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let newQuery = searchController.searchBar.text ?? ""
        if query != newQuery {
            query = newQuery
            searchThrottler.execute()
        }
    }
}

extension StargazersController: UsersViewControllerDataSource, UsersViewControllerDelegate {
    
    func usersViewController(_ usersViewController: UsersViewController, didSelect user: User) {
        interactionLimiter.execute { [weak self] item in
            let paginator = Paginator(size: 50, block: { page, perPage, completion in
                self?.gitHubClient.repositories(for: user, page: page, perPage: perPage, completion: completion)
            })
            
            paginator.loadMore { error in
                guard let `self` = self, let splitViewController = self.splitViewController else { return }
                
                if let error = error {
                    return splitViewController.display(error)
                }
                
                let detailViewController: UIViewController
                
                if self.repositories.isEmpty {
                    let messageViewController = MessageViewController()
                    messageViewController.message = .localizedStringWithFormat(NSLocalizedString("%@ has no repositories", comment: "displayed as an empty screen message"), user.login)
                    detailViewController = messageViewController
                } else {
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
            
            self?.repositoriesPaginator = paginator
        }
    }
}

extension StargazersController: RepositoriesViewControllerDataSource, RepositoriesViewControllerDelegate {
    
    var repositories: [Repository] { return repositoriesPaginator?.values ?? [] }
    
    func repositoriesViewController(_ repositoriesViewController: RepositoriesViewController, didSelect repository: Repository) {
        interactionLimiter.execute { [weak self, weak repositoriesViewController] item in
            let paginator = Paginator(size: 100, block: { page, perPage, completion in
                self?.gitHubClient.stargazers(for: repository, page: page, perPage: perPage, completion: completion)
            })
            
            paginator.loadMore { error in
                guard let `self` = self, let repositoriesViewController = repositoriesViewController else { return }
                
                if let error = error {
                    return repositoriesViewController.display(error)
                }
                
                let stargazersViewController = StargazersViewController()
                stargazersViewController.delegate = self
                stargazersViewController.dataSource = self
                stargazersViewController.title = repository.name
                repositoriesViewController.show(stargazersViewController, sender: self)
            }
            
            self?.stargazersPaginator = paginator
        }
    }
    
    func repositoriesViewControllerWillReachBottom(_ repositoriesViewController: RepositoriesViewController) {
        repositoriesPaginator?.loadMore { error in
            if let error = error {
                repositoriesViewController.display(error)
            } else {
                repositoriesViewController.reloadData()
            }
        }
    }
}

extension StargazersController: StargazersViewControllerDataSource, StargazersViewControllerDelegate {
    
    var stargazers: [User] { return stargazersPaginator?.values ?? [] }
    
    func stargazersViewControllerWillReachBottom(_ stargazersViewController: StargazersViewController) {
        stargazersPaginator?.loadMore { error in
            if let error = error {
                stargazersViewController.display(error)
            } else {
                stargazersViewController.reloadData()
            }
        }
    }
}
