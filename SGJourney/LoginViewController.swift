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
    
    @IBAction func onClickLogin(sender: AnyObject) {
        
        let param: [String: AnyObject] = [
            "email": emailTextField.text!,
            "password": passwordTextField.text!
        ]
        
        Alamofire.request(.POST, Config.SGJourneyAPI + "/account/login", parameters: param, encoding: .JSON)
            .responseJSON(completionHandler: { (req, resp, result) -> Void in
                if(result.isSuccess) {
                    let json = JSON(result.value!)
                    if json["success"] == true {
                        let preferences = NSUserDefaults.standardUserDefaults()
                    
                        preferences.setObject(json["token"].string, forKey: "token")
                        preferences.setObject(json["user"].string, forKey: "user")
                        preferences.synchronize()
                    
                        self.performSegueWithIdentifier("login", sender: nil)
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
