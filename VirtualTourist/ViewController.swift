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
    
    
    var window: UIWindow?
    var removingPins = false
    var dataController: DataController!
    var longPressRec = UILongPressGestureRecognizer()
    var locations: [Location] = []
    var locationToAdd:Location!
    var locationPhotos:[Photo] = []
    var imageArray:[Data] = []
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deletePopUp: UIButton!
    @IBOutlet weak var navBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataCoreLocation()
        deletePopUp.isHidden = true
        
        longPressRec = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(press:)))
        
        longPressRec.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRec)
        
        mapView.delegate = self
        
        populateMap()
        
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
    
    
    func getArrayIndex(location: MKAnnotation) -> Int{
        
        let latString = String(format:"%f", location.coordinate.latitude)
        let lonString = String(format:"%f", location.coordinate.longitude)
        
        for (index, location) in locations.enumerated() {
            
            if(location.lon == lonString && location.lat == latString){
                return index
            }
            
        }
        
        return -1
        
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
        
            let locationToDelete = locations[getArrayIndex(location: view.annotation!)]
            dataController.viewContext.delete(locationToDelete)
            try? dataController.viewContext.save()
            
            mapView.removeAnnotation(view.annotation!)
        
        } else {
            
            print("Taking you the other side")
            
            locations.forEach { (location) in
                if(location.lat == String(format:"%f", (view.annotation?.coordinate.latitude)!)
                    && location.lon == String(format:"%f", (view.annotation?.coordinate.longitude)!)){
                    
                    print("Trovato la location")
                    
                    let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                    VC1.dataController = dataController
//                    VC1.lat = String(format:"%f", (view.annotation?.coordinate.latitude)!)
//                    VC1.lon = String(format:"%f", (view.annotation?.coordinate.longitude)!)
                    VC1.location = location
                    self.navigationController!.pushViewController(VC1, animated: true)
                    
                }
            }
        
            
        }
    }
    
    func getDataCoreLocation(){
        
        //Fetching locations from CoreData
        let fetchRequest:NSFetchRequest<Location> = Location.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            locations = result
            print("Restoring locations...")
            print(locations.count)
            print("locations restored")
        }
        
        
    }
    
    func saveLocationModel(lat: String, lon: String){
        
        //Creating the transtient to save
        locationToAdd = Location(context: dataController.viewContext)
        locationToAdd.lat = lat
        locationToAdd.lon = lon
        
        //trying to save into CoreData
    
        try? dataController.viewContext.save()
        getDataCoreLocation()
        print("coordinates saved")
       
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
            
            
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
            activityIndicator.color = .black
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            saveLocationModel(lat: latString, lon: lonString)
            
            NetworkRequest().getGeoPhotos(lat: latString, lon: lonString, completion: {self.getPhotosArray()})
            
        }
        
    }
    
    func getPhotosArray(){
        
        let photos = photosLocationClass().getJsonPhots()
        
        
        photos.forEach { (photo) in
            NetworkRequest().downloadImage(photo: photo, completion: {self.saveImageDataCore()})
        }
        
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        
        


    }
    
    func saveImageDataCore(){
        
        let data = photosLocationClass().getPhoto(atIndex: 0)
        
        let binaryPhoto = Photo(context: dataController.viewContext)
            binaryPhoto.photo = data
            binaryPhoto.location = locationToAdd
        try? dataController.viewContext.save()
            //locationPhotos.insert(binaryPhoto, at: 0)
            
            print("photo added")
            

    }
    
    
    func populateMap(){
        
        for location in locations {
            
            let annotations = MKPointAnnotation()
            annotations.coordinate = CLLocationCoordinate2D(latitude: (location.lat! as NSString).doubleValue, longitude: (location.lon! as NSString).doubleValue)
            
            mapView.addAnnotation(annotations)
            
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailViewController: DetailViewController = segue.destination as! DetailViewController
        detailViewController.dataController = dataController
    }
    
}

