import SwiftUI

/// 연결 후 간단한 채팅 데모
struct ChatRoomView: View {
    @ObservedObject private var mpc: MPCSession
    @State private var input = ""

    init(mode: RoomMode) { _mpc = ObservedObject(wrappedValue: MPCSession(mode: mode)) }

    var body: some View {
        VStack {
            Text("연결된 기기: \(mpc.connected.count)")
                .font(.caption)
                .padding(.top)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(mpc.messages) { msg in
                            HStack(alignment: .top) {
                                Text(msg.sender)
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    Text(msg.text)
                                        .font(.body)
                                    Text(msg.date, style: .time)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                            .id(msg.id)
                        }
                    }
                    .padding()
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding()
                .onChange(of: mpc.messages.count) { _ in
                    if let last = mpc.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            HStack {
                TextField("메시지 입력", text: $input)
                    .textFieldStyle(.roundedBorder)
                Button("보내기") {
                    mpc.send(text: input)
                    input = ""
                }
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle(mpc.connected.isEmpty ? "대기 중…" : "세션 활성")
        .navigationBarTitleDisplayMode(.inline)
    }
}
