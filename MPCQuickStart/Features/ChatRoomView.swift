import MultipeerConnectivity
import SwiftUI

/// 연결 후 간단한 채팅 데모
struct ChatRoomView: View {
    let userName: String
    @ObservedObject private var mpc: MPCSession
    @State private var input = ""
    private let mode: RoomMode

    init(mode: RoomMode, userName: String) {
        self.userName = userName
        self.mode = mode
        _mpc = ObservedObject(wrappedValue: MPCSession(mode: mode, displayName: userName))
    }

    var body: some View {
        VStack {
            // ➋ 1:1 모드 – 아직 연결 전이라면 카드 목록 표시
            if mode == .oneToOne && mpc.connected.isEmpty {
                discoverSection
            } else {
                connectionStatusHeader
                chatSection
            }
        }
        .navigationTitle(titleText)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 하위 View 빌더

    @ViewBuilder private var discoverSection: some View {
        VStack(spacing: 16) {
            if mpc.foundPeers.isEmpty {
                ProgressView("주변 기기 검색 중…").padding(.top)
            } else {
                Text("주변 기기를 선택하여 세션을 요청하세요").font(.caption)
                ScrollView {
                    LazyVGrid(columns: [.init(.adaptive(minimum: 120), spacing: 16)]) {
                        ForEach(mpc.foundPeers, id: \.self) { peer in
                            PeerCard(peer: peer) {
                                mpc.invite(peer) // ➌ 초대 전송
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .padding()
    }

    @ViewBuilder private var connectionStatusHeader: some View {
        if !mpc.connected.isEmpty {
            let names = mpc.connected.map(\.displayName).joined(separator: ", ")
            Text("연결된 사람: \(names)")
                .font(.caption).padding(.top)
        } else {
            Text("연결된 사람 없음").font(.caption).padding(.top)
        }
    }

    @ViewBuilder private var chatSection: some View {
        // ▼ 기존 채팅 UI 그대로 이동
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

    private var titleText: String {
        if mode == .oneToOne && mpc.connected.isEmpty {
            return "1:1 연결 준비"
        } else {
            return mpc.connected.isEmpty ? "대기 중…" : "세션 활성"
        }
    }
}

// MARK: - Peer Card 컴포넌트

private struct PeerCard: View {
    let peer: MCPeerID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "person.crop.circle")
                    .resizable().scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.accentColor)
                Text(peer.displayName)
                    .font(.footnote).multilineTextAlignment(.center)
            }
            .padding()
            .frame(width: 120, height: 150)
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}
