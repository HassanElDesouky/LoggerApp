//
//  CoreDataManager.swift
//  InstabugLogger
//
//  Created by Hassan El Desouky on 20/12/2020.
//  Copyright © 2020 Instabug. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
  private var storeType: String!

  lazy var managedObjectModel: NSManagedObjectModel = {
    let frameworkBundleIdentifier = "com.Instabug.InstabugLogger"
    let customKitBundle = Bundle(identifier: frameworkBundleIdentifier)!
    let modelURL = customKitBundle.url(forResource: "Logger",
                                       withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
  }()

  lazy var persistentContainer: NSPersistentContainer! = {
    var persistentContainer = NSPersistentContainer(name: "Logger",
                                                    managedObjectModel:
                                                      self.managedObjectModel)
    let description = persistentContainer.persistentStoreDescriptions.first
    description?.type = storeType ?? NSSQLiteStoreType
    persistentContainer.loadPersistentStores { description, error in
      guard error == nil else {
        fatalError("was unable to load store \(error!)")
      }
    }
    return persistentContainer
  }()

  lazy var backgroundContext: NSManagedObjectContext = {
    let context = self.persistentContainer.newBackgroundContext()
    context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    return context
  }()

  lazy var mainContext: NSManagedObjectContext = {
    let context = self.persistentContainer.viewContext
    context.automaticallyMergesChangesFromParent = true
    return context
  }()

  static let shared = CoreDataManager()

  func setup(storeType: String = NSSQLiteStoreType) {
    self.storeType = storeType
  }
}
