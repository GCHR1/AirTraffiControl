import Foundation

struct PrinterConfig: Codable {
    var ip: String
    let port: Int
    let connectionTimeout: TimeInterval
    
    init(ip: String = "", port: Int = 9100, connectionTimeout: TimeInterval = 5.0) {
        self.ip = ip
        self.port = port
        self.connectionTimeout = connectionTimeout
    }
}
