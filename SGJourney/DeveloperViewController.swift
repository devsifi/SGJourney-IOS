//
//  DeveloperViewController.swift
//  SGJourney
//
//  Created by STUDENT on 7/2/18.
//  Copyright © 2018 SEG-DMIT. All rights reserved.
//

import UIKit

class DeveloperViewController: UIViewController {

    @IBOutlet var sgJourneyUrlTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let preferences = NSUserDefaults.standardUserDefaults()
        if let url = preferences.stringForKey("SGJourneyAPI") {
            sgJourneyUrlTextField.text = url
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickSave(sender: AnyObject) {
        let preferences = NSUserDefaults.standardUserDefaults()
        
        if let url = sgJourneyUrlTextField.text {
            preferences.setObject(url, forKey: "SGJourneyAPI")
        }
        
        if let navController = navigationController {
            navController.popToRootViewControllerAnimated(true)
        } else {
            performSegueWithIdentifier("restartApp", sender: nil)
        }
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
