import Combine
import Foundation
import MultipeerConnectivity

/// 단일 세션을 관리하는 경량 래퍼
final class MPCSession: NSObject, ObservableObject {
    // MARK: - Public 상태

    @Published var connected: [MCPeerID] = []
    @Published var lastReceived: String = ""
    @Published var messages: [ChatMessage] = []
    @Published var foundPeers: [MCPeerID] = [] // ➊ 발견된 피어 목록

    // MARK: - 내부 프로퍼티

    private let serviceType = "mpc-demo" // ≤15byte 소문자·숫자·하이픈
    private let myID: MCPeerID
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!

    private let mode: RoomMode
    init(mode: RoomMode, displayName: String) {
        self.mode = mode
        myID = MCPeerID(displayName: displayName)
        super.init()

        session = MCSession(peer: myID, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: myID, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: myID, serviceType: serviceType)

        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self

        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }

    deinit {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
    }

    // MARK: - 송신 API

    func send(text: String) {
        guard !session.connectedPeers.isEmpty,
              let data = text.data(using: .utf8)
        else { return }
        // 본인 메시지도 추가
        let myMessage = ChatMessage(sender: myID.displayName, text: text, date: Date())
        DispatchQueue.main.async {
            self.messages.append(myMessage)
        }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }
}

// MARK: - Delegates

extension MPCSession: MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    // 상태 변경
    func session(_ session: MCSession, peer _: MCPeerID, didChange _: MCSessionState) {
        DispatchQueue.main.async { self.connected = session.connectedPeers }
    }

    // 데이터 수신
    func session(_: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let str = String(data: data, encoding: .utf8) else { return }
        let message = ChatMessage(sender: peerID.displayName, text: str, date: Date())
        DispatchQueue.main.async {
            self.lastReceived = "\(peerID.displayName): \(str)"
            self.messages.append(message)
        }
    }

    // 필요하지만 미사용
    func session(_: MCSession, didReceive _: InputStream, withName _: String, fromPeer _: MCPeerID) {}
    func session(_: MCSession, didStartReceivingResourceWithName _: String, fromPeer _: MCPeerID, with _: Progress) {}
    func session(_: MCSession, didFinishReceivingResourceWithName _: String, fromPeer _: MCPeerID, at _: URL?, withError _: Error?) {}

    // 브라우저: 피어 발견 시
    func browser(_: MCNearbyServiceBrowser, foundPeer pid: MCPeerID, withDiscoveryInfo _: [String: String]?) {
        switch mode {
        case .group:
            // 그룹 방은 기존 로직 유지
            browser.invitePeer(pid, to: session, withContext: nil, timeout: 10)
        case .oneToOne:
            // 1:1 방은 UI에서 사용자가 직접 초대하도록만 목록에 추가
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if !self.foundPeers.contains(pid) { self.foundPeers.append(pid) }
            }
        }
    }

    func browser(_: MCNearbyServiceBrowser, lostPeer pid: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            self?.foundPeers.removeAll(where: { $0 == pid })
        }
    }

    // MARK: - 수동 초대 API (UI에서 호출)

    func invite(_ peer: MCPeerID) {
        browser.invitePeer(peer, to: session, withContext: nil, timeout: 10)
    }

    // 광고자: 초대 수신 시
    func advertiser(_: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer _: MCPeerID,
                    withContext _: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void)
    {
        // 1:1방이면 이미 한 명과 연결 상태인지 확인
        let accept = connected.count < mode.maxPeers
        invitationHandler(accept, session)
    }

    // 시작 실패 로그(옵션)
    func advertiser(_: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) { print(error) }
    func browser(_: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) { print(error) }
}
