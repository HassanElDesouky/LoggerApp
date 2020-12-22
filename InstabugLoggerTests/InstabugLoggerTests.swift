//
//  InstabugLoggerTests.swift
//  InstabugLoggerTests
//
//  Created by khaled mohamed el morabea on 2/23/20.
//  Copyright © 2020 Instabug. All rights reserved.
//

import XCTest
import CoreData
@testable import InstabugLogger

class InstabugLoggerTests: XCTestCase {

  var coreDataTestManager: CoreDataTestManager!
  var loggerCoreDataManager: LoggerDataManager!
  var instabugLogger: InstabugLogger!

  override func setUp() {
    super.setUp()
    coreDataTestManager = CoreDataTestManager()
    instabugLogger = InstabugLogger(mainContext: coreDataTestManager.mainContext,
                                    backgroundContext:
                                      coreDataTestManager.mainContext,
                                    destination: ConsoleDestination(),
                                    forTesting: true)
  }

  func testInit() {
    let loggerDestination = ConsoleDestination()
    XCTAssertEqual(String(describing: instabugLogger.destination.self), String(describing: loggerDestination.self))
    XCTAssertEqual(instabugLogger.loggerQueue.label,
                   "com.Instabug.InstabugLoggerQueue")
    XCTAssertEqual(instabugLogger.fetchLogs().count, 0)
    XCTAssertEqual(String(describing: instabugLogger.destination.self), String(describing: loggerDestination.self))
  }
  
  func testLog() {
    instabugLogger.log("Verbose Message", level: .verbose)

    expectation(forNotification: .NSManagedObjectContextDidSave, object: coreDataTestManager.mainContext) { _ in
      return true
    }

    waitForExpectations(timeout: 1.0) { (error) in
      XCTAssertEqual(self.instabugLogger.fetchLogs().count, 1)
    }

    instabugLogger.log("Error Message", level: .error)

    expectation(forNotification: .NSManagedObjectContextDidSave, object: coreDataTestManager.mainContext) { _ in
      return true
    }

    waitForExpectations(timeout: 1.0) { (error) in
      XCTAssertEqual(self.instabugLogger.fetchLogs().count, 2)
    }
  }

  func testErrorLog() {
    instabugLogger.error("Error Message")

    expectation(forNotification: .NSManagedObjectContextDidSave, object: coreDataTestManager.mainContext) { _ in
      return true
    }

    waitForExpectations(timeout: 1.0) { (error) in
      XCTAssertEqual(self.instabugLogger.fetchLogs().count, 1)
    }
  }

  func testVerboseLog() {
    instabugLogger.verbose("Verbose Message")

    expectation(forNotification: .NSManagedObjectContextDidSave, object: coreDataTestManager.mainContext) { _ in
      return true
    }

    waitForExpectations(timeout: 1.0) { (error) in
      XCTAssertEqual(self.instabugLogger.fetchLogs().count, 1)
    }
  }

  func testFetchAllLogs() {
    var date = Date(timeIntervalSinceReferenceDate: 0)
    for logNum in 1...4 {
      saveLogHelper(logNum, expectedCount: logNum, &date)
    }

    var logs = instabugLogger.fetchLogs()

    logs.sort()
    XCTAssertEqual(logs, instabugLogger.fetchLogs())
  }

  func testFetchAllLogsStrings() {
    var date = Date(timeIntervalSinceReferenceDate: 0)
    for logNum in 1...4 {
      saveLogHelper(logNum, expectedCount: logNum, &date)
    }

    date = Date(timeIntervalSinceReferenceDate: 0)
    let logs = instabugLogger.fetchLogs()
    let logsStrings = instabugLogger.fetchLogsStrings()
    XCTAssertEqual(logs.count, logsStrings.count)
    for (index, log) in logs.enumerated() {
      let log = instabugLogger.destination.formatLog(logger: log)
      XCTAssertEqual(log, logsStrings[index])
    }
  }
}

extension InstabugLoggerTests {
  func saveLogHelper(_ loggerNum: Int, expectedCount: Int,
                     _ date: inout Date) {
    let logger = LoggerValue(level: .error,
                             message: "Error Message \(loggerNum)",
                             date: date)
    instabugLogger.log(logger: logger)

    expectation(forNotification: .NSManagedObjectContextDidSave,
                object: coreDataTestManager.mainContext) { _ in
      return true
    }

    waitForExpectations(timeout: 1) { (error) in
      XCTAssertEqual(self.instabugLogger.fetchLogs().count, expectedCount)
    }

    date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
  }
}
