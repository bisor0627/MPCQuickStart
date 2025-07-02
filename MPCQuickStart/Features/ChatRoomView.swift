import SwiftUI

/// 연결 후 간단한 채팅 데모
struct ChatRoomView: View {
    let userName: String
    @ObservedObject private var mpc: MPCSession
    @State private var input = ""

    init(mode: RoomMode, userName: String) {
        self.userName = userName
        _mpc = ObservedObject(wrappedValue: MPCSession(mode: mode, displayName: userName))
    }

    var body: some View {
        VStack {
            Text("연결된 기기: \(mpc.connected.count)")
                .font(.caption)
                .padding(.top)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(mpc.messages) { msg in
                            let isMine = msg.sender == userName
                            HStack(alignment: .top) {
                                if isMine { Spacer() }
                                VStack(alignment: isMine ? .trailing : .leading) {
                                    HStack(alignment: .bottom, spacing: 4) {
                                        if !isMine {
                                            Text(msg.sender)
                                                .font(.caption2)
                                                .foregroundColor(.blue)
                                        }
                                        Text(msg.text)
                                            .font(.body)
                                            .padding(8)
                                            .background(isMine ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.15))
                                            .cornerRadius(10)
                                            .foregroundColor(.primary)
                                        if isMine {
                                            Text("나")
                                                .font(.caption2)
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                    Text(msg.date, style: .time)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: isMine ? .trailing : .leading)
                                }
                                .frame(maxWidth: 220, alignment: isMine ? .trailing : .leading)
                                if !isMine { Spacer() }
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
