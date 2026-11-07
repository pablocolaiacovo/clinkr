import os

/// One subsystem for both apps, so Console.app shows the iPhone and the Watch with the same filter. Mark user-entered
/// text, like a night's name, `privacy: .private`; ids, counts and drink types can be `.public`.
extension Logger {
    private static let subsystem = "com.colaiacovo.clinkr"

    static let sync = Logger(subsystem: subsystem, category: "sync")
    static let persistence = Logger(subsystem: subsystem, category: "persistence")
    static let nudge = Logger(subsystem: subsystem, category: "nudge")
    static let lifecycle = Logger(subsystem: subsystem, category: "lifecycle")
    static let metrics = Logger(subsystem: subsystem, category: "metrics")
}
