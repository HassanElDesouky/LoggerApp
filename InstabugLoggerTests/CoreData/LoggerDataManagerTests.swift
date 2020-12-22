//
//  LoggerCoreDataManagerTests.swift
//  InstabugLoggerTests
//
//  Created by Hassan El Desouky on 22/12/2020.
//  Copyright © 2020 Instabug. All rights reserved.
//

import XCTest
import CoreData
@testable import InstabugLogger

class LoggerDataManagerTests: XCTestCase {

  let entityName = "LoggerEntity"
  var sut: LoggerDataManager!
  var coreDataTestManager: CoreDataTestManager!

  override func setUp() {
    super.setUp()
    coreDataTestManager = CoreDataTestManager()
    sut = LoggerDataManager(mainContext: coreDataTestManager.mainContext,
                            backgroundContext: coreDataTestManager.mainContext)
  }

  func test_init_context() {
    XCTAssertEqual(sut.backgroundContext, coreDataTestManager.mainContext)
  }

  func test_saveLog_logSaved() {
    let performAndWaitExpectation = expectation(description: #function)
    performAndWaitExpectation.assertForOverFulfill = false
    coreDataTestManager.mainContext.expectation = performAndWaitExpectation

    sut.saveLog(LoggerValue(level: .error, message: "Error Message"))

    waitForExpectations(timeout: 1) { (_) in
      let request = NSFetchRequest<LoggerEntity>(entityName: self.entityName)
      let logs = try! self.coreDataTestManager.mainContext.fetch(request)

      guard let log = logs.first else {
        XCTFail("log is missing")
        return
      }

      XCTAssertEqual(logs.count, 1)
      XCTAssertNotNil(log.creationDate)
      XCTAssertNotNil(log.logLevel)
      XCTAssertNotNil(log.message)
      XCTAssertTrue(self.coreDataTestManager.mainContext.saveWasCalled)
    }
  }

  func test_saveLog_logsLimitExceded() {
    var date = Date(timeIntervalSinceReferenceDate: 0)
    for logNum in 0..<5000 {
      let log = NSEntityDescription.insertNewObject(forEntityName: "LoggerEntity",
                                                    into: coreDataTestManager.mainContext) as! LoggerEntity
      log.creationDate = date
      log.message = "Message \(logNum)"
      log.logLevel = 0
      date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
    }

    try! coreDataTestManager.mainContext.save()

    let performAndWaitExpectation = expectation(description: #function)
    performAndWaitExpectation.assertForOverFulfill = false
    coreDataTestManager.mainContext.expectation = performAndWaitExpectation

    sut.saveLog(LoggerValue(level: .error, message: "Error Message"))

    waitForExpectations(timeout: 1) { (_) in
      let request = NSFetchRequest<LoggerEntity>(entityName: self.entityName)
      let sortByDate = NSSortDescriptor(key: "creationDate", ascending: true)
      request.sortDescriptors = [sortByDate]
      let logs = try! self.coreDataTestManager.mainContext.fetch(request)

      guard let firstLog = logs.first,
            let lastLog = logs.last else {
        XCTFail("log is missing")
        return
      }

      XCTAssertEqual(logs.count, self.sut.logsLimit)
      XCTAssertEqual(firstLog.message, "Message 1")
      XCTAssertEqual(lastLog.message, "Error Message")
      XCTAssertTrue(self.coreDataTestManager.mainContext.saveWasCalled)
    }
  }

  func test_deleteLog_logDeleted() {

    let log1 = NSEntityDescription.insertNewObject(forEntityName: entityName,
                                                into: coreDataTestManager.mainContext) as! LoggerEntity
    log1.creationDate = Date()
    let log2 = NSEntityDescription.insertNewObject(forEntityName: entityName,
                                                   into: coreDataTestManager.mainContext) as! LoggerEntity
    log2.creationDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    let log3 = NSEntityDescription.insertNewObject(forEntityName: entityName,
                                                   into: coreDataTestManager.mainContext) as! LoggerEntity
    log3.creationDate = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
    try! coreDataTestManager.mainContext.save()

    let performAndWaitExpectation = expectation(description: #function)
    coreDataTestManager.mainContext.expectation = performAndWaitExpectation
    sut.deleteFirstLog()

    waitForExpectations(timeout: 1) { _ in
      let request = NSFetchRequest<LoggerEntity>(entityName: self.entityName)
      let sortByDate = NSSortDescriptor(key: "creationDate", ascending: true)
      request.sortDescriptors = [sortByDate]
      let logs = try! self.coreDataTestManager.mainContext.fetch(request)

      XCTAssertEqual(logs.count, 2)
      XCTAssertTrue(logs.contains(log2))
      XCTAssertTrue(logs.contains(log3))
      XCTAssertTrue(self.coreDataTestManager.mainContext.saveWasCalled)
    }
  }
}
