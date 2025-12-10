import UIKit
import Vision

class QRCodeGenerator {
    static let shared = QRCodeGenerator()
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            
            if let ciImage = filter.outputImage {
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let scaledCIImage = ciImage.transformed(by: transform)
                
                let context = CIContext()
                if let cgImage = context.createCGImage(scaledCIImage, from: scaledCIImage.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        
        return nil
    }
    
    func createQRData(type: String, id: String) -> String? {
        let qrData = QRData(type: type, id: id)
        if let jsonData = try? JSONEncoder().encode(qrData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return nil
    }
}
