import SwiftUI

struct CycleView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    let orderID: String
    let machineID: String
    
    @State private var selectedTemperature = "Hot"
    @State private var selectedDuration = "30"
    @State private var showSuccess = false
    
    let temperatures = ["Hot", "Cold"]
    let durations = ["30", "45", "60"]
    
    var machine: Machine? {
        appState.machines.first { $0.id == machineID }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Order #\(orderID)")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    if let machine = machine {
                        Text(machine.name)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Temperature")
                            .font(.headline)
                        
                        Picker("Temperature", selection: $selectedTemperature) {
                            ForEach(temperatures, id: \.self) { temp in
                                Text(temp).tag(temp)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 150)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Duration")
                            .font(.headline)
                        
                        Picker("Duration", selection: $selectedDuration) {
                            ForEach(durations, id: \.self) { duration in
                                Text("\(duration) min").tag(duration)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 150)
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: startCycle) {
                    Text("Start Cycle")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Cycle Started!", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Machine will run for \(selectedDuration) minutes at \(selectedTemperature) temperature.")
            }
        }
    }
    
    private func startCycle() {
        HapticManager.shared.heavyVibrate()
        
        appState.updateMachineStatus(machineID, status: .cycling)
        appState.updateOrderStatus(orderID, status: .assigned)
        appState.currentHeldOrder = nil
        
        print("Cycle started: order=\(orderID), machine=\(machineID), temp=\(selectedTemperature), duration=\(selectedDuration)min")
        
        showSuccess = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            dismiss()
        }
    }
}

#Preview {
    CycleView(orderID: "101", machineID: "washer_01")
        .environmentObject(AppState())
}
