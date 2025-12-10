import Foundation

struct Machine: Identifiable, Codable {
    let id: String
    let name: String
    var status: MachineStatus
    
    enum MachineStatus: String, Codable {
        case inactive
        case active
        case cycling
    }
}
