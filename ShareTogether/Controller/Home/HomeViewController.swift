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
    
    let infoItems: [InfoType] = [.expense, .statistics, .result, .notebook]
    
    var currentGroup: UserGroup?
    
    lazy var notebookViewModel: NotebookViewModel = {
        return NotebookViewModel()
    }()
    
    @IBOutlet weak var bannerView: UIView!
    
    @IBOutlet weak var bannerTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var infoTypeSelectionView: ScrollSelectionView!
    
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
        
    @IBOutlet weak var infoContainer: UIScrollView!
    
    @IBAction func clickGroupButton(_ sender: UIButton) {
        
        let nextVC = UIStoryboard.group.instantiateInitialViewController()!
        present(nextVC, animated: true, completion: nil)
        
    }
    
    @IBAction func clickSettingButton(_ sender: UIButton) {
        
        guard let nextVC = storyboard?.instantiateViewController(withIdentifier: ModallyMeauViewController.identifier)
        else { return }
        
        nextVC.modalPresentationStyle = .overFullScreen
        present(nextVC, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .backgroundLightGray
        bannerView.addShadow()
        bannerView.backgroundColor = .STTintColor
        
        infoContainer.delegate = self
        
        infoTypeSelectionView.dataSource = self
        infoTypeSelectionView.delegate = self
        
        currentGroup = UserInfoManager.shaered.currentGroup
        
        groupNameButton.setTitle(currentGroup?.name, for: .normal)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        settingButton.layer.cornerRadius = settingButton.frame.height / 2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let expenseVC = segue.destination as? ExpenseTableViewController {
            expenseVC.delegate = self
        } else if let statisticsVC = segue.destination as? StatisticsTableViewController {
            statisticsVC.delegate = self
        } else if let resultVC = segue.destination as? ResultTableViewController {
            resultVC.delegate = self
        } else if let notebookVC = segue.destination as? NotebookTableViewController {
            notebookVC.delegate = self
        }
    }
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let screenPage = Int(scrollView.contentOffset.x / UIScreen.main.bounds.width)
        
        if screenPage > infoTypeSelectionView.selectIndex {
            infoTypeSelectionView.switchIndicatorAt(index: screenPage)
        } else if screenPage < infoTypeSelectionView.selectIndex {
            infoTypeSelectionView.switchIndicatorAt(index: screenPage)
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
    }
}

extension HomeViewController: TableViewControllerDelegate {
    
    func tableViewDidScroll(viewController: UITableViewController, offsetY: CGFloat) {
        let offset = min(max(offsetY, 0), 65)
    
        groupNameButton.alpha = 1 - (offset / 65)
        settingButton.alpha = 1 - (offset / 65)
        bannerTopConstraint.constant = 20 - offset
        view.layoutIfNeeded()
    }

}