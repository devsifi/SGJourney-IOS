//
//  LoginViewController.swift
//  SGJourney
//
//  Created by student on 23/1/18.
//  Copyright © 2018 SEG-DMIT. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTriggerSecretButton(sender: AnyObject) {
        print("Opening Developer Menu")
        performSegueWithIdentifier("openDev", sender: nil)
    }
    
    @IBAction func onClickLogin(sender: AnyObject) {
        
        var param: [String: AnyObject] = [
            "email": emailTextField.text!,
            "password": passwordTextField.text!
        ]
        
        Alamofire.request(.POST, Config.SGJourneyAPI() + "/account/login", parameters: param, encoding: .JSON)
            .responseJSON(completionHandler: { (req, resp, result) -> Void in
                if(result.isSuccess) {
                    let json = JSON(result.value!)
                    if json["success"] == true {
                        let preferences = NSUserDefaults.standardUserDefaults()
                    
//                        print(json["user"])
                        
                        preferences.setObject(json["token"].stringValue, forKey: "token")
                        preferences.setObject(json["user"].rawString(), forKey: "user")
                        preferences.synchronize()
                        
                        param = [
                            "token": json["token"].stringValue
                        ]
                        
                        Alamofire.request(.POST, Config.SGJourneyAPI() + "/favourites/get", parameters: param, encoding: .JSON).responseJSON(completionHandler: { (req2, resp2, result2) -> Void in
                            if(result.isSuccess) {
                                BusStopFavourites.clear()
                                let favourites = JSON(result2.value!).arrayValue
                                for favourite in favourites {
                                    BusStopFavourites.addToFavourites(favourite["bus_stop_code"].stringValue)
                                }
                            }
                            
                            self.performSegueWithIdentifier("processLogin", sender: nil)
                        })
                    } else {
                        let alert = UIAlertController(title: "Login Failed", message: json["messages"][0].string, preferredStyle: .Alert)
                        let okButton = UIAlertAction(title: "Ok", style: .Default, handler: nil)

                        alert.addAction(okButton)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                } else {
                    print(result.error)
                    let alert = UIAlertController(title: "Login Failed", message: "Unable to connect to SGJourney Servers", preferredStyle: .Alert)
                    let okButton = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    
                    alert.addAction(okButton)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "register" {
            let controller = segue.destinationViewController as! RegisterViewController
            controller.segueEmail = emailTextField.text
            controller.seguePassword = passwordTextField.text
        }
    }
}
