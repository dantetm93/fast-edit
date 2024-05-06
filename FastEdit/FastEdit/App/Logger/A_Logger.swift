//
//  A_Logger.swift
//  FastEdit
//
//  Created by Tran Manh Quy on 6/5/24.
//

import Foundation

public enum LoggerType: String {
    case debug = "DEBUG", info = "INFO",
         error = "ERROR", warning = "WARNING"
}

public class AppLogger {
    /**
     Write log about [DEBUG]
     * file = #fileID
     * line = #line
     */
    public static func d(_ tag: String, _ message: String, _ file: String, _ line: Int) {
        log(LoggerType.debug, tag, message, file, line)
    }
    /**
     Write log about [INFO]
     * file = #fileID
     * line = #line
     */
    public static func i(_ tag: String, _ message: String, _ file: String, _ line: Int) {
        log(LoggerType.info, tag, message, file, line)
    }
    /**
     Write log about [ERROR]
     * file = #fileID
     * line = #line
     */
    public static func error(_ tag: String, _ message: String, _ file: String, _ line: Int) {
        log(LoggerType.error, tag, message, file, line)
    }

    /**
     Write log about [WARNING]
     * file = #fileID
     * line = #line
     */
    public static func warning(_ tag: String, _ message: String, _ file: String, _ line: Int) {
        log(LoggerType.warning, tag, message, file, line)
    }
    
    private static func log(_ type: LoggerType = .debug, _ tag: String, _ message: String, _ file: String, _ line: Int) {
#if LOGGING
        print("\(Date()): \(file):\(line) [\(type.rawValue)][\(tag)]: \"\(message)\"")
#endif
    }
}
