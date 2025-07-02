import Foundation

/// 세션 유형
enum RoomMode: String, CaseIterable, Identifiable {
    case oneToOne = "1:1"
    case group    = "1:N"
    var id: String { rawValue }

    /// 연결 정책
    var maxPeers: Int {
        switch self {
        case .oneToOne: return 1   // 자신 제외 1명
        case .group:    return 7   // Multipeer 최대(8)-1
        }
    }
}
