import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingMachineSetup = false
    
    var body: some View {
        NavigationStack {
            VStack {
                FloorModeView()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingMachineSetup = true }) {
                        Text("Setup")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingMachineSetup) {
                MachineSetupView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
