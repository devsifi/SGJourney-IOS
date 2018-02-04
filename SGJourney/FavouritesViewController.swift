//
//  FavouritesViewController.swift
//  SGJourney
//
//  Created by STUDENT on 30/1/18.
//  Copyright © 2018 SEG-DMIT. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class FavouritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var favouritesTableView: UITableView!
    
    var favouriteBusStops = [JSON]()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        favouritesTableView.delegate = self
        favouritesTableView.dataSource = self
        
        Alamofire.request(.GET, Config.SGJourneyAPI2 + "/bus/stops").responseJSON { (req, resp, result) -> Void in
            if(result.isSuccess) {
                let json = JSON(result.value!).arrayValue
                self.favouriteBusStops.removeAll()
                let favourites = BusStopFavourites.getFavourites()
                for busStop in json {
                    for favourite in favourites {
                        if(busStop["BusStopCode"].stringValue == favourite) {
                            self.favouriteBusStops.append(busStop)
                        }

                    }
                }
                
                self.favouritesTableView.reloadData()
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteBusStops.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! BusTableViewCell
        let busStop = favouriteBusStops[indexPath.row]
        
        cell.titleLabel?.text = busStop["Description"].stringValue
        cell.descriptionLabel?.text = "\(busStop["RoadName"].string!) (\(busStop["BusStopCode"].string!))"
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "viewBusStopDetails") {
            let dest = segue.destinationViewController as! BusStopDetailsViewController
            let busStop = favouriteBusStops[(favouritesTableView.indexPathForSelectedRow?.row)!]
            dest.busStopTitle = busStop["Description"].stringValue
            dest.busStopDescription = "\(busStop["RoadName"].string!) (\(busStop["BusStopCode"].string!))"
            dest.busStopCode = busStop["BusStopCode"].stringValue
        }
    }
}
