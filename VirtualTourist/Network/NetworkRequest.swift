//
//  NetworkRequest.swift
//  VirtualTourist
//
//  Created by Alessandro Losavio on 17/03/2019.
//  Copyright © 2019 Losavio. All rights reserved.
//

import Foundation
import CoreData


class NetworkRequest {
    
    var photosArray:[photo] = []
    
    let LOCATION_API_URL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=4142777d545d14823760b6f4f2f3553b&format=json&nojsoncallback=1&per_page=20"
    
    func getGeoPhotos(lat: String, lon: String, completion: @escaping ()->Void){
                
        let randomNumber = String(arc4random_uniform(4) + 1)
        
        print("Rnamdom")
        print(randomNumber)
        
        let composition = LOCATION_API_URL + "&lat=" + lat + "&lon=" + lon
        
        let request = URLRequest(url: URL(string:  composition + "&page=" + randomNumber)!)
        let session = URLSession.shared
        
        print("Getting json")
        
    
    
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                
                //errorHandler(error!)
                print(error?.localizedDescription ?? "Unknow error")
                
                return
            }
            
            guard let data = data else {
                
                print("No data")
                return
            }
            
            do {
                print("adding location Info")
                //var myData = String(data: data, encoding: .utf8)!
                let photos = try JSONDecoder().decode(GeoPhotosResponse.self, from: data)
                //self.photosArray = photos.photos.photo.map({$0})
                photosLocationClass().setJsonPhoto(jsonPhotos: photos.photos.photo)
                photosLocationClass().setLatitune(lat: lat)
                photosLocationClass().setLongitude(lon: lon)
                
                completion()
                return
                
            } catch {
                let myError = error as NSError
                print("Qualcosa non va")
                print(myError)
                
            }
            
        }
        task.resume()
        
        return
    }
    
    
    func downloadImage(photo: photo, completion: @escaping ()->Void){
        
        
            let part1 = "https://farm" + String(photo.farm) + ".staticflickr.com/"
            let part2 = photo.server + "/" + photo.id + "_" + photo.secret + ".jpg"
            
            let request = URLRequest(url: URL(string: part1 + part2)!)
            let session = URLSession.shared
            
            print(request)
            
        
            let task = session.dataTask(with: request){ data, response, error in
                if error != nil { // Handle error...
                    
                    //errorHandler(error!)
                    print(error?.localizedDescription ?? "Unknow error")
                    
                    return
                }
                
                guard let data = data else {
                    
                    print("No data")
                    return
                }
                
                do {
                    print("Here")
                    //var myData = String(data: data, encoding: .utf8)!
                    photosLocationClass().addPhoto(data: data)
                    completion()
                    
                    return
                
                    
                } catch {
                    let myError = error as NSError
                    print("Qualcosa non va")
                    print(myError)
                    
                }
                
            }
            task.resume()
            
            return

    }
    
    
}
