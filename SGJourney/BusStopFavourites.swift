//
//  BusStopFavourites.swift
//  SGJourney
//
//  Created by STUDENT on 30/1/18.
//  Copyright © 2018 SEG-DMIT. All rights reserved.
//

import UIKit

class BusStopFavourites: NSObject {
    
    static func getFavourites() -> [String] {
        let preferences = NSUserDefaults.standardUserDefaults()
        var favourites = [String]()
        
        if let savedFavourites = preferences.stringArrayForKey("favourites") {
            favourites.appendContentsOf(savedFavourites)
        }
        
        return favourites
    }
    
    static func addToFavourites(busStop:String){
        var favourites = getFavourites()
        let index = _contains(busStop)
        
        if(index >= 0) {
            favourites.removeAtIndex(index)
        } else {
            favourites.append(busStop)
        }
        
        let preferences = NSUserDefaults.standardUserDefaults()
        preferences.setObject(favourites, forKey: "favourites")
        
    }
    
    static func contains(busStopCode:String) -> Bool {
        return _contains(busStopCode) >= 0
    }
    
    static func _contains(busStopCode:String) -> Int {
        let favourites = getFavourites()
        
        for var i = 0; i < favourites.count; i++ {
            if favourites[i] == busStopCode { return i }
        }
        
        return -1
    }
}
