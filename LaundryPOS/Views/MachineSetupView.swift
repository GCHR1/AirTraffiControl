import SwiftUI

struct MachineSetupView: View {
    @EnvironmentObject var appState: AppState
    @State private var showPrinterConfig = false
    @State private var selectedMachine: Machine?
    @State private var isScanning = false
    @State private var printerIP = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Machine Setup")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                List {
                    ForEach(appState.machines) { machine in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(machine.name)
                                    .font(.headline)
                                Text(machine.status.rawValue.capitalized)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                selectedMachine = machine
                                showPrinterConfig = true
                            }) {
                                Text("Setup")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .sheet(isPresented: $showPrinterConfig) {
                PrinterConfigView(
                    isPresented: $showPrinterConfig,
                    machine: selectedMachine,
                    onPrinterConfigured: { machine, ip in
                        appState.printerConfig.ip = ip
                        setupMachineWithPrinter(machine: machine, ip: ip)
                    }
                )
            }
            .alert("Setup", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("success") {
                        isScanning = true
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func setupMachineWithPrinter(machine: Machine, ip: String) {
        guard !ip.isEmpty else {
            alertMessage = "Please enter a printer IP address"
            showAlert = true
            return
        }
        
        Task {
            do {
                if let qrJson = QRCodeGenerator.shared.createQRData(type: "machine", id: machine.id) {
                    try await PrinterService.shared.printQRCode(data: qrJson, to: ip)
                    
                    alertMessage = "Print sent successfully! Now scan the QR code."
                    showAlert = true
                    
                    appState.updateMachineStatus(machine.id, status: .active)
                }
            } catch {
                alertMessage = "Print failed: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}

#Preview {
    MachineSetupView()
        .environmentObject(AppState())
}
