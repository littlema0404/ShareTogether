//
//  MainViewController.swift
//  ShareTogether
//
//  Created by littlema on 2019/8/27.
//  Copyright © 2019 littema. All rights reserved.
//

import UIKit

class HomeViewController: STBaseViewController {
    
    enum InfoType: String {
        case expense = "交易紀錄"
        case statistics = "金額統計"
        case result = "結算結果"
        case notebook = "記事本"
    }
    
    let infoItems = [InfoType.expense, InfoType.statistics, InfoType.result, InfoType.notebook]
    
    lazy var expenseListViewModel: ExpenseViewModel = {
        return ExpenseViewModel()
    }()
    
    lazy var statisticsViewModel: StatisticsViewModel = {
        return StatisticsViewModel()
    }()
    
    lazy var resultViewModel: ResultViewModel = {
        return ResultViewModel()
    }()
    
    lazy var notebookViewModel: NotebookViewModel = {
        return NotebookViewModel()
    }()
    
    @IBOutlet weak var bannerView: UIView!
    
    @IBOutlet weak var bannerTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var infoTypeSelectionView: ScrollSelectionView! {
        didSet {
            infoTypeSelectionView.dataSource = self
            infoTypeSelectionView.delegate = self
        }
    }
    
    @IBOutlet weak var groupNameButton: UIButton! {
        didSet {
            groupNameButton.setImage(
                .getIcon(code: "ios-arrow-down", color: .white, size: 22),
                for: .normal
            )
            groupNameButton.setTitleColor(.white, for: .normal)
        }
    }
    
    @IBOutlet weak var settingButton: UIButton! {
        didSet {
            settingButton.setImage(
                .getIcon(from: .materialIcon, code: "more.vert", color: .white, size: 30),
                for: .normal)
            settingButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        }
    }
    
    @IBOutlet weak var infoContainer: UIScrollView! {
        didSet {
            infoContainer.delegate = self
        }
    }
    
    @IBAction func clickGroupButton(_ sender: UIButton) {
        
        let nextVC = UIStoryboard.group.instantiateInitialViewController()!
        present(nextVC, animated: true, completion: nil)
        
    }
    
    @IBAction func clickSettingButton(_ sender: UIButton) {
        
        guard let nextVC = storyboard?.instantiateViewController(withIdentifier: ModallyMeauViewController.identifier) else { return }
        nextVC.modalPresentationStyle = .overFullScreen
        present(nextVC, animated: true, completion: nil)
        
    }
    
    let stackView = UIStackView()
    
    let expenseTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.registerWithNib(indentifer: ExpenseTableViewCell.identifer)
        return tableView
    }()
    
    lazy var resultTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.registerWithNib(indentifer: ResultTableViewCell.identifer)
        return tableView
    }()
    
    lazy var statisticsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.registerWithNib(indentifer: StatisticsTableViewCell.identifer)
        return tableView
    }()
    
    lazy var notebookTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.registerWithNib(indentifer: NotebookTableViewCell.identifer)
        tableView.registerWithNib(indentifer: AddNotebookTableViewCell.identifer)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .backgroundLightGray
        bannerView.backgroundColor = .STTintColor

        setupInfoContainerView()

        // refactor
        preparePage(currnetIndex: 0)
        preparePage(currnetIndex: 1)
        preparePage(currnetIndex: 2)
        preparePage(currnetIndex: 3)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        settingButton.layer.cornerRadius = settingButton.frame.height / 2
    }
    
    deinit {
        print("Home deinit")
    }
    
    func setupInfoContainerView() {
        
        bannerView.addShadow()
        
        infoContainer.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: infoContainer.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: infoContainer.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: infoContainer.heightAnchor)
        ])
        
    }
    
    func preparePage(currnetIndex: Int) {
        
        if currnetIndex == 0 {
            stackView.addArrangedSubview(expenseTableView)
            expenseTableView.widthAnchor.constraint(equalTo: infoContainer.widthAnchor).isActive = true
            expenseTableView.dataSource = expenseListViewModel
            expenseTableView.delegate = expenseListViewModel
            expenseTableView.separatorStyle = .none
            expenseTableView.backgroundColor = .clear
            expenseListViewModel.passOffset = { [weak self] offsetY in
                let offset = min(max(offsetY, 0), 65)
                self?.groupNameButton.alpha = 1 - (offset / 65)
                self?.settingButton.alpha = 1 - (offset / 65)
                self?.bannerTopConstraint.constant = 20 - offset
                //self?.bannerView.backgroundColor = UIColor.white.withAlphaComponent((offset / 33))
                //self?.bannerView.addShadow(shadowOpacity: Float(offset / 65 * 0.2))
                self?.view.layoutIfNeeded()
            }
        }
        
        let targetIndex = currnetIndex + 1
        
        guard infoItems.count > targetIndex else { return }
        
        switch infoItems[targetIndex] {

        case .expense:  break
        case .statistics:
            stackView.addArrangedSubview(statisticsTableView)
            statisticsTableView.widthAnchor.constraint(equalTo: infoContainer.widthAnchor).isActive = true
            statisticsTableView.dataSource = statisticsViewModel
            statisticsTableView.delegate = statisticsViewModel
            statisticsTableView.separatorStyle = .none
            statisticsTableView.backgroundColor = .clear
        case .result:
            stackView.addArrangedSubview(resultTableView)
            resultTableView.widthAnchor.constraint(equalTo: infoContainer.widthAnchor).isActive = true
            resultTableView.dataSource = resultViewModel
            resultTableView.delegate = resultViewModel
            resultTableView.separatorStyle = .none
            resultTableView.backgroundColor = .clear
        case .notebook:
            stackView.addArrangedSubview(notebookTableView)
            notebookTableView.widthAnchor.constraint(equalTo: infoContainer.widthAnchor).isActive = true
            notebookTableView.dataSource = notebookViewModel
            notebookTableView.delegate = notebookViewModel
            notebookTableView.separatorStyle = .none
            notebookTableView.backgroundColor = .clear
        }
        
    }
    
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == infoContainer {
            let screenPage = Int(scrollView.contentOffset.x / UIScreen.main.bounds.width)
            
            if screenPage > infoTypeSelectionView.selectIndex {
                infoTypeSelectionView.switchIndicatorAt(index: screenPage)
                //preparePage(currnetIndex: screenPage)
            } else if screenPage < infoTypeSelectionView.selectIndex {
                infoTypeSelectionView.switchIndicatorAt(index: screenPage)
            }
        } 
        
    }
}

extension HomeViewController: ScrollSelectionViewDataSource {
    func numberOfItems(scrollSelectionView: ScrollSelectionView) -> Int {
        return infoItems.count
    }
    
    func titleForItem(scrollSelectionView: ScrollSelectionView, index: Int) -> String {
        return infoItems[index].rawValue
    }
    
}

extension HomeViewController: ScrollSelectionViewDelegate {
    func scrollSelectionView(scrollSelectionView: ScrollSelectionView, didSelectIndexAt index: Int) {
        let index = infoTypeSelectionView.selectIndex
        infoContainer.setContentOffset(CGPoint(x: index * Int(UIScreen.main.bounds.width), y: 0), animated: true)
        if (index + 1) >= stackView.subviews.count {
            //preparePage(currnetIndex: index)
        }
    }
}
