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
    
    let API_URL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=4142777d545d14823760b6f4f2f3553b&format=json&nojsoncallback=1"

    var dataController: DataController!
    
    
    func getGeoPhotos(lat: String, lon: String){

        
        let request = URLRequest(url: URL(string: API_URL + "&lat=" + lat + "&lon=" + lon )!)
        let session = URLSession.shared
        
    
    
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
                
                //var myData = String(data: data, encoding: .utf8)!
                let Photos = try JSONDecoder().decode(GeoPhotosResponse.self, from: data)
                //self.radioArray = radioList.results.map({$0})
                
                print(Photos)
                
            

                
//                DispatchQueue.main.async {
//
//                    print("Done getting data")
//
//                    completionHandler()
//
//                }
                
                
                
                
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
