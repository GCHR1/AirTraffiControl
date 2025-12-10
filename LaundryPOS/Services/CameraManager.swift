import AVFoundation
import Vision

class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var isAuthorized = false
    @Published var detectedQRData: QRData?
    @Published var detectedQRString: String?
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    private var cameraAuthorizationStatus: AVAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        checkCameraAuthorization()
    }
    
    private func checkCameraAuthorization() {
        cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .authorized:
            DispatchQueue.main.async {
                self.isAuthorized = true
                self.setupCamera()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.isAuthorized = false
            }
        @unknown default:
            DispatchQueue.main.async {
                self.isAuthorized = false
            }
        }
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get back camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video_queue"))
            output.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)
            ]
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            self.captureSession = session
            session.startRunning()
            print("Camera setup complete - back camera only")
        } catch {
            print("Failed to setup camera: \(error)")
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let request = VNDetectBarcodesRequest { [weak self] request, error in
            guard let results = request.results as? [VNBarcodeObservation] else {
                return
            }
            
            for barcode in results {
                if barcode.barcodeDescriptor is CIQRCodeDescriptor,
                   let payload = barcode.payloadStringValue {
                    print("QR Code detected: \(payload)")
                    DispatchQueue.main.async {
                        self?.detectedQRString = payload
                        if let qrData = try? JSONDecoder().decode(QRData.self, from: payload.data(using: .utf8)!) {
                            self?.detectedQRData = qrData
                        }
                    }
                    return
                }
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    func stopSession() {
        captureSession?.stopRunning()
    }
    
    func startSession() {
        captureSession?.startRunning()
    }
}
