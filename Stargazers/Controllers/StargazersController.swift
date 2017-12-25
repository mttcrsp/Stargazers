//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit

final class StargazersController: NSObject {
    
    private (set) var query = ""
    private (set) var users: [User] = []
    
    var stargazers: [User] { return stargazersPaginator?.values ?? [] }
    var repositories: [Repository] { return repositoriesPaginator?.values ?? [] }
    
    private var stargazersPaginator: Paginator<User>?
    private var repositoriesPaginator: Paginator<Repository>?
    
    private weak var usersViewController: UsersViewController?
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchThrottler: Throttler?
    
    private let interactionLimiter = Limiter()
    private var gitHubClient: GitHubAPIClient
    
    init(gitHubClient: GitHubAPIClient = GitHubAPIClient()) {
        self.gitHubClient = gitHubClient
        
        super.init()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search user", comment: "Users search bar placeholder")
        
        searchThrottler = Throttler(limit: 0.5) { [weak self] in
            if let `self` = self, !self.query.isEmpty { self.performSearch(self.query) }
        }
    }
    
    var initialViewController: UIViewController {
        let usersViewController = UsersViewController()
        usersViewController.delegate = self
        usersViewController.dataSource = self
        usersViewController.definesPresentationContext = true
        
        self.usersViewController = usersViewController
        
        let navigationController = usersViewController.embeddedInNavigationController
        
        if #available(iOS 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
            usersViewController.navigationItem.searchController = searchController
            usersViewController.navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            usersViewController.tableView.tableHeaderView = searchController.searchBar
        }
        
        return navigationController
    }
    
    func performSearch(_ query: String) {
        gitHubClient.users(for: query) { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .success(let users):
                self.users = users
                self.usersViewController?.reloadData()
            case .failure(let error):
                self.usersViewController?.display(error)
            }
        }
    }
    
    func loadMoreRepositories(for repositoriesViewController: RepositoriesViewController) {
        repositoriesPaginator?.loadMore { error in
            if let error = error {
                repositoriesViewController.display(error)
            } else {
                repositoriesViewController.reloadData()
            }
        }
    }
    
    func loadMoreStargazers(for stargazersViewController: StargazersViewController) {
        stargazersPaginator?.loadMore { error in
            if let error = error {
                stargazersViewController.display(error)
            } else {
                stargazersViewController.reloadData()
            }
        }
    }
}

extension StargazersController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let newQuery = searchController.searchBar.text ?? ""
        if query != newQuery {
            query = newQuery
            searchThrottler?.execute()
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
                stargazersViewController.dataSource = self
                stargazersViewController.title = repository.name
                repositoriesViewController.show(stargazersViewController, sender: repositoriesViewController)
            }
            
            self?.stargazersPaginator = paginator
        }
    }
}

extension StargazersController: StargazersViewControllerDataSource {}
