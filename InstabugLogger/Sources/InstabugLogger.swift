//
//  InstabugLogger.swift
//  InstabugLogger
//
//  Created by Hassan El Desouky on 16/12/2020.
//  Copyright © 2020 Instabug. All rights reserved.
//

import Foundation

/// A logger framework that emits logs to the console, and keeps track of all of the emittied logs..
public final class InstabugLogger {

  enum LoggerSessionError: Error {
    case logsPerSessionExceed
  }
  private let logsLimitPerSession = 5_000

  private let destination: LoggerDestination

  private let loggerQueueLabel = "com.Instabug.InstabugLoggerQueue"
  private let loggerQueue: DispatchQueue!

  private var unsafeLoggers: [LoggerValue] = []
  private var loggers: [LoggerValue] {
    var safeLoggers: [LoggerValue]!
    loggerQueue.sync { [weak self] in
      safeLoggers = self?.unsafeLoggers
    }
    return safeLoggers
  }

  let identifier: String

  /// Initalize an InstabugLogger with an `identifier` and a custome `LoggerDestination`
  /// - Parameters:
  ///   - identifier: the InstabugLogger session identifier.
  ///   - destination: the LoggerDestination.
  public init(identifier: String, destination: LoggerDestination) {
    // TODO: Clear logs from previous session.

    self.identifier = identifier
    self.destination = destination
    self.loggerQueue = DispatchQueue(label: loggerQueueLabel,
                                     attributes: .concurrent)
  }

  /// Initalize an InstabugLogger with an `identifier` and with the default `ConsoleDestination`.
  /// - Parameters:
  ///   - identifier: InstabugLogger session identifier
  convenience public init(identifier: String) {
    let consoleDestination = ConsoleDestination(identifier: identifier)
    self.init(identifier: identifier, destination: consoleDestination)
  }

  /// Creates a `LoggerValue` from `message` and `level`, add it to the current session's loggers
  ///  array, and emit it to the `destination`.
  /// - Parameters:
  ///   - message: the log message which will be added to the loggers array
  ///   and emitted to the `destination`.
  ///   - level: the log level
  /// - Throws: a `LoggerSessionError.logsPerSessionExceed` if current logs in the session
  /// excedes _5,000_ logs.
  public func log(_ message: @autoclosure () -> String,
                  level: LoggerValue.Level) throws {
    if loggers.count > logsLimitPerSession {
      throw LoggerSessionError.logsPerSessionExceed
    }

    let logger = LoggerValue(level: level, message: message())
    loggerQueue.async(flags: .barrier) { [weak self] in
      guard let self = self else {
        return
      }
      self.unsafeLoggers.append(logger)

      self.dispatchLog(logger: logger)
    }
  }

  /// Creates a `verbose`-level logger with `message`, add it to the current session's loggers array,
  /// and emit it to the `destination`.
  /// - Parameter message: the log message which will be added to the loggers array
  /// and emitted to the `destination`.
  /// - Throws: a `LoggerSessionError.logsPerSessionExceed` if current logs in the session
  /// excedes _5,000_ logs.
  public func verbose(_ message: @autoclosure () -> String) throws {
    do {
      try log(message(), level: .verbose)
    } catch LoggerSessionError.logsPerSessionExceed {
      throw LoggerSessionError.logsPerSessionExceed
    }
  }

  /// Creates an `error`-level logger with `message`, add it to the current session's loggers array,
  /// and emit it to the `destination`.
  /// - Parameter message: the log message which will be added to the loggers array
  /// and emitted to the `destination`.
  /// - Throws: a `LoggerSessionError.logsPerSessionExceed` if current logs in the session
  /// excedes _5,000_ logs.
  public func error(_ message: @autoclosure () -> String) throws {
    do {
      try log(message(), level: .error)
    } catch LoggerSessionError.logsPerSessionExceed {
      throw LoggerSessionError.logsPerSessionExceed
    }
  }

  /// - Returns: all of the current session's logs as a `LoggerValue` array.
  public func fetchLogs() -> [LoggerValue] {
    return loggers
  }

  /// - Returns: all of the current session's logs as an array of `String`s.
  public func fetchLogsStrings() -> [String] {
    var allLogs = [String]()
    for log in loggers {
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
  func log(logger: LoggerValue) throws {
    if loggers.count > logsLimitPerSession {
      throw LoggerSessionError.logsPerSessionExceed
    }

    loggerQueue.async(flags: .barrier) { [weak self] in
      self?.unsafeLoggers.append(logger)

      self?.dispatchLog(logger: logger)
    }
  }
}
