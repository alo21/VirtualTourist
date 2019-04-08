//
//  DataController.swift
//  VirtualTourist
//
//  Created by Alessandro Losavio on 08/04/2019.
//  Copyright © 2019 Losavio. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (()->Void)? = nil){
        persistentContainer.loadPersistentStores {storeDrscription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
            
            
            
        }
    }
    
    
    
}
