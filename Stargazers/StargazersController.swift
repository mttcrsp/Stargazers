//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit

final class StargazersController {
    
    private (set) var query = ""
    private (set) var selectedUser: User?
    private (set) var selectedRepository: Repository?
    
    private (set) var users: [User] = []
    private (set) var stargazers: [User] = []
    private (set) var repositories: [Repository] = []
    
    private weak var usersViewController: UsersViewController?
    private weak var repositoriesViewController: RepositoriesViewController?
    private weak var stargazersViewController: StargazersViewController?
    
    private var gitHubClient: GitHubAPIClient
    private var searchThrottler: Throttler?
    
    init(gitHubClient: GitHubAPIClient = GitHubAPIClient()) {
        self.gitHubClient = gitHubClient
        self.searchThrottler = Throttler(limit: 0.5) { [weak self] in
            if let `self` = self { self.performSearch(self.query) }
        }
    }
    
    var initialViewController: UIViewController {
        let usersViewController = UsersViewController()
        usersViewController.delegate = self
        usersViewController.dataSource = self
        return usersViewController.embeddedInNavigationController
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

extension StargazersController: UsersViewControllerDataSource, UsersViewControllerDelegate {
    
    func usersViewController(_ usersViewController: UsersViewController, didEnter query: String) {
        self.query = query
        self.searchThrottler?.execute()
    }
    
    func usersViewController(_ usersViewController: UsersViewController, didSelect user: User) {
        let repositoriesViewController = RepositoriesViewController()
        repositoriesViewController.delegate = self
        repositoriesViewController.dataSource = self
        usersViewController.navigationController?.present(repositoriesViewController, animated: true)
    }
}

extension StargazersController: RepositoriesViewControllerDataSource, RepositoriesViewControllerDelegate {
    
    func repositoriesViewController(_ repositoriesViewController: RepositoriesViewController, didSelect repository: Repository) {
        let stargazersViewController = StargazersViewController()
        stargazersViewController.dataSource = self
        repositoriesViewController.navigationController?.pushViewController(stargazersViewController, animated: true)
    }
}

extension StargazersController: StargazersViewControllerDataSource {
    
}
