//
//  LoggerDataManager.swift
//  InstabugLogger
//
//  Created by Hassan El Desouky on 20/12/2020.
//  Copyright © 2020 Instabug. All rights reserved.
//

import Foundation
import CoreData

class LoggerDataManager {

  let entityName = "LoggerEntity"
  let logsLimit: Int
  let backgroundContext: NSManagedObjectContext
  let mainContext: NSManagedObjectContext
  let isStoreInMemory: Bool
  var firstLogObjectID: NSManagedObjectID?

  init(mainContext: NSManagedObjectContext =
        CoreDataManager.shared.mainContext,
       backgroundContext: NSManagedObjectContext =
        CoreDataManager.shared.backgroundContext,
       logsLimit: Int = 5000,
       storeInMemory: Bool = false) {
    self.mainContext = mainContext
    self.backgroundContext = backgroundContext
    self.logsLimit = logsLimit
    self.isStoreInMemory = storeInMemory
  }

  // MARK: Save a Log
  func saveLog(_ log: LoggerValue) {
    let logs = fetchAllLogs()
    backgroundContext.performAndWait {
      if logs.count >= logsLimit {
        let firstLog = logs[0]
        let objectID = firstLog.objectID

        if let logInContext = try? backgroundContext.existingObject(with: objectID) {
          backgroundContext.delete(logInContext)
        }
      }
      let logger =
        NSEntityDescription.insertNewObject(forEntityName: self.entityName,
                                            into: backgroundContext) as! LoggerEntity

      logger.creationDate = log.creationDate
      logger.logLevel = Int16(log.level.rawValue)
      logger.message = log.message
      do {
        try backgroundContext.save()
      } catch let error {
        fatalError("\(error)")
      }
    }
  }

  // MARK: Deleting
  func deleteLog(_ log: LoggerEntity) {
    let objectID = log.objectID
    backgroundContext.performAndWait {
      if let logInContext = try? backgroundContext.existingObject(with: objectID) {
        backgroundContext.delete(logInContext)
        try? backgroundContext.save()
      }
    }
  }

  func deleteFirstLog() {
    let fetchRequest = NSFetchRequest<LoggerEntity>(entityName: entityName)
    let sortByDate = NSSortDescriptor(key: "creationDate", ascending: true)
    fetchRequest.sortDescriptors = [sortByDate]
    fetchRequest.fetchLimit = 1
    let logs = try! backgroundContext.fetch(fetchRequest)
    let firstLog = logs[0]
    deleteLog(firstLog)
  }

  func deleteAllLogs() {
    if !isStoreInMemory {
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
      backgroundContext.performAndWait {
        _ = try? backgroundContext.execute(deleteRequest)
        try? backgroundContext.save()
      }
    } else {
      CoreDataManager.shared.persistentContainer.destroyPersistentStore()
    }
  }


  // MARK: Fetch all Logs
  func fetchAllLogs() -> [LoggerEntity] {
    let fetchRequest = NSFetchRequest<LoggerEntity>(entityName: entityName)
    let sortByDate = NSSortDescriptor(key: "creationDate", ascending: true)
    fetchRequest.sortDescriptors = [sortByDate]
    fetchRequest.returnsObjectsAsFaults = false
    var logs = [LoggerEntity]()

    mainContext.performAndWait {
      do {
        logs = try mainContext.fetch(fetchRequest)
      } catch {
        print("Unable to fetch managed objects")
      }
    }
    return logs
  }
}
