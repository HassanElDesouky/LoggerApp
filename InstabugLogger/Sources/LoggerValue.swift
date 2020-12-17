//
//  LoggerValue.swift
//  InstabugLogger
//
//  Created by Hassan El Desouky on 16/12/2020.
//  Copyright © 2020 Instabug. All rights reserved.
//

import Foundation

public struct LoggerValue {
  public enum Level: Int {
    case verbose = 0
    case error = 1

    func getLevelName() -> String {
      switch self {
      case .verbose:
        return "VERBOSE"
      case .error:
        return "ERROR"
      }
    }
  }
  
  let creationDate: Date
  let level: Level
  var message = ""

  init(level: Level, message: String) {
    self.creationDate = Date()
    self.level = level
    self.message = validateMessage(message)
  }

  /// For testing only.
  init(level: Level, message: String, date: Date) {
    self.creationDate = date
    self.level = level
    self.message = message
  }

  /// Adds three dots _..._ after 1,000 characters, if the log message is over a 1,000 characters.
  /// - Parameter message: the log message.
  /// - Returns: the same `message` if the message length isn't more than 1,000 characters,
  /// and if it is more than 1,000 characters it will return only the first 1,000 character followed by three dots _..._.
  func validateMessage(_ message: String) -> String {
    var validatedMessage = message
    if message.count > 1000 {
      let limitIndex = validatedMessage.index(validatedMessage.startIndex,
                                              offsetBy: 1000)
      validatedMessage.replaceSubrange(limitIndex..<validatedMessage.endIndex,
                                       with: "...")
    }
    return validatedMessage
  }

  /// - Returns: a string describing the current log level.
  func getCurrentLevelName() -> String {
    return level.getLevelName()
  }
}
