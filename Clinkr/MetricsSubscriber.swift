import MetricKit
import os

/// Logs the reports iOS delivers about once a day (launch time, hangs, battery use, crashes) under `metrics`. Nothing
/// leaves the device. MetricKit isn't available on watchOS.
final class MetricsSubscriber: NSObject, MXMetricManagerSubscriber, Sendable {
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            Logger.metrics.info("Metrics: \(Self.json(payload.jsonRepresentation()), privacy: .public)")
        }
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            let crashes = payload.crashDiagnostics?.count ?? 0
            let hangs = payload.hangDiagnostics?.count ?? 0
            let json = Self.json(payload.jsonRepresentation())
            Logger.metrics.info("Diagnostics: \(crashes) crashes, \(hangs) hangs: \(json, privacy: .public)")
        }
    }

    private static func json(_ data: Data) -> String {
        String(decoding: data, as: UTF8.self)
    }
}
