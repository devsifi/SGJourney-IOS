//
//  ContactViewController.swift
//  SGJourney
//
//  Created by dev on 4/2/18.
//  Copyright © 2018 SEG-DMIT. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {

    let contactNo = "64515115"
    let email = "152819F@mymail.nyp.edu.sg"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickCall(sender: AnyObject) {
        if let url = NSURL(string: "tel://\(contactNo)") where UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func onClickEmail(sender: AnyObject) {
        if let url = NSURL(string: "mailto:\(email)") where UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
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
