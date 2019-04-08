//
//  NetworkRequest.swift
//  VirtualTourist
//
//  Created by Alessandro Losavio on 17/03/2019.
//  Copyright © 2019 Losavio. All rights reserved.
//

import Foundation
import OAuthSwift


class NetworkRequest {
    
    let API_URL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=4142777d545d14823760b6f4f2f3553b&lat=42.464828&lon=14.214090&format=json&nojsoncallback=1"
    
    
    func getGeoPhotos(){
        
        let request = URLRequest(url: URL(string: API_URL)!)
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
                
                //print(radioList)
                
//                if RadioData().getRadios().count == 0 {
//
//                    radioList.results.forEach{ station in
//
//
//                        RadioData().addRadio(radio: station)
//                    }
//
//                }
//
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
