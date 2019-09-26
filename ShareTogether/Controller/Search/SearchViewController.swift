//
//  SearchViewController.swift
//  ShareTogether
//
//  Created by littlema on 2019/8/29.
//  Copyright © 2019 littema. All rights reserved.
//

import UIKit
import MapKit

class SearchViewController: STBaseViewController {
        
    let locationManager = CLLocationManager()
    
    var viewModel = SearchViewModel()
    
    var mapView: MKMapView?
    
    var annotations = [MKPointAnnotation]() {
        willSet {
            mapView?.removeAnnotations(annotations)
        }
        didSet {
            mapView?.showAnnotations(annotations, animated: true)
        }
    }
    
    @IBOutlet weak var goSearchButton: UIButton!
    
    @IBOutlet weak var scrollSelectionView: ScrollSelectionView! {
        didSet {
            scrollSelectionView.dataSource = self
        }
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
//            tableView.dataSource = self
//            tableView.delegate = self
        }
    }
    
    @IBOutlet weak var switchTypeButton: UIButton!
    
    @IBAction func switchType(_ sender: UIButton) {
        switchType()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        mapView = MKMapView(frame: view.frame)

        view.addSubview(mapView!)
        setupMap()
        //mapView?.isHidden = true
    
//        view.bringSubviewToFront(goSearchButton)
//        view.bringSubviewToFront(switchTypeButton)
//
//        switchTypeButton.alpha = 0
//        goSearchButton.alpha = 0
//        goSearchButton.layer.borderWidth = 1.0
//        goSearchButton.layer.borderColor = UIColor.backgroundLightGray.cgColor
//        goSearchButton.clipsToBounds = true
//        goSearchButton.backgroundColor = .white
//        goSearchButton.setImage(.getIcon(code: "ios-search", color: .darkGray, size: 20), for: .normal)

        viewModel.reloadMapHandler = { [weak self] annotations in
            self?.annotations = annotations
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(upadateCurrentGroup),
                                               name: NSNotification.Name(rawValue: "CurrentGroup"),
                                               object: nil)

        upadateCurrentGroup()
        
    }

    @objc func upadateCurrentGroup() {
        viewModel.fectchData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        goSearchButton.layer.cornerRadius = goSearchButton.frame.height / 4
    }
    
    func setupMap() {
        
        mapView?.delegate = self
        mapView?.showsUserLocation = false
        mapView?.userTrackingMode = .none
        
    }
    
    func switchType() {
        if mapView!.isHidden {
            mapView?.isHidden = false
            switchTypeButton.setTitle("列表", for: .normal)
        } else {
            mapView?.isHidden = true
            switchTypeButton.setTitle("地圖", for: .normal)
        }
    }

}

//extension SearchViewController: UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return data.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: ActivityTableViewCell.identifer, for: indexPath)
//
//        guard let activityCell = cell as? ActivityTableViewCell else { return cell }
//
//        activityCell.contentLabel.text = data[indexPath.row]
//        activityCell.timeLabel.text = "2019/09/02"
//
//        return activityCell
//    }
//
//}
//
//extension SearchViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//
//}

extension SearchViewController: CLLocationManagerDelegate {
    
}

extension SearchViewController: MKMapViewDelegate {

}

extension SearchViewController: ScrollSelectionViewDataSource {
    
    func numberOfItems(scrollSelectionView: ScrollSelectionView) -> Int {
        return 10
    }
    
    func titleForItem(scrollSelectionView: ScrollSelectionView, index: Int) -> String {
        return "12345"
    }
    
    func colorOfTitleForItem(scrollSelectionView: ScrollSelectionView) -> UIColor {
        return .STTintColor
    }
    
}
