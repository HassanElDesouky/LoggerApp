//
//  LoggerDestinationTests.swift
//  InstabugLoggerTests
//
//  Created by Hassan El Desouky on 19/12/2020.
//  Copyright © 2020 Instabug. All rights reserved.
//

import XCTest
@testable import InstabugLogger

class LoggerDestinationTests: XCTestCase {

  func testInit() {
    let id = "com.Instabug.InstabugLogger.DestinationTests"
    let destination = LoggerDestination(identification: id)
    XCTAssertEqual(destination.moduleIdentification, id)
    XCTAssertNotNil(destination.destinationQueue)
  }

  func testFormatLog() {
    let id = "com.Instabug.InstabugLogger.DestinationTests"
    let destination = LoggerDestination(identification: id)

    let date = Date(timeIntervalSinceReferenceDate: 0) // "Jan 1, 2001 at 2:00 AM"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "y-MM-dd H:m:ss.SSSS"

    let logger = LoggerValue(level: .error,
                                  message: "Message", date: date)
    let formattedDate = dateFormatter.string(from: logger.creationDate)

    let log = "[\(formattedDate) - \(logger.level.getLevelName()) - \(logger.message)]"
    let formattedLog = destination.formatLog(logger: logger)

    XCTAssertEqual(formattedLog, log)
  }
}
