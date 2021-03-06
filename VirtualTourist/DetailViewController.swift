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
    var location: Location!
    var photos: [Photo] = []
    let finalPiece: [UIImage] = []
    var selectedArrayCell:[Int] = []
    let maxPhoto = 20
    @IBOutlet var colletionView: UICollectionView!
    @IBOutlet var bottomButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.colletionView.delegate = self
        self.colletionView.dataSource = self
        
        getCoreDataPhoto()
        
    }
    
    func getCoreDataPhoto(){
        
        
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
        
        if photos.count==0 {
            NetworkRequest().getGeoPhotos(lat: self.location.lat!, lon: self.location.lon!, completion: {self.getPhotosArray()})
            
        }
        
        if bottomButton.isEnabled && photos.count != 0 {
            return photos.count
        } else {
            return maxPhoto
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DetailCollectionViewCell
        
        if (indexPath as NSIndexPath).row < photos.count {
            let photo = photos[(indexPath as NSIndexPath).row]
            cell.photo.image = UIImage(data: photo.photo!,scale:1.0)
            
        } else if !bottomButton.isEnabled {
            
            cell.photo.image = UIImage(named: "placeholder")
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var isDeselection = false
        let selectedCell = collectionView.cellForItem(at: indexPath)
        
        
        if !selectedArrayCell.isEmpty {
            
            selectedArrayCell.forEach { (cell) in
                if indexPath.row == cell {
                    selectedCell?.layer.opacity = 1.0
                    selectedArrayCell = selectedArrayCell.filter{$0 != indexPath.row}
                    print(selectedArrayCell)
                    isDeselection = true
                    
                }
            }
            
        }
        
        if !isDeselection {
            selectedCell?.layer.opacity = 0.5
            selectedArrayCell.append(indexPath.row)
        }
        
        setButtonTitle()
        
        print(selectedArrayCell)
        
        
    }
    
    func setButtonTitle(){
        
        DispatchQueue.main.async {
            
            if !self.selectedArrayCell.isEmpty{
                self.bottomButton.setTitle("Delete", for: .normal)
            } else {
                self.bottomButton.setTitle("New Collection", for: .normal)
            }
        }
        
    }
    
    
    @IBAction func onButtonPressed(_ sender: UIButton) {
        
        if !selectedArrayCell.isEmpty {
            
            //Delete selected photos only
            
            selectedArrayCell.forEach { (selection) in
                dataController.viewContext.delete(photos[selection])
            }
            
            selectedArrayCell = []
            try? dataController.viewContext.save()
            print("Selected photo deleted")
            reloadCollectionView()
            
            
        } else {
            
            //Get new collection
            
            sender.isEnabled = false
            
            deleteImagesDataCore {
                NetworkRequest().getGeoPhotos(lat: self.location.lat!, lon: self.location.lon!, completion: {self.getPhotosArray()})
            }
            
        }
        
    }
    
    func reloadCollectionView(){
        
        setButtonTitle()
        getCoreDataPhoto()
        
        DispatchQueue.main.async {
            self.colletionView.reloadData()
        }
        
        if photos.count == maxPhoto {
            DispatchQueue.main.async {
                self.bottomButton.isEnabled = true
            }
        }
        
        print("view Reloaded")
        
    }
    

    func getPhotosArray(){
        
        let photos = photosLocationClass().getJsonPhots()
        
        
        photos.forEach { (photo) in
            NetworkRequest().downloadImage(photo: photo, completion: {self.saveImageDataCore()})
        }
        
        
    }
    
    func deleteImagesDataCore(completion: @escaping ()->Void){
        
        photos.forEach { (photo) in
            dataController.viewContext.delete(photo)
            try? dataController.viewContext.save()
            
        }
        print("All previous imagre deleted")
        completion()
        
    }
 
    func saveImageDataCore(){
        
        let data = photosLocationClass().getPhoto(atIndex: 0)
        
        let binaryPhoto = Photo(context: dataController.viewContext)
        binaryPhoto.photo = data
        binaryPhoto.location = location
        try? dataController.viewContext.save()
        //locationPhotos.insert(binaryPhoto, at: 0)
        
        print(location.photos?.count)
        reloadCollectionView()
        print("photo added")
        
    }
    
    
}


