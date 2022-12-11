# NearTalk 소개

<img src="/images/Logo.png" width="250">

- 근처에 있는 사람들과 실시간 소통할 수 있는 메신저 앱 "근방톡" 입니다.
- 실시간 위치 기반으로 근처에 있는 채팅방에 입장하고 대화할 수 있습니다.
- 친구를 맺고 DM을 보낼 수 있습니다.

## 팀원 소개

|`S001` 고병학|`S009` 김영욱|`S013` 김준영|`S025` 신동은|`S046` 임창묵|
|:--:|:--:|:--:|:--:|:--:|
|<img src="https://avatars.githubusercontent.com/u/41236155?v=4" width="150">|<img src="https://avatars.githubusercontent.com/u/100309352?v=4" width="150">|<img src="https://avatars.githubusercontent.com/u/46563413?v=4" width="150">|<img src="https://avatars.githubusercontent.com/u/55118858?v=4" width="150">|<img src="https://avatars.githubusercontent.com/u/58398099?v=4" width="150">|
|[@bengHak](https://github.com/bengHak)|[@yw22](https://github.com/yw22)|[@prestonk162](https://github.com/prestonk162)|[@dongeunshin](https://github.com/dongeunshin)|[@lymchgmk](https://github.com/lymchgmk)|

## 개발환경 및 라이브러리

### iOS 최소 버전
- iOS 15

### 개발환경
- Xcode 14.1
- macOS Ventura 13.0
- macOS Monterey 12.6

### 프레임워크 및 라이브러리 버전

- RxSwift `6.5.0`
- RxCocoa `6.5.0`
- RxGesture `4.0.0`
- RxBlocking `6.5.0`
- Firebase `10.3.0`
- SnapKit `5.6.0`
- Kingfisher `7.4.1`
- Then `3.0.0`

## 기능

#### 사용자 실시간 위치를 기준으로 채팅방 생성

- 채팅방 생성 위치에서 1~10KM 안에 있는 사용자만 채팅방 입장 가능

#### 애플 소셜 로그인

- 별도의 아이디, 비밀번호를 생성하지 않고, 애플 계정을 사용하여, 회원 가입과 로그인이 가능합니다.
- 앱 종료 후, 로그아웃을 하지 않았다면, 자동으로 로그인이 됩니다.
- 로그 아웃 후, 다시 로그인 페이지로 넘어오게 되며, 처음 회원 가입 때와 같은 애플 계정으로 로그인 하시면 재접속이 가능합니다.
- 회원 탈퇴를 원하실 경우, 가입한 애플 계정 로그인으로 재인증이 성공해야 가능합니다.

#### 푸시 알림 On/Off

- 채팅을 푸쉬 알림으로 받을 수 있는 옵션입니다.
- 기본적으로 앱에서 알림 권한이 부여되어야 알림 수신이 가능합니다. 만약 앱에 알림 권한을 부여하지 않은 상태에서, 알림 수신을 켰을 때, 앱 권한 설정 화면으로 이동 시켜 드립니다.
- 알림 권한이 이미 부여 되었다면, 앱에서 알림 수신 설정을 변경 할때, 앱 권한 설정 화면으로 이동시키지 않습니다.

#### 프로필 등록 및 수정

- 프로필은 다음 요소들로 구성 됩니다.
    - 이미지
    - 닉네임 (영어 소문자, 숫자, _- 조합의 5-16자)
    - 상태 메세지 (50자 이하)
- 회원 가입 시, 애플 로그인 성공 후, 프로필을 등록해야 합니다.
    - 로그인 이후, 프로필을 등록하지 않으면, 다시 로그인 할 때, 프로필 등록 화면으로 이동합니다.
- 회원 가입 이후, 마이 프로필 → 프로필 수정 화면으로 이동해서, 프로필을 수정할 수 있습니다.
    - 프로필 수정본을 서버로 업로드하고, 응답을 받기 전까지는, 로딩 화면이 표시됩니다.

#### 그룹 채팅

- 현재 위치를 기반으로 입장할 수 있는 그룹 채팅방을 지도를 통해서 확인 할 수 있습니다.
- 현재 위치를 기반으로 그룹 채팅방을 생성 할 수 있습니다.

#### 친구 추가

#### DM 채팅

## 아키텍쳐 & 디자인 패턴

#### Clean Architecture

- 프레젠테이션 레이어, 도메인 레이어, 데이터 레이어로 분리된 코드로 각 레이어에서 개발한 결과물을 합칠 때 이점이 있기 때문에 도입했습니다.
- 도메인 레이어가 UI와 독립적이기 때문에 비즈니스 로직의 유닛 테스트에 용이합니다.
- MVVM에서 viewModel이 커지는 것을 use case와 repsoitory 코드로 분산할 수 있습니다.

#### MVVM - C

- View와 독립적으로 개발할 수 있는 viewModel을 활용해서 유닛 테스트하기에 용이한 **MVVM 패턴**을 ****입했습니다.
- View의 화면전환 로직을 viewController에서 분리하는 것으로 화면전환을 유연하게 할 수 있는 **코디네이터 패턴**을 도입했습니다.

## 기술적인 도전

#### Carthage

1. Carthage 설치 (터미널에서 실행)
   - `brew install carthage`
2. 프로젝트 폴더에서 프레임워크, 라이브러리 빌드 (터미널에서 실행)
   - `carthage update --use-xcframeworks --platform iOS`
3. 프로젝트 폴더 내 `Carthage/Build/` 폴더를 Xcode 프로젝트 최상단에 추가

   <img src="images/carthage.png" width="300px" />
4. Target의 "Build Settings"에 "Other Linker Flags"에 `$(OTHER_LDFLAGS) -ObjC`를 추가한다.

   <img src="images/carthage_1.png" width="500px" />

