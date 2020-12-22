//
//  NSPersistentContainer+Extension.swift
//  InstabugLogger
//
//  Created by Hassan El Desouky on 22/12/2020.
//  Copyright © 2020 Instabug. All rights reserved.
//

import CoreData

extension NSPersistentContainer {

  func destroyPersistentStore() {
    guard let storeURL = persistentStoreDescriptions.first?.url,
          let storeType = persistentStoreDescriptions.first?.type else {
      return
    }

    do {
      let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
      try persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: storeType, options: nil)
    } catch let error {
      print("failed to destroy persistent store at \(storeURL), error: \(error)")
    }
  }
}

