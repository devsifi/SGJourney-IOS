//
//  BusStopDetailsViewController.swift
//  SGJourney
//
//  Created by STUDENT on 30/1/18.
//  Copyright © 2018 SEG-DMIT. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BusStopDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let ADDED_TO_FAVOURITES = 2
    let REMOVE_FROM_FAVOURITES = 2
    
    let identifier = "BusServiceCell"
    
    var busStopTitle : String!
    var busStopDescription : String!
    var busStopCode : String!
    
    @IBOutlet var busStopTitleLabel: UILabel!
    @IBOutlet var busStopDescriptionLabel: UILabel!
    @IBOutlet var busStopFavouriteButton: UIButton!
    
    @IBOutlet var busServiceTableView: UITableView!
    
    var busServices = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        busStopTitleLabel?.text = busStopTitle
        busStopDescriptionLabel?.text = busStopDescription
        
        busServiceTableView.delegate = self
        busServiceTableView.dataSource = self
        
        if(BusStopFavourites.contains(busStopCode)) {
            busStopFavouriteButton.setTitle("Unfavourite", forState: .Normal)
        } else {
            busStopFavouriteButton.setTitle("Favourite", forState: .Normal)
        }
        
        refresh()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busServices.count
    }
    
    func refresh() {
        let headers = [
            "AccountKey": Config.DataMallAPI.key
        ]
        
        Alamofire.request(.GET, Config.DataMallAPI.url + "/ltaodataservice/BusArrivalv2?BusStopCode=\(busStopCode)", headers: headers)
            .responseJSON(completionHandler: { (req, resp, result) -> Void in
                if(result.isSuccess) {
                    let json = JSON(result.value!)
                    
                    self.busServices.removeAll()
                    self.busServices.appendContentsOf((json["Services"].array)!)
                    
                    self.busServiceTableView.reloadData()
                }
        })
    }
    
    @IBAction func onClickRefresh(sender: AnyObject) {
        refresh();
    }
    
    @IBAction func onClickFavourite(sender: AnyObject) {
        BusStopFavourites.addToFavourites(busStopCode)
        
        if(BusStopFavourites.contains(busStopCode)) {
            let alert = UIAlertController(title: "Added to favourites", message: "'\(busStopTitle)' has been added to favourites!",preferredStyle: .Alert)
            let okBtn = UIAlertAction(title: "Close", style: .Default, handler: nil)
            alert.addAction(okBtn)
            self.presentViewController(alert, animated: true, completion: nil)
            
            busStopFavouriteButton.setTitle("Unfavourite", forState: .Normal)
        } else {
            let alert = UIAlertController(title: "Removed from favourites", message: "'\(busStopTitle)' has been removed from favourites!",preferredStyle: .Alert)
            let okBtn = UIAlertAction(title: "Close", style: .Default, handler: nil)
            alert.addAction(okBtn)
            self.presentViewController(alert, animated: true, completion: nil)
            
            busStopFavouriteButton.setTitle("Favourite", forState: .Normal)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! BusServiceCellView
        let service = busServices[indexPath.row]
        
        print(service.rawString()!)
        
        let busArrivalETA1 = service["NextBus"]["EstimatedArrival"].stringValue
        let busArrivalETA2 = service["NextBus2"]["EstimatedArrival"].stringValue
        let busArrivalETA3 = service["NextBus3"]["EstimatedArrival"].stringValue
        
        let dateFomatter = NSDateFormatter()
        dateFomatter.timeZone = NSTimeZone(name: "UTC")
        dateFomatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        cell.serviceNoLabel?.text = service["ServiceNo"].stringValue
        cell.busETA1?.text = getBusArrivalTime(dateFomatter.dateFromString(busArrivalETA1))
        cell.busETA2?.text = getBusArrivalTime(dateFomatter.dateFromString(busArrivalETA2))
        cell.busETA3?.text = getBusArrivalTime(dateFomatter.dateFromString(busArrivalETA3))
        
        return cell
    }
    
    func getBusArrivalTime(date:NSDate!) -> String {
        if(date != nil) {
            let tmp = Int((date.timeIntervalSinceDate(NSDate())) / 60)
            if(tmp > 0) {
                return "\(tmp) mins"
            } else {
                return "Arriving"
            }
        } else {
            return ""
        }
    }
}
