//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit

protocol StargazersViewControllerDataSource: class {
    var stargazers: [User] { get }
}

protocol StargazersViewControllerDelegate: class {
    func stargazersViewControllerWillReachBottom(_ stargazersViewController: StargazersViewController)
}

final class StargazersViewController: UITableViewController {
    
    weak var dataSource: StargazersViewControllerDataSource?
    weak var delegate: StargazersViewControllerDelegate?
    
    var stargazers: [User] {
        return dataSource?.stargazers ?? []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.reuseIdentifier)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stargazers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.reuseIdentifier, for: indexPath) as! UserTableViewCell
        cell.configure(with: stargazers[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row > stargazers.count - tableView.visibleIndexPathsCount {
            delegate?.stargazersViewControllerWillReachBottom(self)
        }
    }
}
