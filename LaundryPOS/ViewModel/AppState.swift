import Foundation

class AppState: ObservableObject {
    @Published var machines: [Machine] = []
    @Published var orders: [Order] = []
    @Published var currentHeldOrder: Order?
    @Published var printerConfig: PrinterConfig {
        didSet {
            savePrinterConfig()
        }
    }
    
    private let machinesKey = "machines"
    private let ordersKey = "orders"
    private let printerIPKey = "printerIP"
    private let hasInitializedKey = "hasInitialized"
    
    init() {
        self.printerConfig = PrinterConfig()
        loadPrinterConfig()
        
        let hasInitialized = UserDefaults.standard.bool(forKey: hasInitializedKey)
        if !hasInitialized {
            setupDemoData()
            UserDefaults.standard.set(true, forKey: hasInitializedKey)
        } else {
            loadData()
        }
    }
    
    private func setupDemoData() {
        self.machines = [
            Machine(id: "washer_01", name: "Washer 1", status: .inactive),
            Machine(id: "washer_02", name: "Washer 2", status: .inactive),
            Machine(id: "washer_03", name: "Washer 3", status: .inactive),
            Machine(id: "dryer_01", name: "Dryer 1", status: .inactive),
            Machine(id: "dryer_02", name: "Dryer 2", status: .inactive),
        ]
        
        self.orders = [
            Order(id: "101", status: .pending, timestamp: Date()),
            Order(id: "102", status: .pending, timestamp: Date()),
            Order(id: "103", status: .pending, timestamp: Date()),
        ]
        
        saveMachines()
        saveOrders()
    }
    
    private func loadData() {
        if let machineData = UserDefaults.standard.data(forKey: machinesKey),
           let machines = try? JSONDecoder().decode([Machine].self, from: machineData) {
            self.machines = machines
        }
        
        if let orderData = UserDefaults.standard.data(forKey: ordersKey),
           let orders = try? JSONDecoder().decode([Order].self, from: orderData) {
            self.orders = orders
        }
    }
    
    private func saveMachines() {
        if let data = try? JSONEncoder().encode(machines) {
            UserDefaults.standard.set(data, forKey: machinesKey)
        }
    }
    
    private func saveOrders() {
        if let data = try? JSONEncoder().encode(orders) {
            UserDefaults.standard.set(data, forKey: ordersKey)
        }
    }
    
    private func savePrinterConfig() {
        UserDefaults.standard.set(printerConfig.ip, forKey: printerIPKey)
    }
    
    private func loadPrinterConfig() {
        if let savedIP = UserDefaults.standard.string(forKey: printerIPKey) {
            printerConfig.ip = savedIP
        }
    }
    
    func updateMachineStatus(_ machineID: String, status: Machine.MachineStatus) {
        if let index = machines.firstIndex(where: { $0.id == machineID }) {
            machines[index].status = status
            saveMachines()
        }
    }
    
    func updateOrderStatus(_ orderID: String, status: Order.OrderStatus) {
        if let index = orders.firstIndex(where: { $0.id == orderID }) {
            orders[index].status = status
            saveOrders()
        }
    }
    
    func resetDemo() {
        currentHeldOrder = nil
        
        machines = machines.map { machine in
            var updated = machine
            updated.status = .inactive
            return updated
        }
        
        orders = orders.map { order in
            var updated = order
            updated.status = .pending
            return updated
        }
        
        saveMachines()
        saveOrders()
        
        print("Demo reset: all machines inactive, all orders pending")
    }
}
