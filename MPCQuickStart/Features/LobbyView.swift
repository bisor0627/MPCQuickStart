import SwiftUI

/// 방 유형 선택 & 입장
struct LobbyView: View {
    @State private var selection: RoomMode?
    var body: some View {
        VStack(spacing: 40) {
            Text("📡 근거리 방 만들기").font(.headline)
            ForEach(RoomMode.allCases) { mode in
                Button {
                    selection = mode
                } label: {
                    Text(mode.rawValue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor.opacity(0.15))
                        .cornerRadius(12)
                }
            }
            .buttonStyle(.plain)
        }
        .padding()
        .navigationDestination(isPresented: Binding(
            get: { selection != nil },
            set: { if !$0 { selection = nil } })
        ) {
            if let mode = selection {
                ChatRoomView(mode: mode)
            }
        }
    }
}
