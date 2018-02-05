//
//  SearchViewController.swift
//  SGJourney
//
//  Created by STUDENT on 30/1/18.
//  Copyright © 2018 SEG-DMIT. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var searchTextField: UITextField!
    
    @IBOutlet var searchTableView: UITableView!
    
    var searchResults = [JSON]()
//    var busStops : JSON! = {
//        let preferences = NSUserDefaults.standardUserDefaults()
//        return JSON(preferences.valueForKey("bus_stops")!)
//    }()
//    var busRoutes : JSON! = {
//        let preferences = NSUserDefaults.standardUserDefaults()
//        return JSON(preferences.valueForKey("bus_routes")!)
//    }()
    
    @IBAction func onClickSearch(sender: AnyObject) {
        if let query = searchTextField.text?.lowercaseString {
            searchResults.removeAll()
            
            let parameters = [
                "search" : query
            ]
            
            Alamofire.request(.GET, Config.SGJourneyAPI2 + "/bus/stops", parameters: parameters).responseJSON(completionHandler: { (req, resp, results) -> Void in
                if(results.isSuccess) {
                    let json = JSON(results.value!).arrayValue
                    self.searchResults.appendContentsOf(json)
                }
                self.searchTableView.reloadData()
            })
            
//            for busStop in busStops.array! {
//                if(busStop["BusStopCode"].stringValue == query) {
//                    searchResults.append(busStop)
//                } else if (busStop["RoadName"].stringValue.lowercaseString.containsString(query)){
//                    searchResults.append(busStop)
//                } else if (busStop["Description"].stringValue.lowercaseString.containsString(query)){
//                    searchResults.append(busStop)
//                }
//            }
//            
////            print(busRoutes.rawString())
//            for busRoute in busRoutes.array! {
//                print("Service No: \(busRoute["ServiceNo"].stringValue), Query: \(query)")
//                if(busRoute["ServiceNo"].stringValue == query) {
//                    for busStop in busStops.array! {
//                        if(busStop["BusStopCode"].stringValue == busRoute["BusStopCode"].stringValue) {
//                            searchResults.append(busStop)
//                            break
//                        }
//                    }
//                }
//            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        searchResults.removeAll()
        searchTableView.delegate = self
        searchTableView.dataSource = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! BusTableViewCell
        let busStop = searchResults[indexPath.row]
        
        cell.titleLabel?.text = busStop["Description"].stringValue
        cell.descriptionLabel?.text = "\(busStop["RoadName"].string!) (\(busStop["BusStopCode"].string!))"
        
        return cell
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showBusStopDetails") {
            let dest = segue.destinationViewController as! BusStopDetailsViewController
            let busStop = searchResults[(searchTableView.indexPathForSelectedRow?.row)!]
            dest.busStopTitle = busStop["Description"].stringValue
            dest.busStopDescription = "\(busStop["RoadName"].string!) (\(busStop["BusStopCode"].string!))"
            dest.busStopCode = busStop["BusStopCode"].stringValue
        }
    }

}
