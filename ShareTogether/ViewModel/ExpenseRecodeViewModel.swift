//
//  ExpenseRecodeViewModel.swift
//  ShareTogether
//
//  Created by littlema on 2019/8/28.
//  Copyright © 2019 littema. All rights reserved.
//

import Foundation
import UIKit

class ExpenseRecodeViewModel: NSObject {    
    private var expenseRecodes = [ExpenseRecode]()
    
    private var cellViewModels: [ExpenseRecodeCellViewModel] = [ExpenseRecodeCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    var numberOfCells: Int {
        return cellViewModels.count
    }
    
    var reloadTableViewClosure: (() -> Void)?
    
    var passOffset: ((CGFloat) -> Void)?
    
//    func initFetch() {
//        let data = [ExpenseRecode(userId: "j620178", userImg: "12", userName: "littlema", time: "2018/10/02", title: "早餐", amount: 20),
//                    ExpenseRecode(userId: "j620178", userImg: "12", userName: "littlema", time: "2018/10/02", title: "早餐", amount: 20),
//                    ExpenseRecode(userId: "j620178", userImg: "12", userName: "littlema", time: "2018/10/02", title: "早餐", amount: 20),
//                    ExpenseRecode(userId: "j620178", userImg: "12", userName: "littlema", time: "2018/10/02", title: "早餐", amount: 20)]
//        return data
//    }
//    
    func createCellViewModel(expenseRecode: ExpenseRecode) -> ExpenseRecodeCellViewModel {
    
        return ExpenseRecodeCellViewModel( titleText: expenseRecode.title,
                                       timeText: expenseRecode.time,
                                       imageUrl: expenseRecode.userImg,
                                       amountText: "\(expenseRecode.amount)")
    }
    
    private func processFetchedRecodes(expenseRecodes: [ExpenseRecode]) {
        self.expenseRecodes = expenseRecodes // Cache
        var vms = [ExpenseRecodeCellViewModel]()
        for recode in expenseRecodes {
            vms.append(createCellViewModel(expenseRecode: recode) )
        }
        self.cellViewModels = vms
    }

}

extension ExpenseRecodeViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "今天" : "8月27日"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 5 : 7
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseTableViewCell.identifer, for: indexPath)
        
        guard let recodeCell = cell as? ExpenseTableViewCell else { return cell }
        recodeCell.insetContentView.layer.cornerRadius = 0
        if indexPath.row == 0 {
            recodeCell.insetContentView.layer.cornerRadius = 15.0
            recodeCell.insetContentView.layer.maskedCorners = [
                CACornerMask.layerMinXMinYCorner,
                CACornerMask.layerMaxXMinYCorner
            ]
        } else if (indexPath.section == 0 && indexPath.row == 4) || (indexPath.section == 1 && indexPath.row == 6) {
            recodeCell.insetContentView.layer.cornerRadius = 15.0
            recodeCell.insetContentView.layer.maskedCorners = [
                CACornerMask.layerMinXMaxYCorner,
                CACornerMask.layerMaxXMaxYCorner
            ]
        }
        
        return recodeCell
    }
    
}

extension ExpenseRecodeViewModel: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        passOffset?(scrollView.contentOffset.y)
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 1 ? 120 : 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return section == 1 ? UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 120)) : nil
    }
    
}

struct ExpenseRecodeCellViewModel {
    let titleText: String
    let timeText: String
    let imageUrl: String
    let amountText: String
}
