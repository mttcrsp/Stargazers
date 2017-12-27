//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit

protocol RepositoriesViewControllerDataSource: class {
    var repositories: [Repository] { get }
}

protocol RepositoriesViewControllerDelegate: class {
    func repositoriesViewController(_ repositoriesViewController: RepositoriesViewController, didSelect repository: Repository)
    func repositoriesViewControllerWillReachBottom(_ repositoriesViewController: RepositoriesViewController)
}

final class RepositoriesViewController: UITableViewController {
    
    weak var delegate: RepositoriesViewControllerDelegate?
    weak var dataSource: RepositoriesViewControllerDataSource?
    
    var repositories: [Repository] {
        return dataSource?.repositories ?? []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: RepositoryTableViewCell.reuseIdentifier)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryTableViewCell.reuseIdentifier, for: indexPath) as! RepositoryTableViewCell
        
        // Only allow selection of repositories with more than one stargazer
        // associated with them. Otherwise there's you'd just be presenting a
        // screen that you already know will be empty.
        let repository = repositories[indexPath.row]
        cell.accessoryType = repository.hasStargazers ? .disclosureIndicator : .none
        cell.selectionStyle = repository.hasStargazers ? .default : .none
        cell.configure(with: repository)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if repositories[indexPath.row].hasStargazers {
            delegate?.repositoriesViewController(self, didSelect: repositories[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // When the table view has a screenful left of content signal to the
        // delegate object that the view controller is about to run out of
        // content.
        if indexPath.row > repositories.count - tableView.visibleIndexPathsCount {
            delegate?.repositoriesViewControllerWillReachBottom(self)
        }
    }
}
