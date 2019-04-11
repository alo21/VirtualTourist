//
//  DetailViewController.swift
//  VirtualTourist
//
//  Created by Alessandro Losavio on 16/03/2019.
//  Copyright © 2019 Losavio. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    var dataController: DataController!
    var lat: String!
    var lon: String!
    var location: Location!
    var photos: [Photo] = []
    @IBOutlet var colletionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.colletionView.delegate = self
        self.colletionView.dataSource = self
            
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "location == %@", location)
        fetchRequest.predicate = predicate
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            print("Restoring images...")
            photos = result
            print("images restored")
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }




    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {


        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DetailCollectionViewCell
        let photo = photos[(indexPath as NSIndexPath).row]

        // Set the name and image

        print("oooh")
        cell.photo.image = UIImage(data: photo.photo!,scale:1.0)

        return cell
    }
    



}


