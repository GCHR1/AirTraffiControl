import Foundation

class PrinterService {
    static let shared = PrinterService()
    
    func printQRCode(data: String, to ip: String) async throws {
        guard !ip.isEmpty else {
            print("Printer IP is empty")
            throw PrinterError.invalidIP
        }
        
        let printerPort = 9100
        let timeout: TimeInterval = 5.0
        
        print("Attempting to print to printer at \(ip):\(printerPort)")
        print("QR data: \(data)")
        
        do {
            let escapeCodes = generateESCPOSQRCode(data: data)
            
            let (stream, _) = try await URLSession.shared.bytes(from: URL(string: "http://\(ip):\(printerPort)")!)
            
            print("Connected to printer successfully")
            print("Printer connection established")
        } catch {
            print("Failed to connect to printer: \(error.localizedDescription)")
            throw PrinterError.connectionFailed(error)
        }
    }
    
    private func generateESCPOSQRCode(data: String) -> [UInt8] {
        var commands: [UInt8] = []
        
        commands.append(27)
        commands.append(64)
        
        commands.append(contentsOf: [0x1D, 0x28, 0x4B])
        
        return commands
    }
}

enum PrinterError: Error {
    case invalidIP
    case connectionFailed(Error)
    case timeout
    case unknown(String)
}
