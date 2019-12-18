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
// Improvement: Add UIBarButtonItem (set on NavigationItem) to open in-app Settings
class WeatherResultsViewController: UITableViewController {
    
    private var movingToViewController = false
    
    private enum WeatherTableSections: Int {
        case results = 0,
        information,
        attribution
    }
    
    private let manager = MapManager()
    // will hold to the delegate til deinit
    private let weatherMapViewDelegate = WeatherMapViewDelegate()
    
    private var viewModel = WeatherDisplayerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefresh()
        setupMapView()
        
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            }
        }
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
        // since we have no header for sections, we hardcode three sections in
        // - weather results per day time
        // - any notice of information that makes sense (out of zone, risk of ice, etc)
        // - mandatory T&C notice
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // first section has as many results as were rerieved from website
        // second section has as many results as make sense (0 to n)
        // last section has one result only
        switch section {
        case WeatherTableSections.results.rawValue, WeatherTableSections.information.rawValue:
            do {
                return try viewModel.getRows(for: section)
              } catch {
                  return 0
              }
        case WeatherTableSections.attribution.rawValue:
            // we never need more than one attrib cell
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case WeatherTableSections.results.rawValue:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.UI.WeatherPredictionsTableViewNames.weatherPredictionCellName, for: indexPath) as? WeatherPredictionCell else {
                fatalError("Programmer cast cell to incorrect type, check reusable ID \(Constants.UI.WeatherPredictionsTableViewNames.weatherPredictionCellName)")
            }
            do {
                  let cellVM = try viewModel.getCellViewModel( at: indexPath ) as? WeatherCellViewModel
                  
                  cell.textLabel?.text = cellVM?.dateTime ?? ""
                  cell.detailTextLabel?.text = cellVM?.temperature ?? ""
              } catch {
                // return cell emptied
                cell.textLabel?.text = ""
                cell.detailTextLabel?.text = ""
                return cell
              }
            return cell
        case WeatherTableSections.information.rawValue:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.UI.WeatherPredictionsTableViewNames.infoCellName, for: indexPath) as? InformationCell else {
                fatalError("Programmer cast cell to incorrect type, check reusable ID \(Constants.UI.WeatherPredictionsTableViewNames.infoCellName)")
            }
            do {
                let cellVM = try viewModel.getCellViewModel( at: indexPath ) as? InformationCellViewModel
                
                cell.textLabel?.text = cellVM?.title ?? ""
                cell.detailTextLabel?.text = cellVM?.description ?? ""
            } catch {
              // return cell emptied
              cell.textLabel?.text = ""
              cell.detailTextLabel?.text = ""
              return cell
            }
            return cell
        case WeatherTableSections.attribution.rawValue:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.UI.WeatherPredictionsTableViewNames.tAndCCellName, for: indexPath) as? AttributionCell
                else {
                    fatalError("Programmer cast cell to incorrect type, check reusable ID \(Constants.UI.WeatherPredictionsTableViewNames.tAndCCellName)")
            }
            return cell
        default:
            fatalError("Programmer updated cell types but not table view dispatch code")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // size depends on section
        switch indexPath.section {
        case WeatherTableSections.results.rawValue:
            return CGFloat(Constants.UI.WeatherPredictionsTableCells.predictionHeight)
        case WeatherTableSections.information.rawValue:
            // Improvement: make dynamic in order to display an appropriately-sized cell for the amount of information
            return CGFloat(Constants.UI.WeatherPredictionsTableCells.informationHeight)
        case WeatherTableSections.attribution.rawValue:
            return AttributionCell.cellHeight()
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case WeatherTableSections.results.rawValue:
            break
        case WeatherTableSections.information.rawValue:
            break
        case WeatherTableSections.attribution.rawValue:
            cell.backgroundView?.alpha = 0.85
            cell.alpha = 0.85
            break
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if viewModel.shouldTransition(for: indexPath) {
            return indexPath
        } else
        {
            return nil
        }
    }
    // Improvement: implement cancellable pushes
    // Attribution cells transition here
    // Information and Prediction cells transition in Will
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case WeatherTableSections.results.rawValue:
            break
        case WeatherTableSections.information.rawValue:
            break
        case WeatherTableSections.attribution.rawValue:
            movingToViewController = true
            tableView.isUserInteractionEnabled = !movingToViewController
            navigationController?.pushViewController(AttributionWebViewController(), animated: false)
            break
        default:
            break
        }
        
    }
    // UIKit is O-C mostly
    @objc private func requestDataRefresh(refreshControl: UIRefreshControl) {
        
        //            // TODO: pass action down
        //        let action = {
        //            DispatchQueue.main.async {
        //                self.refreshControl?.endRefreshing()
        //            }
        //        }
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
