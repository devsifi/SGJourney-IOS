//
//  SplashScreenViewController.swift
//  SGJourney
//
//  Created by student on 23/1/18.
//  Copyright © 2018 SEG-DMIT. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SplashScreenViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Launching SGJourney")
        
        // Do any additional setup after loading the view.
        process()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func proceed() {
        let preferences = NSUserDefaults.standardUserDefaults()
        
        if preferences.objectForKey("token") != nil {
            self.performSegueWithIdentifier("gotoMain", sender: nil)
        } else {
            self.performSegueWithIdentifier("gotoLogin", sender: nil)
        }
    }
    
    func process() {
        
        Alamofire.request(.GET, Config.SGJourneyAPI2) // Wake server up (Heroku)
        
        let preferences = NSUserDefaults.standardUserDefaults()
        if let token = preferences.stringForKey("token") {
            let param = [
                "token": token
            ]
        
            Alamofire.request(.POST, Config.SGJourneyAPI + "/favourites/get", parameters: param, encoding: .JSON).responseJSON(completionHandler: { (req, resp, result) -> Void in
                if(result.isSuccess) {
                    BusStopFavourites.clear()
                    let favourites = JSON(result.value!)["favourites"].arrayValue
                    for favourite in favourites {
                        BusStopFavourites.addToFavourites(favourite["bus_stop_code"].stringValue)
                    }
                }
                
                let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 3 * Int64(NSEC_PER_SEC))
                dispatch_after(time, dispatch_get_main_queue()) {
                    self.proceed()
                }
            })
        } else {
            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 3 * Int64(NSEC_PER_SEC))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.proceed()
            }
        }
        
        // Retrieve Data from DataMall API
        /*
        let preferences = NSUserDefaults.standardUserDefaults()
        self.getBusStop({ (busStops) -> Void in
            self.getBusStop({ (busStops) -> Void in })
            var tmp = [AnyObject]()
            
            for busStop in busStops {
                tmp += busStop.arrayObject!
            }
            
            preferences.setObject(tmp, forKey: "bus_stops")
            
            self.getBusRoute({ (busRoutes) -> Void in
                var tmp2 = [AnyObject]()
                
                for busRoute in busRoutes {
                    tmp2 += busRoute.arrayObject!
                }
                
                let date = NSDate()
                
                preferences.setObject(tmp2, forKey: "bus_routes")
                preferences.setObject(date, forKey: "last_updated")
                
                self.proceed()
            })
        })
        */
    }

    /*
    func getBusStop(completionHandler: ((busStops: [JSON]) -> Void)) {
        self.getBusStop(0, busStops: nil, completionHandler: completionHandler)
    }
    
    func getBusStop(skip:Int, busStops:[JSON]?, completionHandler: ((busStops: [JSON]) -> Void)) {
        
        var arr:[JSON]
        
        if(busStops == nil) {
            arr = [JSON]()
        } else {
            arr = busStops!
        }
        
        let headers = [
            "AccountKey": Config.DataMallAPI.key
        ]
        
        Alamofire.request(.GET, Config.DataMallAPI.url + "/ltaodataservice/BusStops?$skip=\(skip)", headers: headers)
            .responseJSON(completionHandler: { (req, resp, result) -> Void in
                if(result.isSuccess) {
                    let json = JSON(result.value!)
                    arr.append(json["value"])
                    
                    print("SGJourney: Bus Stop Count: \(json["value"].count)")
                    
                    if(json["value"].count != 500) {
                        completionHandler(busStops: arr)
                    } else {
                        self.getBusStop(skip + 500, busStops: arr, completionHandler: completionHandler)
                    }
                } else {
                    print(result.error)
                    let alert = UIAlertController(title: "Error", message: "Unable to retrieve Bus Stop Information", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
    }
    
    func getBusRoute(completionHandler: ((busRoutes: [JSON]) -> Void)) {
        self.getBusRoute(0, busRoutes: nil, completionHandler: completionHandler)
    }
    
    func getBusRoute(skip:Int, busRoutes:[JSON]?, completionHandler: ((busRoutes: [JSON]) -> Void)) {
        
        var arr:[JSON]
        
        if(busRoutes == nil) {
            arr = [JSON]()
        } else {
            arr = busRoutes!
        }
        
        let headers = [
            "AccountKey": Config.DataMallAPI.key
        ]
        
        Alamofire.request(.GET, Config.DataMallAPI.url + "/ltaodataservice/BusRoutes?$skip=\(skip)", headers: headers)
            .responseJSON(completionHandler: { (req, resp, result) -> Void in
                if(result.isSuccess) {
                    let json = JSON(result.value!)
                    arr.append(json["value"])
                    
                    print("SGJourney: Bus Route Count: \(json["value"].count)")
                    
                    if(json["value"].count != 500) {
//                        print(json["value"])
                        completionHandler(busRoutes: arr)
                    } else {
                        self.getBusRoute(skip + 500, busRoutes: arr, completionHandler: completionHandler)
                    }
                } else {
                    print(result.error)
                    let alert = UIAlertController(title: "Error", message: "Unable to retrieve Bus Route Information", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
    }
    */
}