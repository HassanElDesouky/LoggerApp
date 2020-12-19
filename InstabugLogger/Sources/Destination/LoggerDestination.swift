//
//  LoggerDestination.swift
//  InstabugLogger
//
//  Created by Hassan El Desouky on 19/12/2020.
//  Copyright © 2020 Instabug. All rights reserved.
//

import Foundation

/// A logger destination which all others inherit from. do not directly use
open class LoggerDestination: LoggerFormat {

  /// runs in own serial background thread for better performance
  open var asynchronously = false

  let moduleIdentification: String

  // each destination instance must have an own serial queue to ensure serial output
  // GCD gives it a prioritization between User Initiated and Utility
  var destinationQueue: DispatchQueue?

  public init(identification: String) {
    self.moduleIdentification = identification
    let uuid = UUID().uuidString
    let queueLabel = "InstabugLogger-queue-" + uuid
    destinationQueue = DispatchQueue(label: queueLabel,
                                     target: destinationQueue)
  }

  /// send / store the formatted log message to the destination
  /// returns the formatted log message for processing by inheriting method
  /// and for unit tests (nil if error)
  open func emit(logger: LoggerValue) -> String {
    return formatLog(logger: logger)
  }

  // MARK: Format
  public func formatLog(logger: LoggerValue) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "y-MM-dd H:m:ss.SSSS"
    let formattedDate = dateFormatter.string(from: logger.creationDate)
    return "[\(formattedDate) - \(logger.level.getLevelName()) - \(logger.message)]"
  }
}
