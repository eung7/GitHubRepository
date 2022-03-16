//
//  RepositoryListViewController.swift
//  GitHubRepository
//
//  Created by 김응철 on 2022/03/16.
//

import UIKit

class RepositoryListViewController : UITableViewController {
    private let organization = "Apple"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = organization + " Repositories"
        
        self.refreshControl = UIRefreshControl() // 당겨서 새로고침
        let refreshControl = self.refreshControl
        refreshControl?.backgroundColor = .systemBackground
        refreshControl?.tintColor = .darkGray
        refreshControl?.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
//        refreshControl?.addTarget(self, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
        
        tableView.register(RepositoryListCell.self, forCellReuseIdentifier: "RepositoryListCell")
        tableView.rowHeight = 140
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RepositoryListCell",
            for: indexPath
        ) as? RepositoryListCell else { return UITableViewCell() }
        
        return cell
    }
}
