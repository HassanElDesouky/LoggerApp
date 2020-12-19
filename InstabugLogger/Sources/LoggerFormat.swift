//
//  LoggerFormat.swift
//  InstabugLogger
//
//  Created by Hassan El Desouky on 19/12/2020.
//  Copyright © 2020 Instabug. All rights reserved.
//

import Foundation

public protocol LoggerFormat {
  /// Returns  a formatted `String` from the `logger` information.
  /// - Parameter logger: logger value.
  /// - Returns: a formatted `String` following the `[Date - Log level - message]` format.
  func formatLog(logger: LoggerValue) -> String
}
