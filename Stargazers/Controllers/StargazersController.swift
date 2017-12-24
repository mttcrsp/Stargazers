//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit

final class StargazersController: NSObject {
    
    private (set) var query = ""
    
    private (set) var selectedUser: User? {
        didSet { allRepositoriesLoaded = false ; repositories = [] }
    }
    
    private (set) var selectedRepository: Repository? {
        didSet { allStargazersLoaded = false ; stargazers = [] }
    }
    
    private (set) var users: [User] = []
    private (set) var stargazers: [User] = []
    private (set) var repositories: [Repository] = []
    
    private weak var usersViewController: UsersViewController?
    private weak var stargazersViewController: StargazersViewController?
    private weak var repositoriesViewController: RepositoriesViewController?
    
    // WARNING: The GitHub API page numbering is 1-based. (https://developer.github.com/v3/#pagination)
    private var currentStargazersPage: Int { return stargazers.count / gitHubClient.stargazersPerPage }
    private var currentRepositoriesPage: Int { return repositories.count / gitHubClient.repositoriesPerPage }
    
    private var allStargazersLoaded = false
    private var allRepositoriesLoaded = false
    
    private let loadingQueue = OperationQueue()
    
    private var isLoadingStargazers = false
    private var isLoadingRepositories = false
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let limiter = Limiter()
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
    
    func loadMoreRepositories(for repositoriesViewController: RepositoriesViewController) {
        guard let user = selectedUser, !isLoadingRepositories else { return }
        
        isLoadingRepositories = true
        gitHubClient.repositories(for: user, page: currentRepositoriesPage + 1) { [weak self, weak repositoriesViewController] response in
            guard let `self` = self, let repositoriesViewController = repositoriesViewController else { return }
            
            defer { self.isLoadingRepositories = false }
            
            switch response {
            case .failure(let error):
                repositoriesViewController.display(error)
            case .success(let repositories):
                if repositories.isEmpty {
                    self.allRepositoriesLoaded = true
                } else {
                    self.repositories.append(contentsOf: repositories)
                    repositoriesViewController.reloadData()
                }
            }
        }
    }
    
    func loadMoreStargazers(for stargazersViewController: StargazersViewController) {
        guard let repository = selectedRepository, !isLoadingStargazers else { return }
        
        isLoadingStargazers = true
        gitHubClient.stargazers(for: repository, page: currentStargazersPage + 1) { [weak self, weak stargazersViewController] response in
            guard let `self` = self, let stargazersViewController = stargazersViewController else { return }
            
            defer { self.isLoadingStargazers = false }
            
            switch response {
            case .failure(let error):
                stargazersViewController.display(error)
            case .success(let stargazers):
                if stargazers.isEmpty {
                    self.allStargazersLoaded = true
                } else {
                    self.stargazers.append(contentsOf: stargazers)
                    stargazersViewController.reloadData()
                }
            }
        }
    }
}

extension StargazersController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        query = searchController.searchBar.text ?? ""
        searchThrottler?.execute()
    }
}

extension StargazersController: UsersViewControllerDataSource, UsersViewControllerDelegate {
    
    func usersViewController(_ usersViewController: UsersViewController, didSelect user: User) {
        limiter.execute { [weak self, weak usersViewController] item in
            self?.gitHubClient.repositories(for: user) { result in
                guard let `self` = self, let usersViewController = usersViewController, !item.isCancelled else { return }
                
                switch result {
                case .failure(let error):
                    usersViewController.display(error)
                case .success(let repositories):
                    let repositoriesViewController = RepositoriesViewController()
                    repositoriesViewController.delegate = self
                    repositoriesViewController.dataSource = self
                    repositoriesViewController.title = user.login
                    repositoriesViewController.navigationItem.largeTitleDisplayMode = .never
                    usersViewController.show(repositoriesViewController, sender: usersViewController)
                    
                    self.selectedUser = user
                    self.repositories = repositories
                    self.repositoriesViewController = repositoriesViewController
                }
            }
        }
    }
}

extension StargazersController: RepositoriesViewControllerDataSource, RepositoriesViewControllerDelegate {
    
    func repositoriesViewController(_ repositoriesViewController: RepositoriesViewController, didSelect repository: Repository) {
        limiter.execute { [weak self, weak repositoriesViewController] item in
            self?.gitHubClient.stargazers(for: repository) { result in
                guard let `self` = self, let repositoriesViewController = repositoriesViewController, !item.isCancelled else { return }
                
                switch result {
                case .failure(let error):
                    repositoriesViewController.display(error)
                case .success(let stargazers):
                    let stargazersViewController = StargazersViewController()
                    stargazersViewController.dataSource = self
                    stargazersViewController.title = repository.name
                    repositoriesViewController.show(stargazersViewController, sender: repositoriesViewController)
                    
                    self.stargazers = stargazers
                    self.stargazersViewController = stargazersViewController
                    self.selectedRepository = repository
                }
            }
        }
    }
}

extension StargazersController: StargazersViewControllerDataSource {}
