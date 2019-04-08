//
//  GeoPhoto.swift
//  VirtualTourist
//
//  Created by Alessandro Losavio on 07/04/2019.
//  Copyright © 2019 Losavio. All rights reserved.
//

import Foundation


struct GeoPhotosResponse: Codable {
    let photos: photos
    let stat: String
}

struct photos: Codable{
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [photo]
}

struct photo: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}
