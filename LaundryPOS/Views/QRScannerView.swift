import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @StateObject var cameraManager = CameraManager()
    @State private var showSimulateMenu = false
    var onScan: (QRData) -> Void
    
    var body: some View {
        ZStack {
            CameraPreview(cameraManager: cameraManager)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Scan QR Code")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding()
                .background(Color.black.opacity(0.3))
                
                Spacer()
                
                VStack(spacing: 12) {
                    if !cameraManager.isAuthorized {
                        Text("Camera access denied. Use Simulate Scan button.")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    Menu {
                        Button("Order #101") {
                            simulateScan(type: "order", id: "101")
                        }
                        Button("Order #102") {
                            simulateScan(type: "order", id: "102")
                        }
                        Button("Order #103") {
                            simulateScan(type: "order", id: "103")
                        }
                        Button("Washer 1") {
                            simulateScan(type: "machine", id: "washer_01")
                        }
                        Button("Washer 2") {
                            simulateScan(type: "machine", id: "washer_02")
                        }
                        Button("Dryer 1") {
                            simulateScan(type: "machine", id: "dryer_01")
                        }
                    } label: {
                        Text("Simulate Scan")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding()
                }
                .background(Color.black.opacity(0.3))
            }
        }
        .onChange(of: cameraManager.detectedQRData) { oldValue, newValue in
            if let qrData = newValue {
                print("QR scanned: type=\(qrData.type), id=\(qrData.id)")
                onScan(qrData)
            }
        }
    }
    
    private func simulateScan(type: String, id: String) {
        let qrData = QRData(type: type, id: id)
        print("Simulated QR scan: type=\(type), id=\(id)")
        onScan(qrData)
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        if let session = cameraManager.captureSession {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
            DispatchQueue.main.async {
                previewLayer.frame = view.bounds
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

#Preview {
    QRScannerView(onScan: { _ in })
}
