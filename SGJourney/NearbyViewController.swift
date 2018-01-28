//
//  NearbyViewController.swift
//  SGJourney
//
//  Created by STUDENT on 10/1/18.
//  Copyright © 2018 SEG-DMIT. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class NearbyViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var nearbyMapView: MKMapView!
    @IBOutlet var nearbyBusStopsTableView: UITableView!
    
    var locationManager : CLLocationManager = CLLocationManager()
    lazy var busStops : JSON! = {
        let preferences = NSUserDefaults.standardUserDefaults()
        return JSON(preferences.valueForKey("bus_stops")!)
    }()
    
    var busPinAnnotation : MKPinAnnotationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        nearbyMapView.delegate = self
        nearbyBusStopsTableView.delegate = self
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        nearbyMapView.removeAnnotations(nearbyMapView.annotations)
        centerMapOnLocation(locations.first!)
        
        // Display all nearby bus stops
        for busStop in busStops.array! {
//            CLLocation.init(latitude: <#T##CLLocationDegrees#>, longitude: <#T##CLLocationDegrees#>)
            let location = CLLocation(latitude: busStop["Latitude"].doubleValue, longitude: busStop["Longitude"].doubleValue)
            if(locations.first!.distanceFromLocation(location) <= Config.NearbyRadius) {
                let annotation = BusAnnotation()
                annotation.pin = "ic_marker_bus.png"
                annotation.coordinate = location.coordinate
                annotation.title = busStop["Description"].string!
                annotation.subtitle = "\(busStop["RoadName"].string!) (\(busStop["BusStopCode"].string!))"
//                annotation.setValue(busStop.string, forKey: "bus_stop")
                
                busPinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "bus_pin")
                nearbyMapView.addAnnotation(busPinAnnotation.annotation!)
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyMapView.annotations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        
        cell?.textLabel?.text = nearbyMapView.annotations[indexPath.row].title!
        
        return cell!
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "bus_pin"
        var annotationView = nearbyMapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        let busAnnotation = annotation as! BusAnnotation
        let pinImage = UIImage(named: busAnnotation.pin)
        let pinSize = CGSize(width: 20, height: 20)
        
        UIGraphicsBeginImageContext(pinSize)
        pinImage!.drawInRect(CGRectMake(0, 0, pinSize.width, pinSize.height))
        let resizedPinImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        annotationView?.image = resizedPinImage
        return annotationView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centerMapOnLocation(location: CLLocation)
    {
        let regionRadius: CLLocationDistance = 600
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        nearbyMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // TODO: Throw an alert message that the app requires location services otherwise the view will not function
    }
}