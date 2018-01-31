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
    
    var nearbyBusStops = [JSON]()
    
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
        nearbyBusStopsTableView.dataSource = self
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        nearbyMapView.removeAnnotations(nearbyMapView.annotations)
        centerMapOnLocation(locations.first!)
        
        nearbyBusStops.removeAll()
        
        // Display all nearby bus stops
        for busStop in busStops.array! {
            let location = CLLocation(latitude: busStop["Latitude"].doubleValue, longitude: busStop["Longitude"].doubleValue)
            if(locations.first!.distanceFromLocation(location) <= Config.NearbyRadius) {
                nearbyBusStops.append(busStop)
            }
        }
        
        nearbyBusStops = nearbyBusStops.sort { (busStop, otherBusStop) -> Bool in
            let location = CLLocation(latitude: busStop["Latitude"].doubleValue, longitude: busStop["Longitude"].doubleValue)
            let otherLocation = CLLocation(latitude: otherBusStop["Latitude"].doubleValue, longitude: otherBusStop["Longitude"].doubleValue)
            
//            print(location.distanceFromLocation(locations[0]),otherLocation.distanceFromLocation(locations[0]))
            return location.distanceFromLocation(locations[0]) < otherLocation.distanceFromLocation(locations[0])
        }
        
        for busStop in nearbyBusStops {
            let location = CLLocation(latitude: busStop["Latitude"].doubleValue, longitude: busStop["Longitude"].doubleValue)
//            print(location.distanceFromLocation(locations[0]))
            
            let annotation = BusAnnotation()
            annotation.pin = "ic_marker_bus.png"
            annotation.coordinate = location.coordinate
            annotation.title = busStop["Description"].string!
            annotation.subtitle = "\(busStop["RoadName"].string!) (\(busStop["BusStopCode"].string!))"

            busPinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "bus_pin")
            nearbyMapView.addAnnotation(busPinAnnotation.annotation!)
        }
        
        nearbyBusStopsTableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyMapView.annotations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! BusTableViewCell
        let busStop = nearbyBusStops[indexPath.row]
        
        cell.titleLabel?.text = busStop["Description"].stringValue
        cell.descriptionLabel?.text = "\(busStop["RoadName"].string!) (\(busStop["BusStopCode"].string!))"

        return cell
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showBusStopDetails") {
            let dest = segue.destinationViewController as! BusStopDetailsViewController
            let busStop = nearbyBusStops[(nearbyBusStopsTableView.indexPathForSelectedRow?.row)!]
            dest.busStopTitle = busStop["Description"].stringValue
            dest.busStopDescription = "\(busStop["RoadName"].string!) (\(busStop["BusStopCode"].string!))"
            dest.busStopCode = busStop["BusStopCode"].stringValue
        }
    }
}