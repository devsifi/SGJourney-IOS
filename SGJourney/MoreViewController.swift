//
//  MoreViewController.swift
//  SGJourney
//
//  Created by dev on 4/2/18.
//  Copyright © 2018 SEG-DMIT. All rights reserved.
//

import UIKit
import SwiftyJSON

class MoreViewController: UIViewController {

    @IBOutlet var UserNameLabel: UILabel!
    @IBOutlet var UserEmailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let preference = NSUserDefaults.standardUserDefaults()
        
        if let userRaw = preference.stringForKey("user") {
            let user = JSON.parse(userRaw)
            UserNameLabel.text = user["name"].stringValue
            UserEmailLabel.text = user["email"].stringValue
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickLogout(sender: AnyObject) {
//        if let bid = NSBundle.mainBundle().bundleIdentifier {
//            NSUserDefaults.standardUserDefaults().removePersistentDomainForName(bid)
//            self.performSegueWithIdentifier("login", sender: nil)
//        }
        
        let preferences = NSUserDefaults.standardUserDefaults()
        preferences.removeObjectForKey("token")
        preferences.removeObjectForKey("user")
        
        self.performSegueWithIdentifier("login", sender: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
