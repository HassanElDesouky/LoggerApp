//
//  ConsoleDestination.swift
//  InstabugLogger
//
//  Created by Hassan El Desouky on 19/12/2020.
//  Copyright © 2020 Instabug. All rights reserved.
//

import Foundation

/// Emits log messages to the console.
final class ConsoleDestination: LoggerDestination {
  override init(identifier: String) {
    super.init(identifier: identifier)
  }

  override func emit(logger: LoggerValue) -> String {
    let formattedLog = super.emit(logger: logger)
    print(formattedLog)
    return formattedLog
  }
}
