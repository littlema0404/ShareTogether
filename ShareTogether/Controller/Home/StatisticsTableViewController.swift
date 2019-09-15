//
//  StatisticsTableViewController.swift
//  ShareTogether
//
//  Created by littlema on 2019/9/13.
//  Copyright © 2019 littema. All rights reserved.
//

import UIKit

class StatisticsTableViewController: UITableViewController {
    
    weak var delegate: TableViewControllerDelegate?
    
    lazy var viewModel: StatisticsViewModel = {
        return StatisticsViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerWithNib(indentifer: StatisticsTableViewCell.identifer)
    }
    
}

// MARK: - Table view data source
extension StatisticsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsTableViewCell.identifer, for: indexPath)
        
        guard let statisticsCell = cell as? StatisticsTableViewCell else { return cell }
        return statisticsCell
    }
    
}

// MARK: - Table view delegate
extension StatisticsTableViewController {
    
    override func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath) {
        
        cell.alpha = 0
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1
        }
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.tableViewDidScroll(viewController: self, offsetY: scrollView.contentOffset.y)
    }
    
}