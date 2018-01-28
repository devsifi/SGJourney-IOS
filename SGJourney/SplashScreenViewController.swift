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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let preferences = NSUserDefaults.standardUserDefaults()
        
        // Retrieve Data from DataMall API
        getBusStop({ (busStops) -> Void in
            
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
                
                preferences.setObject(tmp, forKey: "bus_routes")
                preferences.setObject(date, forKey: "last_updated")
                
                print(date)
                
                if preferences.objectForKey("token") != nil {
                    self.performSegueWithIdentifier("gotoMain", sender: nil)
                } else {
                    self.performSegueWithIdentifier("gotoLogin", sender: nil)
                }
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    func getBusRoute(skip:Int, busRoutes:[JSON]?, completionHandler: ((busStops: [JSON]) -> Void)) {
        
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
                        completionHandler(busStops: arr)
                    } else {
                        self.getBusStop(skip + 500, busStops: arr, completionHandler: completionHandler)
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
}