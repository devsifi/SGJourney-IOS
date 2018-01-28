//
//  RegisterViewController.swift
//  SGJourney
//
//  Created by student on 23/1/18.
//  Copyright © 2018 SEG-DMIT. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RegisterViewController: UIViewController {
    
    var segueEmail : String?
    var seguePassword : String?
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    
    @IBAction func onClickRegister(sender: AnyObject) {
        let param: [String: AnyObject] = [
            "email": emailTextField.text!,
            "password": passwordTextField.text!,
            "name":  nameTextField.text!
        ]
        
        Alamofire.request(.POST, Config.SGJourneyAPI + "/account/register", parameters: param, encoding: .JSON)
            .responseJSON(completionHandler: { (req, resp, result) -> Void in
                if(result.isSuccess) {
                    let json = JSON(result.value!)
                    if json["success"] == true {
                        let preferences = NSUserDefaults.standardUserDefaults()
                        
                        preferences.setObject(json["token"].string, forKey: "token")
                        preferences.setObject(json["user"].string, forKey: "user")
                        preferences.synchronize()
                        
                        self.performSegueWithIdentifier("gotoMain", sender: nil)
                    } else {
                        
                        var alertMessage = "Unable to register user"
                        for message in json["messages"] {
                            alertMessage += "\n" + (message.1.string!)
                        }
                        
                        let alert = UIAlertController(title: "Registration Failed", message: alertMessage, preferredStyle: .Alert)
                        let okButton = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                        
                        alert.addAction(okButton)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                } else {
                    print(result.error)
                    let alert = UIAlertController(title: "Registration Failed", message: "Unable to connect to SGJourney Servers", preferredStyle: .Alert)
                    let okButton = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    
                    alert.addAction(okButton)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if segueEmail != nil {
            emailTextField.text = segueEmail!
        }
        
        if seguePassword != nil {
            passwordTextField.text = seguePassword!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
