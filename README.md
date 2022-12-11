# NearTalk (프로젝트 소개)
<img src="/images/NearTalkLogo.png" width="250">

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
- macOS Ventura 13.0 → 병학님, 준영님, 영욱님
- macOS Monterey 12.6 → 창묵님, 동은님

### 프레임워크 및 라이브러리

- RxSwift `6.5.0`
- RxCocoa `6.5.0`
- RxGesture `4.0.0`
- RxBlocking `6.5.0`
- Firebase `10.3.0`
- SnapKit `5.6.0`
- Kingfisher `7.4.1`
- Then `3.0.0`

## 기능

## 아키텍쳐 & 디자인 패턴

### Clean Architecture

### MVVM - C

## 기술적인 도전

### Carthage 적용

1. Carthage 설치 (터미널에서 실행)
   - `brew install carthage`
2. 프로젝트 폴더에서 프레임워크, 라이브러리 빌드 (터미널에서 실행)
   - `carthage update --use-xcframeworks --platform iOS`
3. 프로젝트 폴더 내 `Carthage/Build/` 폴더를 Xcode 프로젝트 최상단에 추가

   <img src="images/carthage.png" width="300px" />
4. Target의 "Build Settings"에 "Other Linker Flags"에 `$(OTHER_LDFLAGS) -ObjC`를 추가한다.

   <img src="images/carthage_1.png" width="500px" />
