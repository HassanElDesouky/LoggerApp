# LoggerApp
InstabugLogger is a logger framework task that's a part of Instabug's hiring process.

## Getting started

### Installation

First, you will need to clone the repo and compile the library, then you will need to drag it to your own project.

### Usage

```swift
// 1) Let's import the logging API package.
import InstabugLogger

// 2) We need to create a logger.
let logger = InstabugLogger.shared

// 3) We're now ready to use it.
logger.log("Error message!", level: .error)
```

### Output

```
[2020-12-22 23:14:12.9500 - ERROR - Error message!]
```

## Documentation

- Log levels:
  - `verbose`
  - `error`
- Message formats are defined based on the `LoggerDestination` and the default format is:
  `[Date - Log level - message]`
- To log a message you can log it directly via a log level or by using `log` and providing a level.
  For example:
  `logger.log("Error message!", level: .error)` and `logger.error("Error message")`
- To retrieve all messages in the session you can use:
  - `fetchLogs()` which returns a `LoggerValue` array sorted by the log creation date.
  - `fetchLogsStrings()` which returns a formatted strings array sorted by the log creation date.
- To create your own `LoggerDestination` you would have to subclass `LoggerDestination`. Then you can override the `emit` method and customize your `formatLog`. Finally, to use it, simply set the logger destination with `InstabugLogger.shared.set(_LoggerDestination_)`

## Done / Todo

- [x] Framework should have an interface for log method that receives a log message and log level (Error or Verbose).

- [x] Framework should have an interface for fetch method that returns all logs sorted by date.

- [x] Each log message should not exceed 1K characters if it exceeds the limit you need to add three dots after the 1K characters.

- [x] Logs limit per session is 5K.

- [x] Every launch you need to clear logs from the previous session.

- [x] Logger should not affect the main thread.

- [x] Logs should be formatted as follows `[Date - Log level - message]`

- [x] Over **94%** code coverage.

- [x] Provide documentation (in code and in GitHub's `README.md`)

- [x] Design the framework to be a reusable component.

