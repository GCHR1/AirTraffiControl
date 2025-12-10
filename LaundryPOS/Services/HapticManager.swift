import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    func vibrate(pattern: [Int]) {
        for duration in pattern {
            let feedback = UIImpactFeedbackGenerator(style: .heavy)
            feedback.impactOccurred()
            Thread.sleep(forTimeInterval: TimeInterval(duration) / 1000.0)
        }
    }
    
    func heavyVibrate() {
        let feedback = UIImpactFeedbackGenerator(style: .heavy)
        feedback.impactOccurred()
    }
    
    func lightVibrate() {
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
    }
}
