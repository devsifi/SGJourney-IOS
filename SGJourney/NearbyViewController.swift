//
//  NearbyViewController.swift
//  SGJourney
//
//  Created by STUDENT on 10/1/18.
//  Copyright © 2018 SEG-DMIT. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import FontAwesomeKit

class NearbyViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var mapRefreshButton: UIButton!
    @IBOutlet var nearbyMapView: MKMapView!
    @IBOutlet var nearbyBusStopsTableView: UITableView!
    
    var nearbyBusStops = [JSON]()
    var locationManager : CLLocationManager = CLLocationManager()
    var busPinAnnotation : MKPinAnnotationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        nearbyMapView.delegate = self
        nearbyBusStopsTableView.delegate = self
        nearbyBusStopsTableView.dataSource = self
        
        let refreshIcon = FAKFontAwesome.refreshIconWithSize(24)
        refreshIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGrayColor())
        mapRefreshButton.setAttributedTitle(refreshIcon.attributedString(), forState: .Normal)
    }
    
    @IBAction func onClickMapRefresh(sender: AnyObject) {
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotation.toValue = M_PI * 2
            rotation.duration = 0.66
            rotation.cumulative = true
            rotation.repeatCount = 2
            self.mapRefreshButton.layer.addAnimation(rotation, forKey: "rotateAnimation")
            }) { (bool) -> Void in
                self.locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        nearbyMapView.removeAnnotations(nearbyMapView.annotations)
        centerMapOnLocation(locations.first!)
        
        let parameters = [
            "latitude" : String(locations.first!.coordinate.latitude.description),
            "longitude" : String(locations.first!.coordinate.longitude.description),
        ]
        
        Alamofire.request(.GET, Config.SGJourneyAPI2 + "/bus/nearby", parameters: parameters).responseJSON(completionHandler: { (req, resp, result) -> Void in
            self.nearbyBusStops.removeAll()
            if(result.isSuccess) {
                let json = JSON(result.value!)
                for busStop in json.arrayValue {
                    self.nearbyBusStops.append(busStop)
                    let location = CLLocation(latitude: busStop["Latitude"].doubleValue, longitude: busStop["Longitude"].doubleValue)
                    //            print(location.distanceFromLocation(locations[0]))
                    
                    let annotation = BusAnnotation()
                    annotation.pin = "ic_marker_bus.png"
                    annotation.coordinate = location.coordinate
                    annotation.title = busStop["Description"].string!
                    annotation.subtitle = "\(busStop["RoadName"].string!) (\(busStop["BusStopCode"].string!))"
                    
                    self.busPinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "bus_pin")
                    self.nearbyMapView.addAnnotation(self.busPinAnnotation.annotation!)
                }
                
                self.nearbyBusStopsTableView.reloadData()
            }
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyBusStops.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! BusTableViewCell
        let busStop = nearbyBusStops[indexPath.row]
        
        cell.viewController = self
        
        cell.busStopCode = busStop["BusStopCode"].stringValue
        cell.busStopTitle = busStop["Description"].stringValue
        cell.busStopDescription = "\(busStop["RoadName"].string!) (\(busStop["BusStopCode"].stringValue))"
        
        cell.titleLabel?.text = cell.busStopTitle
        cell.descriptionLabel?.text = cell.busStopDescription
        cell.update()
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