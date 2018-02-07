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
    
    @IBAction func onTriggerSecretButton(sender: AnyObject) {
        print("Opening Developer Menu")
        performSegueWithIdentifier("openDev", sender: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func proceed() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let preferences = NSUserDefaults.standardUserDefaults()
            if preferences.objectForKey("token") != nil {
                self.performSegueWithIdentifier("gotoMain", sender: nil)
            } else {
                self.performSegueWithIdentifier("gotoLogin", sender: nil)
            }
            
        })
        
        let preferences = NSUserDefaults.standardUserDefaults()
        if preferences.objectForKey("token") != nil {
            self.performSegueWithIdentifier("gotoMain", sender: nil)
        } else {
            self.performSegueWithIdentifier("gotoLogin", sender: nil)
        }
    }
    
    func process() {
        
        //Alamofire.request(.GET, Config.SGJourneyAPI2) // Wake server up (Heroku)
        
        let preferences = NSUserDefaults.standardUserDefaults()
        if let token = preferences.stringForKey("token") {
            let param = [
                "token": token
            ]
        
            Alamofire.request(.POST, Config.SGJourneyAPI() + "/favourites/get", parameters: param, encoding: .JSON).validate().responseJSON(completionHandler: { (req, resp, result) -> Void in
                if(result.isSuccess) {
                    BusStopFavourites.clear()
                    let favourites = JSON(result.value!)["favourites"].arrayValue
                    for favourite in favourites {
                        BusStopFavourites.addToFavourites(favourite["bus_stop_code"].stringValue)
                    }
                }
                
                self.proceed()
            })
        } else {
            self.proceed()
        }
    }
}