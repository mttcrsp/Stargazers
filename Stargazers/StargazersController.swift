//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit

final class StargazersController: NSObject {
    
    private (set) var query = ""
    private (set) var selectedUser: User?
    private (set) var selectedRepository: Repository?
    
    private (set) var users: [User] = []
    private (set) var stargazers: [User] = []
    private (set) var repositories: [Repository] = []
    
    private weak var usersViewController: UsersViewController?
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var searchThrottler: Throttler?
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
        usersViewController.navigationItem.hidesSearchBarWhenScrolling = false
        usersViewController.navigationItem.searchController = searchController
        usersViewController.definesPresentationContext = true
        
        self.usersViewController = usersViewController
        
        let navigationController = usersViewController.embeddedInNavigationController
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }
    
    func performSearch(_ query: String) {
        gitHubClient.users(for: query) { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .success(let response):
                self.users = response.items
                self.usersViewController?.reloadData()
            case .failure(let error):
                self.usersViewController?.display(error)
            }
        }
    }
    
    func loadMoreRepositories() {}
    
    func loadMoreStargazers() {}
}

extension StargazersController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        query = searchController.searchBar.text ?? ""
        searchThrottler?.execute()
    }
}

extension StargazersController: UsersViewControllerDataSource, UsersViewControllerDelegate {
    
    func usersViewController(_ usersViewController: UsersViewController, didSelect user: User) {
        gitHubClient.repositories(for: user) { [weak self, weak usersViewController] result in
            guard let `self` = self, let usersViewController = usersViewController else { return }
            
            switch result {
            case .failure(let error):
                usersViewController.display(error)
            case .success(let repositories):
                self.repositories = repositories
                let repositoriesViewController = RepositoriesViewController()
                repositoriesViewController.delegate = self
                repositoriesViewController.dataSource = self
                repositoriesViewController.title = user.login
                repositoriesViewController.navigationItem.largeTitleDisplayMode = .never
                usersViewController.show(repositoriesViewController, sender: usersViewController)
            }
        }
    }
}

extension StargazersController: RepositoriesViewControllerDataSource, RepositoriesViewControllerDelegate {
    
    func repositoriesViewController(_ repositoriesViewController: RepositoriesViewController, didSelect repository: Repository) {
        gitHubClient.stargazers(for: repository) { [weak self, weak repositoriesViewController] result in
            guard let `self` = self, let repositoriesViewController = repositoriesViewController else { return }
            
            switch result {
            case .failure(let error):
                repositoriesViewController.display(error)
            case .success(let stargazers):
                self.stargazers = stargazers
                let stargazersViewController = StargazersViewController()
                stargazersViewController.dataSource = self
                stargazersViewController.title = repository.name
                repositoriesViewController.show(stargazersViewController, sender: repositoriesViewController)
            }
        }
    }
}

extension StargazersController: StargazersViewControllerDataSource {}
