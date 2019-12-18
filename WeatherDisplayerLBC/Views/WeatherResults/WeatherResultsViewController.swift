//
//  WeatherResultsViewController.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 17/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import UIKit
import MapKit
import SwiftyDrop


// Improvement: use CLGeocoder to reverse-geocode the location, and display it as an info cell
// Improvement: Add slide-to-remove on info cells [requires keeping track of what information was hidden]
class WeatherResultsViewController: UITableViewController {
    
    private var movingToViewController = false

    private let manager = MapManager()
    // will hold to the delegate til deinit
    private let weatherMapViewDelegate = WeatherMapViewDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefresh()
        setupMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Predictions"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Got it", style: .done, target: nil, action: nil)
        movingToViewController = false
        tableView?.isUserInteractionEnabled = !movingToViewController
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // we have between 2 and 3 sections active
        // - weather results per day time
        // - any notice of information that makes sense (out of zone, risk of ice, etc)
        // - mandatory T&C notice
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // first section has as many results as were rerieved from website
        // second section has as many results as make sense (0 to n)
        // last section has one result only
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.UI.WeatherPredictionsTableViewNames.tAndCCellName, for: indexPath) as? AttributionCell
        // TODO: build something more elegant
        cell?.textLabel?.text = "www.infoclimat.fr"
        cell?.textLabel?.textAlignment = .center
        // only for T&C and information cells
        cell?.selectionStyle = .none
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            movingToViewController = true
            tableView.isUserInteractionEnabled = !movingToViewController
            // improvement: implement cancellable pushes
            navigationController?.pushViewController(AttributionWebViewController(), animated: false)
        }
    }
    // UIKit is O-C mostly
    @objc private func requestDataRefresh(refreshControl: UIRefreshControl) {
            Drop.down("lol")
            // TODO: decide if I end refreshing now or if I wait for data return
            refreshControl.endRefreshing()
    }
    
    private func setupMapView() {
        let mapView = MKMapView()
        // initially centered on my house, improvement: bind the user location and center the map on known last location
        // maybe use the CoreLocation feature that does just that ;)
        mapView.setRegion(MKCoordinateRegion(center:
            CLLocationCoordinate2D(latitude: 50.640364,
                                   longitude: 3.062058),
                                             latitudinalMeters: Constants.UI.Map.latitudinalMeters,
                                             longitudinalMeters: Constants.UI.Map.longitudinalMeters), animated: true)
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.delegate = weatherMapViewDelegate
        // Note: we don't need a MKMapViewDelegate since we don't intend to set annotations
        // we do need CLLocationManagerDelegate and CLLocationManager
        tableView.backgroundView = mapView
    }
    
    private func setupRefresh() {

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(requestDataRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
}
