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
  let destination: LoggerDestination
  let loggerQueue: DispatchQueue

  let logsLimitPerSession = 5_000

  /// Initalize an InstabugLogger with an `identifier` and a custome `LoggerDestination`
  /// - Parameters:
  ///   - identifier: the InstabugLogger session identifier.
  ///   - destination: the LoggerDestination.
  convenience public init(destination: LoggerDestination) {
    let loggerCoreDataManager = LoggerDataManager()
    self.init(mainContext: loggerCoreDataManager.mainContext,
              backgroundContext: loggerCoreDataManager.backgroundContext,
              destination: destination, forTesting: false)
  }

  /// Initalize an InstabugLogger with an `identifier` and with the default `ConsoleDestination`.
  /// - Parameters:
  ///   - identifier: InstabugLogger session identifier
  convenience public init() {
    let consoleDestination = ConsoleDestination()
    self.init(destination: consoleDestination)
  }

  /// Internal `init` for testing.
  init(mainContext: NSManagedObjectContext,
       backgroundContext: NSManagedObjectContext,
       destination: LoggerDestination,
       forTesting: Bool = true) {
    self.destination = destination
    self.loggerQueue = DispatchQueue(label: loggerQueueLabel,
                                     attributes: .concurrent)
    self.loggerCoreDataManager =
      LoggerDataManager(mainContext: mainContext,
                            backgroundContext: backgroundContext,
                            logsLimit: self.logsLimitPerSession)
    if forTesting {
      self.loggerCoreDataManager.deleteAllLogsForTests()
    } else {
      self.loggerCoreDataManager.deleteAllLogs()
    }
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
    loggerQueue.async(flags: .barrier) { [weak self] in
      guard let self = self else {
        return
      }
      self.loggerCoreDataManager.saveLog(logger)
      self.dispatchLog(logger: logger)
    }
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
  /// - Throws: a `LoggerSessionError.logsPerSessionExceed` if current logs in the session
  /// excedes _5,000_ logs.
  func log(logger: LoggerValue) {
    loggerQueue.async(flags: .barrier) { [weak self] in
      guard let self = self else {
        return
      }
      self.loggerCoreDataManager.saveLog(logger)
      self.dispatchLog(logger: logger)
    }
  }
}
