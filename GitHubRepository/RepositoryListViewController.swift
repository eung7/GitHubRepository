//
//  RepositoryListViewController.swift
//  GitHubRepository
//
//  Created by 김응철 on 2022/03/16.
//
 
import UIKit
import RxSwift
import RxCocoa

class RepositoryListViewController : UITableViewController {
    private let organization = "Apple"
    private let repositories = BehaviorSubject<[Repository]>(value: [])
    private let dispoasBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefresh()
        
        title = organization + " Repositories"
            
        tableView.register(RepositoryListCell.self, forCellReuseIdentifier: "RepositoryListCell")
        tableView.rowHeight = 140
    }
    
    private func setupRefresh() {
        self.refreshControl = UIRefreshControl()
        let refreshControl = self.refreshControl
        refreshControl?.backgroundColor = .systemBackground
        refreshControl?.tintColor = .darkGray
        refreshControl?.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        refreshControl?.addTarget(self, action: #selector(didChangedRefresh), for: .valueChanged)
    }
    
    @objc func didChangedRefresh() {
        
    }
    
    // 네트워크를 통해 Json을 가져옴 -> Repository로 변환 -> BehaviorSubject로 onNext 하는 메서드
    func fetchRepositories(of organization : String) {
        Observable.from([organization])
            .map { str in
                URL(string: "https://api.github.com/orgs/\(str)/repos")!
            }
            .map { url -> URLRequest in
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                
                return request
            }
            .flatMap { request -> Observable<(response : HTTPURLResponse, data : Data)> in
                return URLSession.shared.rx.response(request: request)
            }
            .filter { response, _ in
                return 200..<300 ~= response.statusCode
            }
            .map { _, data -> [[String : Any]] in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                      let result = json as? [[String : Any]] else {
                    return []
                }
                return result
            }
            .filter { result in
                result.count > 0
            }
            .map { objects in
                return objects.compactMap { dic -> Repository? in
                    guard let id = dic["id"] as? Int,
                          let name  = dic["name"] as? String,
                          let description = dic["description"] as? String,
                          let stargazersCount = dic["stargazers_count"] as? Int,
                          let language = dic["language"] as? String else {
                        return nil
                    }
                    return Repository(
                        id: id,
                        name: name,
                        description: description,
                        stargazersCount: stargazersCount,
                        language: language
                    )
                }
            }
            .subscribe(onNext : { [weak self] newRepositories in
                self?.repositories.onNext(newRepositories)
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                }
            })
            .disposed(by: dispoasBag)
    }
}


// DataSource, delegate
extension RepositoryListViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RepositoryListCell",
            for: indexPath
        ) as? RepositoryListCell else { return UITableViewCell() }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
}

