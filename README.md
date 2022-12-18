# NearTalk 소개

<p align="center"><img src="/images/nearTalkLogo.png" width="250"></p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=Swift&logoColor=white"/>
  <img src="https://img.shields.io/badge/UIkit-2396F3?style=for-the-badge&logo=iOS&logoColor=white"/>
  <img src="https://img.shields.io/badge/RxSwift-8D1F89?style=for-the-badge&logo=ReactiveX&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=Firebase&logoColor=white"/>
</p>

- 근처에 있는 사람들과 실시간 소통할 수 있는 메신저 앱 "근방톡" 입니다.
- 실시간 위치 기반으로 근처에 있는 채팅방에 입장하고 대화할 수 있습니다.
- 친구를 맺고 DM을 보낼 수 있습니다.

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

## 기능

### 사용자 실시간 위치를 기준으로 채팅방 생성

### 애플 소셜 로그인

<table>
 <tr>
  <td>로그인 화면</td>
  <td>회원 탈퇴</td>
 </tr>
  <td>
   <img width="818" alt="스크린샷 2022-12-15 17 39 03" src="https://user-images.githubusercontent.com/46563413/207814240-257d4f19-08bd-4f86-aee2-e40eaa499746.png">
  </td>
  <td>
   <img width="862" alt="스크린샷 2022-12-15 17 39 38" src="https://user-images.githubusercontent.com/46563413/207814166-317274b9-d563-415a-8a0f-8c9b556aefe1.png">
  </td>
 </tr>
</table>

별도의 이메일, 비밀번호 필요 없이, 애플 계정만으로 회원 가입 및 로그인이 가능합니다.

- 애플 로그인 이후, 로그아웃을 하지 않았다면, 해당 애플 계정에 연결된 계정으로 자동 로그인이 됩니다.
- 애플 로그인은 회원 가입, 로그인, 회원 탈퇴 때 요구됩니다.
- 앱에 로그인한 애플 계정 변경을 원하실 경우, 설정 앱 -> icloud -> 암호 및 보안 -> Apple ID를 사용하는 앱 -> NearTalk 앱 -> Apple ID 사용 중단 클릭을 하셔야 합니다.

### 푸시 알림 On/Off

### 프로필 등록 및 수정

#### 프로필 등록
첫 로그인 이후, 프로필 등록 단계에서 프로필 등록이 가능합니다. (로그인 직후, 앱을 종료할 경우, 프로필 등록 페이지로 이동합니다)

#### 프로필 수정
앱 로그인 이후, 마이 프로필 -> 프로필 수정 화면에서 프로필 수정이 가능합니다.

<table>
 <tr>
    <td>프로필 등록</td>
    <td>프로필 수정</td>
 </tr>
 <tr>
    <td><img width="862" alt="스크린샷 2022-12-15 15 14 01" src="https://user-images.githubusercontent.com/46563413/207786439-86435afa-6ce0-4861-a9fb-8535305aa346.png"></td>
    <td><img width="818" alt="스크린샷 2022-12-15 15 25 00" src="https://user-images.githubusercontent.com/46563413/207788099-e0a31785-5c35-46ff-8a9b-3f4637fe1546.png"></td>
   </td>
 <tr>
</table>


프로필은 다음의 요소로 구성됩니다.
```
- 닉네임 (한글, 영어소문자, 숫자만 포함된 3-20자 텍스트)
- 상태메세지 (50자 이하 텍스트)
- 이미지 (사진)
```

### 다크 모드 지원
마이 프로필 -> 앱 설정 -> 테마 설정 화면에서 테마 선택이 가능합니다.

테마 모드
```
- 시스템 설정 (설정 앱에서 선택한 테마)
- 다크 모드 (설정 앱 테마 값 무시)
- 라이트 모드 (설정 앱 테마 값 무시)
```

<table>
   <tr>
      <td>시스템 설정 (라이트)</td>
      <td>시스템 설정 (다크)</td>
      <td>다크 모드</td>
      <td>라이트 모드</td>
   </tr>
   <tr>
      <td>
      <img width="818" alt="스크린샷 2022-12-15 15 36 07" src="https://user-images.githubusercontent.com/46563413/207793332-4969031b-31e8-4aa9-a2cd-431336bfa04c.png">
      </td>
      <td>
      <img width="818" alt="스크린샷 2022-12-15 15 57 08" src="https://user-images.githubusercontent.com/46563413/207793514-eb9bc6d1-eb39-4f55-a41b-81fc5356e872.png">
      </td>
      <td>
      <img width="818" alt="스크린샷 2022-12-15 15 37 54" src="https://user-images.githubusercontent.com/46563413/207793358-a2cc4484-e4e9-4ee4-849b-dbf0d5008f6e.png">
      </td>
      <td>
      <img width="818" alt="스크린샷 2022-12-15 15 38 03" src="https://user-images.githubusercontent.com/46563413/207793380-9479f293-26e9-4d57-95f9-1272f121e4ef.png">
      </td>
   </tr>
</table>

### 그룹 채팅

### 친구 추가

### DM 채팅

## 아키텍쳐 & 디자인 패턴

### Clean Architecture

- 프레젠테이션 레이어, 도메인 레이어, 데이터 레이어로 분리된 코드로 각 레이어에서 개발한 결과물을 합칠 때 이점이 있기 때문에 도입했습니다.
- 도메인 레이어가 UI와 독립적이기 때문에 비즈니스 로직의 유닛 테스트에 용이합니다.
- MVVM에서 viewModel이 커지는 것을 use case와 repsoitory 코드로 분산할 수 있습니다.

### MVVM - C

- View와 독립적으로 개발할 수 있는 viewModel을 활용해서 유닛 테스트하기에 용이한 **MVVM 패턴**을 ****입했습니다.
- View의 화면전환 로직을 viewController에서 분리하는 것으로 화면전환을 유연하게 할 수 있는 **코디네이터 패턴**을 도입했습니다.

## 기술적인 도전

### Carthage

1. Carthage 설치 (터미널에서 실행)
   - `brew install carthage`
2. 프로젝트 폴더에서 프레임워크, 라이브러리 빌드 (터미널에서 실행)
   - `carthage update --use-xcframeworks --platform iOS`
3. 프로젝트 폴더 내 `Carthage/Build/` 폴더를 Xcode 프로젝트 최상단에 추가

   <img src="images/carthage.png" width="300px" />
4. Target의 "Build Settings"에 "Other Linker Flags"에 `$(OTHER_LDFLAGS) -ObjC`를 추가한다.

   <img src="images/carthage_1.png" width="500px" />

### 접근 허용된 사진만 불러오기

https://user-images.githubusercontent.com/46563413/207805355-73482552-b042-48fe-bd9a-92d9e390936f.mov

- 앱 실행 중 접근 허용하지 않은 사진을 아예 화면에서 보이지 않게 하기 위해 구현했습니다.
- PHPickerViewController, UIImageViewController는 접근을 허용하지 않은 사진까지 불러옵니다.
- PHAsset, PHPhotoLibrary, CollectionView를 활용하여 앱에서 사진을 Import 할 때 접근이 허용된 사진만 불러오는 Picker를 구현했습니다.
