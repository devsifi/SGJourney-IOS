//
//  BusTableViewCell.swift
//  SGJourney
//
//  Created by student on 28/1/18.
//  Copyright © 2018 SEG-DMIT. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FontAwesomeKit

class BusTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var favouriteButton: UIButton!
    
    var viewController : UIViewController!
    var busStopTitle : String!
    var busStopDescription : String!
    var busStopCode : String!
    var icon = FAKFontAwesome.heartIconWithSize(24)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //update()
        self.favouriteButton.addTarget(self, action: "toggleFavourite", forControlEvents: .TouchUpInside)
    }
    
    func toggleFavourite() {
        BusStopFavourites.addToFavourites(busStopCode)
        
        let preferences = NSUserDefaults.standardUserDefaults()
        let token = preferences.stringForKey("token")
        let parameters : [String:AnyObject]? = [
            "token": token!,
            "busStopCode" : busStopCode!
        ]
        
        if(BusStopFavourites.contains(busStopCode!)) {
            
            Alamofire.request(.POST, Config.SGJourneyAPI + "/favourites/add", parameters: parameters, encoding: .JSON).responseJSON(completionHandler: { (
                req, resp, result) -> Void in
                if(!result.isSuccess || !JSON(result.value!)["success"].boolValue) {
                    let alert = UIAlertController(title: "Something went wrong", message: "Unable to add '\(self.busStopTitle)' to favourites!",preferredStyle: .Alert)
                    let okBtn = UIAlertAction(title: "Close", style: .Default, handler: nil)
                    alert.addAction(okBtn)
                    self.viewController.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Added to favourites", message: "'\(self.busStopTitle)' has been added to favourites!",preferredStyle: .Alert)
                    let okBtn = UIAlertAction(title: "Close", style: .Default, handler: nil)
                    alert.addAction(okBtn)
                    self.viewController.presentViewController(alert, animated: true, completion: nil)
                    self.update()
                }
            });
            
        } else {
            Alamofire.request(.POST, Config.SGJourneyAPI + "/favourites/remove", parameters: parameters, encoding: .JSON).responseJSON(completionHandler: { (
                req, resp, result) -> Void in
                if(!result.isSuccess || !JSON(result.value!)["success"].boolValue) {
                    let alert = UIAlertController(title: "Something went wrong", message: "Unable to remove '\(self.busStopTitle)' from favourites!",preferredStyle: .Alert)
                    let okBtn = UIAlertAction(title: "Close", style: .Default, handler: nil)
                    alert.addAction(okBtn)
                    self.viewController.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Removed to favourites", message: "'\(self.busStopTitle)' has been removed from favourites!",preferredStyle: .Alert)
                    let okBtn = UIAlertAction(title: "Close", style: .Default, handler: nil)
                    alert.addAction(okBtn)
                    self.viewController.presentViewController(alert, animated: true, completion: nil)
                    self.update()
                }
            })
        }
    }
    
    func update() {
        if(BusStopFavourites.contains(busStopCode!)) {
            icon.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex:"#BC6873"))
        } else {
            icon.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor())
        }
        
        favouriteButton.setAttributedTitle(icon.attributedString(), forState: .Normal)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
