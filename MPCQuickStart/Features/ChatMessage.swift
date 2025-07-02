import Foundation

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let sender: String
    let text: String
    let date: Date
}
