//
//  NSManagedObjectContextSpy.swift
//  InstabugLoggerTests
//
//  Created by Hassan El Desouky on 22/12/2020.
//  Copyright © 2020 Instabug. All rights reserved.
//

import CoreData
import XCTest

class NSManagedObjectContextSpy: NSManagedObjectContext {
  var expectation: XCTestExpectation?

  var saveWasCalled = false

  // MARK: - Perform
  override func performAndWait(_ block: () -> Void) {
    super.performAndWait(block)

    expectation?.fulfill()
  }

  // MARK: - Save
  override func save() throws {
    try super.save()
    saveWasCalled = true
  }
}

