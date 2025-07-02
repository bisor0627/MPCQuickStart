# 🌱 MPCQuickStart

> MultipeerConnectivity(MPC) 기반의 iOS P2P 채팅 예제 – SwiftUI와 Combine을 활용하여, 로컬 네트워크에서 여러 기기가 실시간으로 채팅할 수 있는 구조와 코드를 제공합니다.


[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)]()
[![Xcode](https://img.shields.io/badge/Xcode-15.0-blue.svg)]()
[![License](https://img.shields.io/badge/license-MIT-green.svg)]()

---

## 💡 프로젝트 동기

MultipeerConnectivity(MPC)는 별도의 서버 없이 로컬 네트워크에서 여러 기기가 직접 통신할 수 있는 강력한 프레임워크입니다. SwiftUI와 Combine을 활용해, 실시간 상태 관리와 P2P 채팅 구조를 학습하고자 본 프로젝트를 시작했습니다.

## 📌 목표

- iOS에서 MultipeerConnectivity(MPC) 기본 구조 및 활용법 습득
- 실습/도입을 위한 최소한의 예제 코드 제공
- 네트워크 없이 여러 기기 간 채팅 경험 제공

## ⚙️ 개발 환경

- Xcode 15.0 / iOS 17.0
- Swift 5.9
- MultipeerConnectivity.framework

## 🧩 주요 구현 기능

- [x] 1:1 및 1:N(그룹) 채팅 세션 생성 및 참여
- [x] 실시간 메시지 송수신 및 리스트 표시
- [x] 연결된 기기 목록 및 상태 표시
- [x] SwiftUI 기반의 직관적 UI
- [ ] (To-do) 메시지 영속화, 푸시 알림 등

## ⚙️ 설치 및 실행

```bash
git clone https://github.com/yourname/MPCQuickStart.git
open MPCQuickStart/MPCQuickStart.xcodeproj
```

- 두 대 이상의 iOS 기기(또는 시뮬레이터)에서 각각 빌드 및 실행
- 동일 네트워크(와이파이/블루투스) 환경 필요

## 🔍 프로젝트 구조
```
MPCQuickStart/
 ┣ Features/
 ┃ ┣ ChatRoomView.swift
 ┃ ┣ LobbyView.swift
 ┃ ┗ RoomMode.swift
 ┣ MPC/
 ┃ ┗ MPCSession.swift
 ┣ Assets.xcassets/
 ┣ MPCQuickStartApp.swift
 ┗ ...
```

## 📝 추후 개선 사항

- [ ] 메시지 영속화(로컬 저장)
- [ ] 유저간 식별을 위한 Profile
- [ ] 광고&검색 On/Off 토글


## 📝 License

This project is licensed under the [LICENSE](./LICENSE)