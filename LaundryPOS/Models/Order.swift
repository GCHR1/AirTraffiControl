import Foundation

struct Order: Identifiable, Codable {
    let id: String
    var status: OrderStatus
    let timestamp: Date
    
    enum OrderStatus: String, Codable {
        case pending
        case assigned
        case complete
    }
}
