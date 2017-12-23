//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit

protocol UsersViewControllerDataSource: class {
    var users: [User] { get }
}

protocol UsersViewControllerDelegate: class {
    func usersViewController(_ usersViewController: UsersViewController, didSelect user: User)
}

final class UsersViewController: UITableViewController {
    
    weak var delegate: UsersViewControllerDelegate?
    weak var dataSource: UsersViewControllerDataSource?
    
    var users: [User] { return dataSource?.users ?? [] }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("✨ Stargazers", comment: "initial screen title")
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.reuseIdentifier)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.reuseIdentifier, for: indexPath) as! UserTableViewCell
        cell.configure(with: users[indexPath.row])
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.usersViewController(self, didSelect: users[indexPath.row])
    }
}
