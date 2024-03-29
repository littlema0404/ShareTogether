//
//  ExpenseRecodeViewModel.swift
//  ShareTogether
//
//  Created by littlema on 2019/8/28.
//  Copyright © 2019 littema. All rights reserved.
//

import Foundation

class HomeExpenseViewModel: NSObject {
    
    var expenses = [Expense]()
    
    private var cellViewModels = [[HomeExpenseCellViewModel]]() {
        didSet {
            reloadTableViewHandler?()
        }
    }
    
    private var titleOfSections = [String]()
    
    var reloadTableViewHandler: (() -> Void)?
    var showAlertHandler: (() -> Void)?
    var updateLoadingStatusHandler: (() -> Void)?
    
    var numberOfSections: Int {
        return cellViewModels.count
    }
    
    func numberOfCells(section: Int) -> Int {
        return cellViewModels[section].count
    }
    
    func titleOfSections(section: Int) -> String {
        return titleOfSections[section]
    }
    
    func getCellViewModel(section: Int, row: Int) -> HomeExpenseCellViewModel {
        
        if row == 0 {
            
            return cellViewModels[section][row]
            
        } else {
            
            for vmSection in cellViewModels.indices {
                
                let lastSection = vmSection
                
                let lastRow = cellViewModels[vmSection].count - 1
                
                if section == lastSection, row == lastRow {
                    
                    return cellViewModels[section][row]
                }
            }
        }
        
        return cellViewModels[section][row]
    }
    
    func createCellViewModels(expense: Expense) -> HomeExpenseCellViewModel {
                
        return HomeExpenseCellViewModel(id: expense.id,
                                        type: ExpenseType(rawValue: expense.type)!,
                                        title: expense.desc,
                                        img: expense.splitInfo.amountDesc[0].member.photoURL,
                                        time: expense.time.toFullFormat,
                                        amount: expense.amount)
    }
    
    func fectchData() {
        
        FirestoreManager.shared.getExpenses { [weak self] result in
            
            switch result {
                
            case .success(let expenses):
                
                if expenses.isEmpty {
                    
                    self?.expenses = [Expense]()
                    
                    self?.cellViewModels = [[HomeExpenseCellViewModel]]()
                    
                } else {
                    
                    self?.expenses = expenses
                    
                    self?.processData()
                }

            case .failure(let error):
                print(error)
            }
        }
    }
    
    func processData() {
        
        var viewModels = [[HomeExpenseCellViewModel]]()
        
        var viewModelsSection = [HomeExpenseCellViewModel]()
        
        var index = 0
        
        titleOfSections = [String]()
        
        titleOfSections.append(expenses[0].time.toSimpleFormat)
        
        for expense in expenses {
            
            if titleOfSections[index] == expense.time.toSimpleFormat {
                
                viewModelsSection.append(createCellViewModels(expense: expense))
                
            } else {
                
                viewModels.append(viewModelsSection)
                
                titleOfSections.append(expense.time.toSimpleFormat)
                
                viewModelsSection = [HomeExpenseCellViewModel]()
                
                viewModelsSection.append(createCellViewModels(expense: expense))
                
                index += 1
            }
        }
        
        viewModels.append(viewModelsSection)
        
        self.cellViewModels = viewModels
    }
}
