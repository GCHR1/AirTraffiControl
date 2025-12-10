import SwiftUI

struct PrinterConfigView: View {
    @Binding var isPresented: Bool
    var machine: Machine?
    var onPrinterConfigured: ((Machine, String) -> Void)?
    
    @State private var printerIP = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Configure Printer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Enter the IP address of your ESC/POS printer")
                    .font(.body)
                    .foregroundColor(.gray)
                
                TextField("Printer IP Address", text: $printerIP)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    if !printerIP.isEmpty, let machine = machine {
                        onPrinterConfigured?(machine, printerIP)
                        isPresented = false
                    }
                }) {
                    Text("Configure & Print")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(printerIP.isEmpty)
                .padding()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    PrinterConfigView(
        isPresented: .constant(true),
        machine: Machine(id: "washer_01", name: "Washer 1", status: .inactive)
    )
}
