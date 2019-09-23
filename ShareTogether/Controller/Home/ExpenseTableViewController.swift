//
//  ExpenseTableViewController.swift
//  ShareTogether
//
//  Created by littlema on 2019/9/13.
//  Copyright © 2019 littema. All rights reserved.
//

import UIKit

protocol TableViewControllerDelegate: AnyObject {
    func tableViewDidScroll(viewController: UITableViewController, offsetY: CGFloat)
    func empty(isEmpty: Bool)
}

class ExpenseTableViewController: UITableViewController {
    
    weak var delegate: TableViewControllerDelegate?
    
    var viewModel: HomeViewModel!
    
    var observation: NSKeyValueObservation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerWithNib(indentifer: ExpenseTableViewCell.identifer)
        tableView.register(ExpenseFooterView.self,
                           forHeaderFooterViewReuseIdentifier: ExpenseFooterView.reuseIdentifier)
        // .old,, .prior
        observation = viewModel.observe(\.cellViewModels, options: [.initial, .new]) { (child, change) in
            self.tableView.reloadData()
        }
        
        viewModel.fectchData()

    }

}

// MARK: - Table view data source
extension ExpenseTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections == 0 ? delegate?.empty(isEmpty: true) : delegate?.empty(isEmpty: false) 
        return viewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleOfSections(section: section)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells(section: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseTableViewCell.identifer, for: indexPath)

        guard let recodeCell = cell as? ExpenseTableViewCell else { return cell }

        recodeCell.viewModel = viewModel.getExpenseCellViewModel(at: indexPath)

        return recodeCell

    }

}

// MARK: - Table view delegate
extension ExpenseTableViewController {
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    }

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
