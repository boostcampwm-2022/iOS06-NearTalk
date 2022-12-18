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

#### Dependency Manager
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

<img alt="로그인화면" src="https://user-images.githubusercontent.com/46563413/208241267-fe0fdd14-4c4e-46ae-bbc8-c834e7fc471a.png" width=25% />
<img src="https://user-images.githubusercontent.com/46563413/208241268-bfe4279b-c6a3-46e7-b03d-1f129d11338c.png" width=25% />
<img src="https://user-images.githubusercontent.com/46563413/208241504-b7e0fd32-a51e-4216-a221-ad216ede02b7.png" width=24% />

> 텍스트와 이미지로 프로필 등록 및 편집

<img src="https://user-images.githubusercontent.com/46563413/208240532-1d88021f-a63d-4e5b-b345-aba544bd9706.png" width=24%><img src="https://user-images.githubusercontent.com/46563413/208240524-efbd816b-180f-43c5-88c6-3308162bcbf8.png" width=25%><img src="https://user-images.githubusercontent.com/46563413/208240519-c09d4849-36b7-4f61-876e-e2ebb23a156c.png" width=25%>

- 프로필 사진은 설정 앱에서 접근을 허용한 사진만 사용 가능합니다.

> 다크 모드 지원

|<img src="https://user-images.githubusercontent.com/46563413/208240529-b5491a10-ecd7-48a2-9ed7-864962c94d1c.png">|<img src="https://user-images.githubusercontent.com/46563413/208240528-319d5a8e-d366-4ce1-aa98-ceadce89dc2a.png">|<img src="https://user-images.githubusercontent.com/46563413/208240536-42a3aa2a-0964-4f55-9022-214a30b6ecda.png">|<img src="https://user-images.githubusercontent.com/46563413/208240534-5134dc2e-bd93-4390-bf2b-06410c515481.png">|
|:-:|:-:|:-:|:-:|
|`시스템 설정 (라이트)`|`시스템 설정 (다크)`|`다크 모드`|`라이트 모드`|
|

## 기술적인 도전
