//
//  LoggerValueTests.swift
//  InstabugLoggerTests
//
//  Created by Hassan El Desouky on 16/12/2020.
//  Copyright © 2020 Instabug. All rights reserved.
//

import XCTest
@testable import InstabugLogger

class LoggerValueTests: XCTestCase {
  
  func testLoggerValueInit() {
    let level = LoggerValue.Level.error
    let message = "Test Message"
    let loggerVal = LoggerValue(level: level, message: message)
    
    XCTAssertEqual(level, loggerVal.level)
    XCTAssertEqual(message, loggerVal.message)
  }

  
  func testLoggerValueInitWithDate() {
    let level = LoggerValue.Level.error
    let message = "Test Message"
    let date = Date(timeIntervalSinceReferenceDate: 0) // "Jan 1, 2001 at 2:00 AM"
    let loggerVal = LoggerValue(level: level, message: message, date: date)
    
    XCTAssertEqual(level, loggerVal.level)
    XCTAssertEqual(message, loggerVal.message)
    XCTAssertEqual(date, loggerVal.creationDate)
  }
  
  func testGetLevelName() {
    let verboseLevelName = "VERBOSE"
    let errorLevelName = "ERROR"

    let errorLoggeerVal = LoggerValue(level: .error,
                                      message: "Test message")
    let verboseLoggerVal = LoggerValue(level: .verbose,
                                       message: "Test message")
    
    XCTAssertEqual(errorLoggeerVal.getCurrentLevelName(),
                   errorLevelName)
    XCTAssertEqual(verboseLoggerVal.getCurrentLevelName(),
                   verboseLevelName)
  }
  
  func testValidateMessage() {
    let veryLongMessage = String(repeating: "A", count: 1050)
    
    let modifiedMessage = String(repeating: "A", count: 1000) + "..."

    let loggerVal = LoggerValue(level: .error,
                                message: veryLongMessage)
    XCTAssertEqual(loggerVal.message.count, 1003)
    XCTAssertEqual(loggerVal.message, modifiedMessage)
    XCTAssertEqual(String(loggerVal.message.suffix(3)), "...")
  }

}
