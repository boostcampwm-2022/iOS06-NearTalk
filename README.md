# NearTalk 소개

<p align="light"><img src="/images/nearTalkLogo.png" width="250"></p>

<p align="light">
  <img src="https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=Swift&logoColor=white"/>
  <img src="https://img.shields.io/badge/UIkit-2396F3?style=for-the-badge&logo=iOS&logoColor=white"/>
  <img src="https://img.shields.io/badge/RxSwift-8D1F89?style=for-the-badge&logo=ReactiveX&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=Firebase&logoColor=white"/>
</p>

근처에 있는 사람들과 실시간 소통할 수 있는 메신저 앱 "근방톡" 입니다.
실시간 위치 기반으로 근처에 있는 채팅방에 입장하고 대화할 수 있습니다.
친구를 맺고 DM을 보낼 수 있습니다.

## 팀원 소개

|`S001` 고병학|`S009` 김영욱|`S013` 김준영|`S025` 신동은|`S046` 임창묵|
|:--:|:--:|:--:|:--:|:--:|
|<img src="https://avatars.githubusercontent.com/u/41236155?v=4" width="150">|<img src="https://avatars.githubusercontent.com/u/100309352?v=4" width="150">|<img src="https://avatars.githubusercontent.com/u/46563413?v=4" width="150">|<img src="https://avatars.githubusercontent.com/u/55118858?v=4" width="150">|<img src="https://avatars.githubusercontent.com/u/58398099?v=4" width="150">|
|[@bengHak](https://github.com/bengHak)|[@yw22](https://github.com/yw22)|[@prestonk162](https://github.com/prestonk162)|[@dongeunshin](https://github.com/dongeunshin)|[@lymchgmk](https://github.com/lymchgmk)|

## 동작화면
<table>
   <tr>
      <td>로그인</td>
      <td>지도 뷰</td>
      <td>채팅방 생성</td>
      <td>채팅방 목록</td>
   </tr>
   <tr>
      <td>
      <>
      </td>
      <td>
      <>
      </td>
      <td>
      <>
      </td>
      <td>
      <>
      </td>
   </tr>
   <tr>
      <td>채팅방</td>
      <td>친구추가</td>
      <td>다크 모드</td>
      <td>앱 설정</td>
   </tr>
   <tr>
      <td>
      <>
      </td>
      <td>
      <>
      </td>
      <td>
      <>
      </td>
      <td>
      <>
      </td>
   </tr>
</table>

## 주요 기능

#### 📱사용자 실시간 위치를 기준으로 채팅방 생성
- 실시간으로 사용자의 위치를 정보를 불러와서 근처에 입장가능한 방들을 보여줍니다
- 

#### 📱채팅방
- Group채팅방과 DM 채팅방을 분리했습니다.
- 채팅방에 변경을 실시간으로 인지하여 화면에 보여줍니다
- 현재위치기반 입장가능한 방과 입장 불가능한 방을 보여줍니다.

#### 📱채팅화면
- 실시간으로 상대방들과 대화를 주고 받을 수 있습니다.
- 

#### 📱친구추가
- QR을 이용하여 친구 추가를 할 수 있습니다
- 친구와는 DM을 할 수 있습니다.

#### 📱애플 소셜 로그인
- 별도의 이메일, 비밀번호 필요 없이, 애플 계정만으로 회원 가입 및 로그인이 가능합니다.
- 로그아웃과 회원탈퇴 기능을 지원합니다.

#### 📱푸시 알림 On/Off
- 채팅이 오면 푸시 알림으로 사용자에게 알려줍니다.

#### 📱프로필 등록 및 수정
- 첫 로그인 이후, 프로필 등록 단계에서 프로필 등록이 가능합니다. (로그인 직후, 앱을 종료할 경우, 프로필 등록 페이지로 이동합니다)
- 앱 로그인 이후, 마이 프로필 -> 프로필 수정 화면에서 프로필 수정이 가능합니다.

#### 📱다크 모드 지원
- 마이 프로필 -> 앱 설정 -> 테마 설정 화면에서 테마 선택이 가능합니다.

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

> ### RxSwift
- 
- 
> ### Firebase & RealTimeBase
- 
- 
> ### CoreData를 활용한 채팅메세지 캐싱
- 
- 
> ### 의존성 주입을 위한 DIContainer
-
-
> ### 다크모드 지원
- 
> ### Image Resize
- 






