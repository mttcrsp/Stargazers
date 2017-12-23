//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit

protocol RepositoriesViewControllerDataSource: class {
    var repositories: [Repository] { get }
    func loadMoreRepositories()
}

protocol RepositoriesViewControllerDelegate: class {
    func repositoriesViewController(_ repositoriesViewController: RepositoriesViewController, didSelect repository: Repository)
}

final class RepositoriesViewController: UITableViewController {
    
    weak var delegate: RepositoriesViewControllerDelegate?
    weak var dataSource: RepositoriesViewControllerDataSource?
    
    var repositories: [Repository] {
        return dataSource?.repositories ?? []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        cell.accessoryType = .disclosureIndicator
        cell.configure(with: repositories[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.repositoriesViewController(self, didSelect: repositories[indexPath.row])
    }
}
