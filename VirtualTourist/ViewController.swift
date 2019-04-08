//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Alessandro Losavio on 16/03/2019.
//  Copyright © 2019 Losavio. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate {
    
    var removingPins = false
    var dataConroller: DataController!
    var longPressRec = UILongPressGestureRecognizer()
    var locations: [Location] = []
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deletePopUp: UIButton!
    @IBOutlet weak var navBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Fetching locations from CoreData
        let fetchRequest:NSFetchRequest<Location> = Location.fetchRequest()
        if let result = try? dataConroller.viewContext.fetch(fetchRequest) {
            locations = result
            print("Restoring locations...")
            print(locations.count)
            print("locations restored")
            populateMap()
        }
        
        deletePopUp.isHidden = true
        
        longPressRec = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(press:)))
        
        longPressRec.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRec)
        
        mapView.delegate = self
        
    }
    
    
    @IBAction func editPressed(_ sender: UIBarButtonItem) {
        
        var item = navBar.rightBarButtonItem
        
        if removingPins == true {
            
            print("I can't remove pins")
            
            item = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(editPressed(_:)))
            
            
            mapView.addGestureRecognizer(longPressRec)
            
        } else {
            
            print("I can remove pins")
            
            item = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(editPressed(_:)))
            
            mapView.removeGestureRecognizer(longPressRec)
            
        }
        
        deletePopUp.isHidden = removingPins
        removingPins = !removingPins
        
        navBar.setRightBarButton(item, animated: true)
        
    }
    
    
    //MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
        }
        else {
            pinView!.annotation = annotation
        }
        
        
        return pinView
    }
    
    
    
    //Method implemented to respond to taps
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        print("tapped a pin")
        
        if(removingPins) {
        
            
            mapView.removeAnnotation(view.annotation!)
        
        } else {
            
            print("Taking you the other side")
            
        
            
            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            self.navigationController!.pushViewController(VC1, animated: true)
        }
        

    }
    
    func saveLocationModel(lat: String, lon: String){
        
        //Creating the transtient to save
        let location = Location(context: dataConroller.viewContext)
        location.lat = lat
        location.lon = lon
        
        //trying to save into disk
        do {
            try? dataConroller.viewContext.save()
            print("coordinates saved")
        } catch {
            print("I can't save the coordinates")
        }
        
    }
    
    
    @objc func addAnnotation(press: UILongPressGestureRecognizer) {
        
        if press.state ==  UILongPressGestureRecognizer.State.began  {
            
            let location  = press.location(in: mapView)
            let coordinates = mapView.convert(location, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            
            let latString = String(format:"%f", coordinates.latitude)
            let lonString = String(format:"%f", coordinates.longitude)
            
            print(coordinates)
            
            mapView.addAnnotation(annotation)
            saveLocationModel(lat: latString, lon: lonString)
            
            NetworkRequest().getGeoPhotos(lat: latString, lon: lonString)
            
            
        }
        
    }
    
    
    func populateMap(){
        
        for location in locations {
            
            let annotations = MKPointAnnotation()
            annotations.coordinate = CLLocationCoordinate2D(latitude: (location.lat! as NSString).doubleValue, longitude: (location.lon! as NSString).doubleValue)
            
            mapView.addAnnotation(annotations)
            
        }
        
        
    }
    
}

