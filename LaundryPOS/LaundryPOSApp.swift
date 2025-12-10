import SwiftUI
import Darwin

@main
struct LaundryPOSApp: App {
    @StateObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    logLocalNetworkInfo()
                }
        }
    }
    
    private func logLocalNetworkInfo() {
        if let localIP = getLocalIPAddress() {
            print("Access app on local network at: http://\(localIP):3000")
        }
    }
    
    private func getLocalIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        defer { freeifaddrs(ifaddr) }
        
        var ptr = ifaddr
        while ptr != nil {
            let flags = Int32(ptr?.pointee.ifa_flags ?? 0)
            let addr = ptr?.pointee.ifa_addr?.pointee
            
            if let addr = addr, (flags & (IFF_UP|IFF_RUNNING)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == sa_family_t(AF_INET) {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(ptr?.pointee.ifa_addr, socklen_t(addr.sa_len),
                               &hostname, socklen_t(hostname.count),
                               nil, 0, NI_NUMERICHOST)
                    let ipString = String(cString: hostname)
                    if ipString != "127.0.0.1" {
                        address = ipString
                        break
                    }
                }
            }
            ptr = ptr?.pointee.ifa_next
        }
        return address
    }
}
