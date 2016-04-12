//
//  DriverMapDetailPendingVC.swift
//  hackathon-for-hunger
//
//  Created by David Fierstein on 4/9/16.
//  Copyright © 2016 Hacksmiths. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DriverMapDetailPendingVC: UIViewController, MKMapViewDelegate {
    
    var startingRegion = MapsDummyData.sharedInstance.startingRegion // used to retrieve precalculated starting region
    
    var annotationsHaveBeenShown: Bool = false //to allow auto zooming to pins, but just once
    
    var locationManager = LocationManager.sharedInstance.locationManager
    
    var donation: Donation?
    
    var pickupAnnotation: MKPointAnnotation?
    var dropoffAnnotation: MKPointAnnotation?

    
    
    //MARK:- Outlets & Actions
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var recipientNameLabel: UILabel!
    @IBOutlet weak var recipientStreetLabel: UILabel!
    @IBOutlet weak var recipientCityLabel: UILabel!
    @IBOutlet weak var donorNameLabel: UILabel!
    @IBOutlet weak var donorStreetLabel: UILabel!
    @IBOutlet weak var donorCityLabel: UILabel!
    
    @IBAction func acceptDonation(sender: AnyObject) {
        // segue to view controller with route
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK:- View lifecycle
    
    override func viewDidLoad() {

        mapView.delegate = self
        mapView.setRegion(startingRegion, animated: true)
        if donation != nil {
            donorNameLabel.text = donation?.donor?.name
            // TODO: need a street address for Donor Participant, to be passed to UI
            if donation?.recipient != nil {
                recipientNameLabel.text = donation?.recipient?.name
                recipientStreetLabel.text = donation?.recipient?.street_address
                if let cityString = donation?.recipient?.city {
                    if let stateString = donation?.recipient?.state {
                        let cityStateString = cityString + ", " + stateString
                        if let zipString = donation?.recipient?.zip_code {
                            recipientCityLabel.text = cityStateString + " " + zipString
                        }
                    }
                }
                
                

            }
        }
        
        mapView.showsUserLocation = true
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        addPins()
        
        if donation != nil {
            donorNameLabel.text = donation?.donor?.name
        }
    }
    
    //MARK:- mapView
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
        if annotationsHaveBeenShown != true {
            annotationsHaveBeenShown = true

            mapView.showAnnotations(mapView.annotations, animated: true)
        }
        
    }
    
//    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//
//        for annotation in mapView.annotations {
//            mapView.deselectAnnotation(annotation, animated: true)
//            mapView.selectAnnotation(annotation, animated: true)
//        }
//
//    }
    

    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            pinView?.pinTintColor = MapsDummyData.sharedInstance.pinColor
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    
    //MARK:- Annotations
    
    func addPins() { //TODO:- unwrap safely
        
        // In case there are any exisiting annotations, remove them
        if mapView.annotations.count != 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        
        // Set pin for pickup location
        pickupAnnotation = MKPointAnnotation()
        pickupAnnotation!.title = donation?.donor?.name
        
        pickupAnnotation!.coordinate = (donation?.pickup?.coordinates)!
        
        
        let pickupAnnotationView = MKPinAnnotationView(annotation: pickupAnnotation, reuseIdentifier: nil)
        pickupAnnotationView.canShowCallout = true
        pickupAnnotationView.selected = true
        mapView.addAnnotation(pickupAnnotationView.annotation!)

        // Set pin for the optional dropoff location if it exists at this point
        if let dropoff = donation?.dropoff { 
            dropoffAnnotation = MKPointAnnotation()
            dropoffAnnotation!.title = donation?.recipient?.name
            
            dropoffAnnotation!.coordinate = (dropoff.coordinates)!
            
            let dropoffAnnotationView = MKPinAnnotationView(annotation: dropoffAnnotation, reuseIdentifier: nil)
            
            mapView.addAnnotation(dropoffAnnotationView.annotation!)
            dropoffAnnotationView.selected = true
        } else {
            recipientNameLabel.text = "no dropoff location yet"
            
        }
    }
    
    
}