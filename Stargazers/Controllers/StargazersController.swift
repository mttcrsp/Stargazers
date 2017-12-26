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
        
        self.usersViewController = usersViewController
        
        let navigationController = UINavigationController(rootViewController: usersViewController)
        navigationController.delegate = self
        
        if #available(iOS 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
            usersViewController.navigationItem.searchController = searchController
            usersViewController.navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            usersViewController.tableView.tableHeaderView = searchController.searchBar
        }
        
        window.rootViewController = navigationController
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
        interactionLimiter.execute { [weak self, weak usersViewController] item in
            let paginator = Paginator(size: 50, block: { page, perPage, completion in
                self?.gitHubClient.repositories(for: user, page: page, perPage: perPage, completion: completion)
            })
            
            paginator.loadMore { error in
                guard let `self` = self, let usersViewController = usersViewController else { return }
                
                if let error = error {
                    return usersViewController.display(error)
                }
                
                let repositoriesViewController = RepositoriesViewController()
                repositoriesViewController.delegate = self
                repositoriesViewController.dataSource = self
                repositoriesViewController.title = user.login
                
                if #available(iOS 11.0, *) {
                    repositoriesViewController.navigationItem.largeTitleDisplayMode = .never
                }
                
                usersViewController.show(repositoriesViewController, sender: usersViewController)
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
                repositoriesViewController.show(stargazersViewController, sender: repositoriesViewController)
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

extension StargazersController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is UsersViewController {
            interactionLimiter.cancel()
        }
    }
}
