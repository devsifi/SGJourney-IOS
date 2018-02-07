//
//  EditProfileViewController.swift
//  SGJourney
//
//  Created by dev on 4/2/18.
//  Copyright © 2018 SEG-DMIT. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class EditProfileViewController: UIViewController {

    @IBOutlet var EditEmailField: UITextField!
    @IBOutlet var EditNameField: UITextField!
    
    var token : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let preferences = NSUserDefaults.standardUserDefaults()
        let user = JSON.parse(preferences.stringForKey("user")!)
        
        EditEmailField.text = user["email"].stringValue
        EditNameField.text = user["name"].stringValue
        token = preferences.stringForKey("token")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickUpdateProfile(sender: AnyObject) {
        let param: [String: AnyObject] = [
            "token": token,
            "email": EditEmailField.text!,
            "name": EditNameField.text!,
        ]
        
        Alamofire.request(.PUT, Config.SGJourneyAPI() + "/account/update", parameters: param, encoding: .JSON)
            .responseJSON(completionHandler: { (req, resp, result) -> Void in
                if(result.isSuccess) {
                    let json = JSON(result.value!)
                    if json["success"] == true {
                        let preferences = NSUserDefaults.standardUserDefaults()
                        
                        preferences.setObject(json["user"].rawString(), forKey: "user")
                        preferences.synchronize()
                        
                        let alert = UIAlertController(title: "Updated Profile Successfully", message: "Profile updated successfully", preferredStyle: .Alert)
                        let okButton = UIAlertAction(title: "Ok", style: .Default, handler: {(alert: UIAlertAction!) -> Void in
                            self.navigationController?.popViewControllerAnimated(true)
                        })
                        
                        alert.addAction(okButton)
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    } else {
                        
                        var alertMessage = "Unable to update profile"
                        for message in json["messages"] {
                            alertMessage += "\n" + (message.1.string!)
                        }
                        
                        let alert = UIAlertController(title: "Update Profile Failed", message: alertMessage, preferredStyle: .Alert)
                        let okButton = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                        
                        alert.addAction(okButton)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                } else {
                    print(result.error)
                    let alert = UIAlertController(title: "Update Profile Failed", message: "Unable to connect to SGJourney Servers", preferredStyle: .Alert)
                    let okButton = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    
                    alert.addAction(okButton)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })

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
