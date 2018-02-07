import UIKit

class Config {
    static func SGJourneyAPI () -> String {
        let preferences = NSUserDefaults.standardUserDefaults()
        
        if let api = preferences.stringForKey("SGJourneyAPI") {
            print(api)
            return api
        } else {
            return "http://172.27.153.9:3000"
        }
    }
}