//
//  InstabugLogger.swift
//  InstabugLogger
//
//  Created by Hassan El Desouky on 16/12/2020.
//  Copyright © 2020 Instabug. All rights reserved.
//

import Foundation
import CoreData

/// A logger framework that emits logs to the console, and keeps track of all of the emittied logs..
public final class InstabugLogger {

  private let loggerCoreDataManager: LoggerDataManager
  private let loggerQueueLabel = "com.Instabug.InstabugLoggerQueue"
  var destination: LoggerDestination

  let logsLimitPerSession = 5_000

  public static let shared = InstabugLogger()

  /// Initalize an InstabugLogger with the default `ConsoleDestination`.
  convenience init() {
    let consoleDestination = ConsoleDestination()
    let loggerCoreDataManager = LoggerDataManager()
    self.init(mainContext: loggerCoreDataManager.mainContext,
              backgroundContext: loggerCoreDataManager.backgroundContext,
              storeInMemory: false,
              destination: consoleDestination)
  }

  /// Internal `init` for testing.
  init(mainContext: NSManagedObjectContext,
       backgroundContext: NSManagedObjectContext, storeInMemory: Bool,
       destination: LoggerDestination) {
    self.destination = destination
    self.loggerCoreDataManager =
      LoggerDataManager(mainContext: mainContext,
                            backgroundContext: backgroundContext,
                            logsLimit: self.logsLimitPerSession,
                            storeInMemory: storeInMemory)
    self.loggerCoreDataManager.deleteAllLogs()
  }

  /// Set an InstabugLogger with a custome `LoggerDestination`
  /// - Parameters:
  ///   - destination: the LoggerDestination.
  public func set(destination: LoggerDestination) {
    self.destination = destination
  }

  /// Creates a `LoggerValue` from `message` and `level`, add it to the current session's loggers
  ///  array, and emit it to the `destination`.
  /// - Parameters:
  ///   - message: the log message which will be added to the loggers array
  ///   and emitted to the `destination`.
  ///   - level: the log level.
  public func log(_ message: @autoclosure () -> String,
                  level: LoggerValue.Level) {
    let logger = LoggerValue(level: level, message: message())
    self.loggerCoreDataManager.saveLog(logger)
    self.dispatchLog(logger: logger)
  }

  /// Creates a `verbose`-level logger with `message`, add it to the current session's loggers array,
  /// and emit it to the `destination`.
  /// - Parameter message: the log message which will be added to the loggers array
  /// and emitted to the `destination`.
  public func verbose(_ message: @autoclosure () -> String) {
    log(message(), level: .verbose)
  }

  /// Creates an `error`-level logger with `message`, add it to the current session's loggers array,
  /// and emit it to the `destination`.
  /// - Parameter message: the log message which will be added to the loggers array
  /// and emitted to the `destination`.
  public func error(_ message: @autoclosure () -> String) {
    log(message(), level: .error)
  }

  /// - Returns: all of the current session's logs as a `LoggerValue` array.
  public func fetchLogs() -> [LoggerValue] {
    var currentSessionLogs = [LoggerEntity]()
    currentSessionLogs = self.loggerCoreDataManager.fetchAllLogs()
    var loggers = [LoggerValue]()
    for log in currentSessionLogs {
      let logLevel = LoggerValue.Level(rawValue: Int(log.logLevel))!
      loggers.append(LoggerValue(level: logLevel, message: log.message!,
                                 date: log.creationDate!))
    }
    return loggers
  }

  /// - Returns: all of the current session's logs as an array of `String`s.
  public func fetchLogsStrings() -> [String] {
    var allLogs = [String]()
    for log in fetchLogs() {
      allLogs.append(destination.formatLog(logger: log))
    }
    return allLogs
  }
}

// MARK: - Dispatch Logs
extension InstabugLogger {
  /// Dispatches the `logger` to the `destination`'s queue.
  func dispatchLog(logger: LoggerValue) {
    guard let queue = destination.destinationQueue else { return }
    if destination.asynchronously {
      queue.async { [weak self] in
        _ = self?.destination.emit(logger: logger)
      }
    } else {
      queue.sync { [weak self] in
        _ = self?.destination.emit(logger: logger)
      }
    }
  }
}

// MARK: - Tests Helper
extension InstabugLogger {
  /// This method is for testing only, it will add the logger to the current session's loggers array,
  ///  and emit it to the `destination`.
  /// - Parameters:
  ///   - logger: the logger value
  func log(logger: LoggerValue) {
    self.loggerCoreDataManager.saveLog(logger)
    self.dispatchLog(logger: logger)
  }
}
