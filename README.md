# NearTalk

<p align="center"><img src="/images/nearTalkLogo.png" width="250"></p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=Swift&logoColor=white"/>
  <img src="https://img.shields.io/badge/UIkit-2396F3?style=for-the-badge&logo=iOS&logoColor=white"/>
  <img src="https://img.shields.io/badge/RxSwift-8D1F89?style=for-the-badge&logo=ReactiveX&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=Firebase&logoColor=white"/>
</p>

> 근처에 있는 사람들과 실시간 소통할 수 있는 메신저 앱 "NeakTalk(근방톡)" 입니다.
> 
> 개발 기간: 2022.11.07 ~ 2022.12.16

## 프로젝트 소개
> 💫 근방에서 금방 만나요, 근방톡 💫

- 실시간 위치 기반으로 근처에 있는 오픈 그룹 채팅방에 입장하고, 다른 사람들과 채팅을 할 수 있습니다.

- 친구를 맺은 후, 거리에 상관 없이 개인 채팅방을 만들 수 있습니다.

## 팀원 소개

|`S001` 고병학|`S009` 김영욱|`S013` 김준영|`S025` 신동은|`S046` 임창묵|
|:--:|:--:|:--:|:--:|:--:|
|<img src="https://avatars.githubusercontent.com/u/41236155?v=4" width="150">|<img src="https://avatars.githubusercontent.com/u/100309352?v=4" width="150">|<img src="https://avatars.githubusercontent.com/u/46563413?v=4" width="150">|<img src="https://avatars.githubusercontent.com/u/55118858?v=4" width="150">|<img src="https://avatars.githubusercontent.com/u/58398099?v=4" width="150">|
|[@bengHak](https://github.com/bengHak)|[@yw22](https://github.com/yw22)|[@prestonk162](https://github.com/prestonk162)|[@dongeunshin](https://github.com/dongeunshin)|[@lymchgmk](https://github.com/lymchgmk)|

## 개발환경 및 라이브러리

### 개발환경

#### IDE
![badge](https://img.shields.io/badge/Xcode-14.1-147EFB?style=for-the-badge&logo=Xcode&logoColor=147EFB)

#### iOS 최소 지원
![badge](https://img.shields.io/badge/iOS-15.0-lightgrey.svg?style=for-the-badge&logo=apple&logoColor=white)



### 프레임워크 및 라이브러리

#### Package Dependency Manager
![badge](https://img.shields.io/badge/CocoaPods-1.11.3-EE3322.svg?style=for-the-badge&logo=CocoaPods&logoColor=EE3322)

#### Networking
![badge](https://img.shields.io/badge/Firebase-10.3.0-FFCA28.svg?style=for-the-badge&logo=Firebase&logoColor=FFCA28)

#### Asynchronous programming
![badge](https://img.shields.io/badge/RxSwift-6.5.0-B7178C.svg?style=for-the-badge&logo=ReactiveX&logoColor=B7178C)
![badge](https://img.shields.io/badge/RxCocoa-6.5.0-B7176C.svg?style=for-the-badge&logo=ReactiveX&logoColor=B7176C)
![badge](https://img.shields.io/badge/RxGesture-4.0.0-B7174C.svg?style=for-the-badge&logo=ReactiveX&logoColor=B7174C)
![badge](https://img.shields.io/badge/RxBlocking-6.5-B7172C.svg?style=for-the-badge&logo=ReactiveX&logoColor=B7172C)

#### UI Autolayout
![badge](https://img.shields.io/badge/SnapKit-5.6.0-F05138?style=for-the-badge&logo=Swift&logoColor=F05138)
![badge](https://img.shields.io/badge/Then-3.0.0-F06138.svg?style=for-the-badge&logo=Swift&logoColor=F06138)

#### Image caching
![badge](https://img.shields.io/badge/Kingfisher-7.4.1-F07138.svg?style=for-the-badge&logo=Swift&logoColor=F07138)

#### Dependency injection
![badge](https://img.shields.io/badge/Swinject-2.8.3-F08138.svg?style=for-the-badge&logo=Swift&logoColor=F08138)

## 프로젝트 주요 기능

> QR 코드를 통한 친구 추가 및 채팅

> 애플 계정으로 회원 가입, 로그인, 회원 탈퇴

<img alt="로그인화면" src="https://user-images.githubusercontent.com/46563413/208241267-fe0fdd14-4c4e-46ae-bbc8-c834e7fc471a.png" width=25% /><img src="https://user-images.githubusercontent.com/46563413/208241268-bfe4279b-c6a3-46e7-b03d-1f129d11338c.png" width=25% /><img src="https://user-images.githubusercontent.com/46563413/208241504-b7e0fd32-a51e-4216-a221-ad216ede02b7.png" width=24% />

> 텍스트와 이미지로 프로필 등록 및 편집

<img src="https://user-images.githubusercontent.com/46563413/208240532-1d88021f-a63d-4e5b-b345-aba544bd9706.png" width=24%><img src="https://user-images.githubusercontent.com/46563413/208240524-efbd816b-180f-43c5-88c6-3308162bcbf8.png" width=25%><img src="https://user-images.githubusercontent.com/46563413/208240519-c09d4849-36b7-4f61-876e-e2ebb23a156c.png" width=25%>

- 프로필 사진은 설정 앱에서 접근을 허용한 사진만 사용 가능합니다.

> 다크 모드 지원

|<img src="https://user-images.githubusercontent.com/46563413/208240529-b5491a10-ecd7-48a2-9ed7-864962c94d1c.png">|<img src="https://user-images.githubusercontent.com/46563413/208240528-319d5a8e-d366-4ce1-aa98-ceadce89dc2a.png">|<img src="https://user-images.githubusercontent.com/46563413/208240536-42a3aa2a-0964-4f55-9022-214a30b6ecda.png">|<img src="https://user-images.githubusercontent.com/46563413/208240534-5134dc2e-bd93-4390-bf2b-06410c515481.png">|
|:-:|:-:|:-:|:-:|
|`시스템 설정 (라이트)`|`시스템 설정 (다크)`|`다크 모드`|`라이트 모드`|


## 아키텍쳐 & 디자인 패턴
<img alt="Data Flow" src="/images/Flow.png">

> ### Clean Architecture

- 프레젠테이션 레이어, 도메인 레이어, 데이터 레이어로 분리된 코드로 각 레이어에서 개발한 결과물을 합칠 때 이점이 있기 때문에 도입했습니다.
- 도메인 레이어가 UI와 독립적이기 때문에 비즈니스 로직의 유닛 테스트에 용이합니다.
- MVVM에서 viewModel이 커지는 것을 use case와 repsoitory 코드로 분산할 수 있습니다.

> ###  MVVM - C

- View와 독립적으로 개발할 수 있는 viewModel을 활용해서 유닛 테스트하기에 용이한 **MVVM 패턴**을 도입했습니다.
- View의 화면전환 로직을 viewController에서 분리하는 것으로 화면전환을 유연하게 할 수 있는 **코디네이터 패턴**을 도입했습니다.

## 기술적인 도전

### RxSwift
- MVVM 패턴에서 ViewModel과 View(View + ViewController)와의 데이터 바인딩을 위해 도입했습니다.
- 델리게이트나 클로저를 통한 방법도 있지만, 클로저 중첩과 실행 흐름의 복잡성으로 인해 테스트와 개발 모두 어려워지는 단점이 있습니다.
- RxSwift와 연관된 RxCocoa를 통해, UI 관련 여러 버튼, 텍스트 필드, 이벤트 관련 메서드나 프로퍼티가 제공되어 있어, Combine 보다 더 적은 코드로 데이터 바인딩이 가능하여 도입했습니다.

### MapKit
- 사용자의 GPS 좌표를 이용하여 채팅방 입장/생성이 가능합니다.
- RxSwift를 이용해서, 사용자의 현재 위치가 변경되거나 지도 뷰를 이동했을 때 입장가능한 채팅방을 비동기적으로 가져오는 비즈니스 로직을 작성했습니다.

### Core Data
- 메세지들을 채팅방 사용자 모두가 매번 호출하게 되면 요청량이 많을 것으로 예상됐습니다.
- 파이어베이스 비용을 줄이기 위해 송수신하는 메세지들을 코어데이터에 저장하고 채팅방에 다시 입장할 때 불러오도록 구현했습니다.

### Firebase
- 사용자의 프로필 데이터와 메세지 데이터들을 Firestore와 RealtimeDatabase에 나눠 저장했습니다.
- 나눠 저장한 이유는 각 저장소의 특징을 활용하고 싶었기 때문입니다.
- Firestore는 비교적 더 나은 쿼리 API를 갖고 있어서 채팅방을 위치에 따라 가져와야하는 저희 서비스에서는 활용하면 좋겠다고 판단했습니다.
- RealtimeDatabase는 실시간으로 변하는 데이터들을 추적하는 것에 특화된 서비스이기 때문에 실시간 채팅을 고려한 저희 서비스에서 사용하기 좋다고 판단했습니다.

### Carthage
- UIKit을 활용한 프로젝트이지만 빠른 화면 개발을 위해  SwiftUI의 Preview를 활용했습니다.
- CocoaPods로 관리하던 firebase-ios-sdk의 빌드 시간으로 인해 preview 그려지는 시간 증가했습니다.
- Firebase-ios-sdk의 빌드시간을 줄이기 위해 Carthage를 활용했습니다.
- Carthage 적용 후 클린 빌드 시간 단축할 수 있었습니다. **(88초 -> 16.3초)**

저희의 개발기를 보고싶으시다면 WIKI를 참고해주세요! ![iOS06_NearTalk](https://github.com/boostcampwm-2022/iOS06-NearTalk/wiki)
