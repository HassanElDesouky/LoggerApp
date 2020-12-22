//
//  CoreDataTestManager.swift
//  InstabugLoggerTests
//
//  Created by Hassan El Desouky on 21/12/2020.
//  Copyright © 2020 Instabug. All rights reserved.
//

import XCTest
import CoreData
@testable import InstabugLogger

struct CoreDataTestManager {

  let managedObjectModel: NSManagedObjectModel
  let persistentContainer: NSPersistentContainer
  let mainContext: NSManagedObjectContextSpy
  let backgroundContext: NSManagedObjectContextSpy

  init() {
    let frameworkBundleIdentifier = "com.Instabug.InstabugLogger"
    let customKitBundle = Bundle(identifier: frameworkBundleIdentifier)!
    let modelURL = customKitBundle.url(forResource: "Logger",
                                       withExtension: "momd")!
    managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
    persistentContainer = NSPersistentContainer(name: "Logger",
                                                managedObjectModel:
                                                  managedObjectModel)
    let description = persistentContainer.persistentStoreDescriptions.first
    description?.type = NSInMemoryStoreType

    persistentContainer.loadPersistentStores { description, error in
      guard error == nil else {
        fatalError("Unable to load store \(error!)")
      }
    }

    mainContext =
      NSManagedObjectContextSpy(concurrencyType: .mainQueueConcurrencyType)
    mainContext.automaticallyMergesChangesFromParent = true
    mainContext.persistentStoreCoordinator =
      persistentContainer.persistentStoreCoordinator

    backgroundContext =
      NSManagedObjectContextSpy(concurrencyType: .privateQueueConcurrencyType)
    backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    backgroundContext.parent = self.mainContext
  }
}
