//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Alessandro Losavio on 16/03/2019.
//  Copyright © 2019 Losavio. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    var removingPins = false
    
    var longPressRec = UILongPressGestureRecognizer()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deletePopUp: UIButton!
    @IBOutlet weak var navBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
    
    
    @objc func addAnnotation(press: UILongPressGestureRecognizer) {
        
        if press.state ==  UILongPressGestureRecognizer.State.began  {
            
            let location  = press.location(in: mapView)
            let coordinates = mapView.convert(location, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            
            mapView.addAnnotation(annotation)
            
            NetworkRequest().getGeoPhotos()
            
            
        }
        
    }
    
}

