//
//  InstabugLoggerTests.swift
//  InstabugLoggerTests
//
//  Created by khaled mohamed el morabea on 2/23/20.
//  Copyright © 2020 Instabug. All rights reserved.
//

import XCTest
@testable import InstabugLogger

class InstabugLoggerTests: XCTestCase {

  let instabugLogger = InstabugLogger(identifier:
                                        "com.Instabug.InstabugLogger.InstabugLoggerTests")

  func testInit() {
    let identifier = "com.Instabug.InstabugLogger.InstabugLoggerTests"
    XCTAssertEqual(instabugLogger.identifier, identifier)
  }
  
  func testLog() {
    let loggersCount = instabugLogger.fetchLogs().count
    XCTAssertNoThrow((try instabugLogger.log("Verbose Message",
                                             level: .verbose)))
    XCTAssertNoThrow((try instabugLogger.log("Error Message",
                                             level: .error)))
    let newLoggersCount = loggersCount + 2
    XCTAssertEqual(instabugLogger.fetchLogs().count,
                   newLoggersCount)
  }

  func testErrorLog() {
    let loggersCount = instabugLogger.fetchLogs().count
    XCTAssertNoThrow((try instabugLogger.error("Error Message")))
    let newLoggersCount = loggersCount + 1
    XCTAssertEqual(instabugLogger.fetchLogs().count,
                   newLoggersCount)
  }

  func testVerboseLog() {
    let loggersCount = instabugLogger.fetchLogs().count
    XCTAssertNoThrow((try instabugLogger.verbose("Verbose Message")))
    let newLoggersCount = loggersCount + 1
    XCTAssertEqual(instabugLogger.fetchLogs().count,
                   newLoggersCount)
  }


  func testFetchAllLogs() {
    let loggersCount = instabugLogger.fetchLogs().count
    let messages = [
      "Error Message 1",
      "Error Message 2",
      "Error Message 3",
      "Error Message 4",
    ]
    let date = Date(timeIntervalSinceReferenceDate: 0) // "Jan 1, 2001 at 2:00 AM"
    var timeInterval: TimeInterval = 30000
    for message in messages {
      let logger = LoggerValue(level: .error, message: message,
                               date: date.advanced(by: timeInterval))
      XCTAssertNoThrow(try instabugLogger.log(logger: logger))
      timeInterval *= 2
    }

    var logs = instabugLogger.fetchLogs()
    let allLogsStringsCount = instabugLogger.fetchLogsStrings().count
    let newLoggersCount = loggersCount + messages.count

    XCTAssertEqual(logs.count, newLoggersCount)
    XCTAssertEqual(allLogsStringsCount, newLoggersCount)

    logs.sort()
    XCTAssertEqual(logs, instabugLogger.fetchLogs())
  }

  func testLogsExceededLimit() {
    for logNum in instabugLogger.fetchLogs().count...5000 {
      XCTAssertNoThrow(try instabugLogger.log("Message \(logNum)", level: .verbose))
    }

    let expectedError = InstabugLogger.LoggerSessionError.logsPerSessionExceed
    var error: InstabugLogger.LoggerSessionError?
    XCTAssertThrowsError(try instabugLogger.log("Message 5001",
                                                level: .error)) { thrownError in
      error = thrownError as? InstabugLogger.LoggerSessionError
    }
    XCTAssertEqual(expectedError, error)

    let logVal = LoggerValue(level: .error, message: "Message 5002")
    XCTAssertThrowsError(try instabugLogger.log(logger: logVal)) { thrownError in
      error = thrownError as? InstabugLogger.LoggerSessionError
    }
    XCTAssertEqual(expectedError, error)

    XCTAssertThrowsError(try instabugLogger.error("Message 5003")) { thrownError in
      error = thrownError as? InstabugLogger.LoggerSessionError
    }
    XCTAssertEqual(expectedError, error)

    XCTAssertThrowsError(try instabugLogger.verbose("Message 5004")) { thrownError in
      error = thrownError as? InstabugLogger.LoggerSessionError
    }
    XCTAssertEqual(expectedError, error)

  }
}
