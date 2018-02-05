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
import FontAwesomeKit

class BusStopDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let favouriteIcon = FAKFontAwesome.heartIconWithSize(24)
    
    let identifier = "BusServiceCell"
    
    var busStopTitle : String!
    var busStopDescription : String!
    var busStopCode : String!
    
    @IBOutlet var busStopTitleLabel: UILabel!
    @IBOutlet var busStopDescriptionLabel: UILabel!
    @IBOutlet var busStopFavouriteButton: UIButton!
    @IBOutlet var busStopRefreshButton: UIButton!
    
    @IBOutlet var busServiceTableView: UITableView!
    
    var busServices = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        busStopTitleLabel?.text = busStopTitle
        busStopDescriptionLabel?.text = busStopDescription
        
        busServiceTableView.delegate = self
        busServiceTableView.dataSource = self
        
        let refreshButton = FAKFontAwesome.refreshIconWithSize(24)
        refreshButton.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGrayColor())
        busStopRefreshButton.setAttributedTitle(refreshButton.attributedString(), forState: .Normal)
        
        updateFavouriteButton()
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
        
        Alamofire.request(.GET, Config.SGJourneyAPI2 + "/bus/arrival?id=\(busStopCode)", headers: headers)
            .responseJSON(completionHandler: { (req, resp, result) -> Void in
                if(result.isSuccess) {
                    let json = JSON(result.value!)
                    
                    self.busServices.removeAll()
                    self.busServices.appendContentsOf(json.arrayValue)
                    
                    self.busServiceTableView.reloadData()
                }
        })
    }
    
    func updateFavouriteButton() {
        if(BusStopFavourites.contains(busStopCode)) {
            favouriteIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex: "#BC6873"))
            busStopFavouriteButton.setAttributedTitle(favouriteIcon.attributedString(), forState: .Normal)
        } else {
            favouriteIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor())
            busStopFavouriteButton.setAttributedTitle(favouriteIcon.attributedString(), forState: .Normal)
        }
    }
    
    @IBAction func onClickRefresh(sender: AnyObject) {
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
                rotation.toValue = M_PI * 2
                rotation.duration = 0.66
                rotation.cumulative = true
                rotation.repeatCount = 2
                self.busStopRefreshButton.layer.addAnimation(rotation, forKey: "rotateAnimation")
            }) { (bool) -> Void in
                self.refresh()
            }
//        refresh();
    }
    
    @IBAction func onClickFavourite(sender: AnyObject) {
        BusStopFavourites.addToFavourites(busStopCode)
        let preferences = NSUserDefaults.standardUserDefaults()
        let token = preferences.stringForKey("token")
        let parameters = [
            "token": token,
            "busStopCode" : busStopCode
        ]
        
        if(BusStopFavourites.contains(busStopCode)) {
            
            Alamofire.request(.POST, Config.SGJourneyAPI + "/favourites/add", parameters: parameters, encoding: .JSON).responseJSON(completionHandler: { (
                req, resp, result) -> Void in
                if(!result.isSuccess || !JSON(result.value!)["success"].boolValue) {
                    let alert = UIAlertController(title: "Something went wrong", message: "Unable to add '\(self.busStopTitle)' to favourites!",preferredStyle: .Alert)
                    let okBtn = UIAlertAction(title: "Close", style: .Default, handler: nil)
                    alert.addAction(okBtn)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Added to favourites", message: "'\(self.busStopTitle)' has been added to favourites!",preferredStyle: .Alert)
                    let okBtn = UIAlertAction(title: "Close", style: .Default, handler: nil)
                    alert.addAction(okBtn)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    self.updateFavouriteButton()
                }
            });
            
            } else {
                Alamofire.request(.POST, Config.SGJourneyAPI + "/favourites/remove", parameters: parameters, encoding: .JSON).responseJSON(completionHandler: { (
                req, resp, result) -> Void in
                    if(!result.isSuccess || !JSON(result.value!)["success"].boolValue) {
                        let alert = UIAlertController(title: "Something went wrong", message: "Unable to remove '\(self.busStopTitle)' from favourites!",preferredStyle: .Alert)
                        let okBtn = UIAlertAction(title: "Close", style: .Default, handler: nil)
                        alert.addAction(okBtn)
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: "Removed to favourites", message: "'\(self.busStopTitle)' has been removed from favourites!",preferredStyle: .Alert)
                        let okBtn = UIAlertAction(title: "Close", style: .Default, handler: nil)
                        alert.addAction(okBtn)
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.updateFavouriteButton()
                    }
                });
            }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! BusServiceCellView
        let service = busServices[indexPath.row]
        
        let busArrival1 = service["NextBus"]
        let busArrival2 = service["NextBus2"]
        let busArrival3 = service["NextBus3"]
        
        let busArrivalETA1 = busArrival1["EstimatedArrival"].stringValue
        let busArrivalETA2 = busArrival2["EstimatedArrival"].stringValue
        let busArrivalETA3 = busArrival3["EstimatedArrival"].stringValue
        
        let dateFomatter = NSDateFormatter()
        dateFomatter.timeZone = NSTimeZone(name: "UTC")
        dateFomatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        cell.serviceNoLabel?.text = service["ServiceNo"].stringValue
        cell.busETA1?.text = getBusArrivalTime(dateFomatter.dateFromString(busArrivalETA1))
        cell.busETA2?.text = getBusArrivalTime(dateFomatter.dateFromString(busArrivalETA2))
        cell.busETA3?.text = getBusArrivalTime(dateFomatter.dateFromString(busArrivalETA3))
        
        cell.busETA1?.textColor = getLoadColor(busArrival1["Load"].stringValue)
        cell.busETA2?.textColor = getLoadColor(busArrival2["Load"].stringValue)
        cell.busETA3?.textColor = getLoadColor(busArrival3["Load"].stringValue)
        
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
    
    func getLoadColor(load:String) -> UIColor {
        
        let full = UIColor(hex: "#6E2A33")
        let limited = UIColor(hex: "#C7AB87")
        let empty = UIColor(hex: "#6E7560")
        
        switch (load) {
        case "SDA":
            return limited
            case "LSD":
                return full
        case "SEA":
            return empty
        default:
            return empty
        }
    }
}