import SwiftUI

struct FloorModeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showScanner = false
    @State private var showOrderAlert = false
    @State private var showMachineStatus = false
    @State private var selectedMachine: Machine?
    @State private var showSettings = false
    @State private var navigationPath = NavigationPath()
    
    var activeMachineCount: Int {
        appState.machines.filter { $0.status == .active || $0.status == .cycling }.count
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Active Machines")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(activeMachineCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Spacer()
                        
                        Menu {
                            Button(action: { appState.resetDemo() }) {
                                Label("Reset Demo", systemImage: "arrow.counterclockwise")
                            }
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                                .padding(12)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Button(action: { showScanner = true }) {
                            Text("Scan QR Code")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        if appState.currentHeldOrder != nil {
                            HStack {
                                Image(systemName: "bell.fill")
                                Text("Order #\(appState.currentHeldOrder!.id) held - scan a machine")
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color.yellow.opacity(0.3))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                }
                .ignoresSafeArea()
                
                if showScanner {
                    QRScannerView(onScan: handleQRScan)
                        .transition(.move(edge: .leading))
                }
            }
            .navigationDestination(for: String.self) { machineID in
                if let order = appState.currentHeldOrder {
                    CycleView(orderID: order.id, machineID: machineID)
                }
            }
            .alert("Order Scanned", isPresented: $showOrderAlert) {
                Button("OK") {}
            } message: {
                if let order = appState.currentHeldOrder {
                    Text("Order #\(order.id) scanned. Walk to a machine and scan it.")
                }
            }
            .alert("Machine Status", isPresented: $showMachineStatus) {
                Button("OK") {}
            } message: {
                if let machine = selectedMachine {
                    Text("\(machine.name) - \(machine.status.rawValue.capitalized)")
                }
            }
        }
    }
    
    private func handleQRScan(_ qrData: QRData) {
        showScanner = false
        
        switch qrData.type {
        case "order":
            if let order = appState.orders.first(where: { $0.id == qrData.id }) {
                appState.currentHeldOrder = order
                print("Order #\(order.id) held")
                showOrderAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showOrderAlert = false
                }
            }
            
        case "machine":
            if let machine = appState.machines.first(where: { $0.id == qrData.id }) {
                if let heldOrder = appState.currentHeldOrder {
                    navigationPath.append(machine.id)
                } else {
                    selectedMachine = machine
                    showMachineStatus = true
                }
            }
            
        default:
            print("Unknown QR type: \(qrData.type)")
        }
    }
}

#Preview {
    FloorModeView()
        .environmentObject(AppState())
}
