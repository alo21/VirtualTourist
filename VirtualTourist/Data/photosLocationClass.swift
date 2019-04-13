//
//  photosLocation.swift
//  VirtualTourist
//
//  Created by Alessandro Losavio on 10/04/2019.
//  Copyright © 2019 Losavio. All rights reserved.
//

import Foundation

struct PhotosLocation: Codable {
    var lat: String
    var lon: String
    var photos:[Data]
    var jsonPhotos:[photo]
}

var globalPhotosLocation: PhotosLocation = PhotosLocation(lat: "", lon: "", photos: [], jsonPhotos: [])


class photosLocationClass{
    
    
    func setLatitune(lat: String){
        globalPhotosLocation.lat = lat
    }
    
    func setLongitude(lon: String){
        globalPhotosLocation.lon = lon
    }
    
    func addPhoto(data: Data){
        globalPhotosLocation.photos.insert(data, at: 0)
    }
    
    func setJsonPhoto(jsonPhotos: [photo]){
        
        globalPhotosLocation.jsonPhotos = jsonPhotos
    }
    
    func getLatitude()->String{
        return globalPhotosLocation.lat
    }
    
    func getLongitude()->String{
        return globalPhotosLocation.lon
    }
    
    func getPhoto(atIndex: Int)->Data{
        return globalPhotosLocation.photos[atIndex]
    }
    
    func getJsonPhots() -> [photo] {
            
        return globalPhotosLocation.jsonPhotos
    }
    
    
    
    
}
