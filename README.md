# “Card.Zip” - 이미지를 첨부 단어 카드

### Card.Zip으로 주제에 맞는 단어 카드를 작성해 빠르게 외우세요.

> 주제를 선택하고, 주제와 관련된 단어 카드를 만들어 기록하는 서비스
> 
![Group_2](https://github.com/user-attachments/assets/e43178a5-94cd-4119-be22-6588fab10db0)
[![Download_on_the_App_Store_Badge_US-UK_RGB_blk_092917](https://github.com/user-attachments/assets/c6e16b92-5795-4a7c-b392-b69a9bc431ba)](https://apps.apple.com/kr/app/card-zip/id6469782765?l=en-GB)


### 프로젝트 요약

- 여러 이미지를 담은 수 있는 하나의 **“단어 카드”** > 단어 카드들의 모음집을 **“세트”** 로 기록
- 개인 프로젝트
- 2023.09.23 ~ 2024.10.23 (4주)
- iOS App - Minimum deployment target **16.0**

> 💡 주제를 선택하고, 주제와 관련된 단어 카드를 만들어 외우는 데 도움을 주는 암기 도구입니다.  
> 사용자가 선택한 주제에 대한 단어들을 이미지와 함께 기억하도록 돕습니다.  
> 북마크 기능, 집중 암기 대상 위젯 기능, TTS 기능, 단어 키워드 이미지 검색 기능 등을 통해 사용자가 원하는 방식으로 외울 수 있게 돕습니다.  


### 사용 기술 목록

| **Services, Technology** | **Stack** |
| --- | --- |
| Architectrue | MVC → MVVM |
| Asynchronous | Swift Concurrency, Combine |
| Network | Alamofire |
| UI | UIKit(SnapKit), Modern Collection View |
| Cache, Storage, DataBase | RealmSwift, NSCache, UserDefaults, Documents |
| Apple APIs | CoreImage, Photos |
| Custom Serivice | ReferenceCounter |
| Widget | WidgetKit |
| Others | Localization, TTS |

## 주요 제공 서비스

### 1. 단어 카드 및 카드 세트 CRUD

| **1. 생성** | **2. 조회** | **3. 수정** | **4. 삭제** |
|-------------|-------------|-------------|-------------|
| <img src="https://github.com/user-attachments/assets/f48887a2-68e5-4ae1-82bb-588ba8e36c1c" width="200"/> | <img src="https://github.com/user-attachments/assets/eba57761-ab06-4e89-8a0c-25f353866e43" width="200"/> | <img src="https://github.com/user-attachments/assets/7b8bdcde-eacc-4f33-8b18-6afb56c0418d" width="200"/> | <img src="https://github.com/user-attachments/assets/dcbf5bfa-80ca-4cd2-8989-a6a0f8a9224d" width="200"/> |

- **주요 기능**
    1. **단어 카드 및 카드 세트 생성**
        1. 사용자 앨범에서 이미지 첨부
        2. 이미지 검색 API를 단어 카드와 세트에 적절한 이미지 첨부
    2. **단어 카드 및 카드 세트 조회**
        1. CollectionView Paging 스크롤로 하나의 단어 카드 조회 가능
        2. 이미지 갤러리 확대 조회
        3. 카드 넘겨서 단어 의미 조회
        4. 단어별 음성 제공
    3. 단어 카드 및 카드 세트 수정
        1. 사용자 앨범에서 이미지 첨부
        2. 이미지 검색 API를 단어 카드와 세트에 적절한 이미지 첨부
    4. **단어 카드 및 카드 세트 삭제**
        1. 전체 카드 세트 
    

### 2. 세트 별 검색, 즐겨찾기 및 위젯

| **세트 카드 검색 및 세트 즐겨찾기** | **집중 카드 즐겨찾기** | **집중 카드 위젯** |
|------------------------------------|-----------------------|---------------------|
| <img src="https://github.com/user-attachments/assets/d8307a4e-b6d5-4d99-b5d2-eb37003344d8" width="200"/> | <img src="https://github.com/user-attachments/assets/4f5f0e07-031b-4808-9d74-8e5967cd53ed" width="200"/> | <img src="https://github.com/user-attachments/assets/821879a2-e896-44a6-9799-8b2f4b0bc1d7" width="200"/> |
- **주요 기능**
    1. **세트 카드 검색 및 세트 즐겨찾기**
        1. 검색 기능을 적용해서 빠르게 세트 내부에서 단어 조회 가능
        2. 북마크 아이콘을 선택하여 세트 내부에서 잘 안 외어지는 단어에 빠르게 접근 가능
    2. **집중 카드 즐겨찾기**
        1. 별표 아이콘을 선택해서 세트에 상관없이 전체 카드 중 중요 단어 빠르게 접근 가능
    3. **집중 카드 위젯**
        1. **“집중 카드 즐겨찾기 세트”**에 존재하는 단어들을 빠르게 볼 수 있는 위젯
        2. 앱 아이콘과 다르게 위젯 선택시 **“집중 카드 즐겨찾기 세트 화면”**으로 바로 이동

## 주요 기술 구현 특징

| **Keyword** | **Description** |
| --- | --- |
| **App Architeucture** | [Modern UICollectionView 적용하기](https://arpple.tistory.com/23) |
|  | [CustomDiffableDataSource와 MVVM으로 Cell 데이터 관리하기](https://arpple.tistory.com/31) |
|  | [MVC 버전의 문제점](https://www.notion.so/1-0-1-MVVM-53bba64197654ca49761865d35531d03?pvs=21) |
| **Image Caching** | [UIImage 최적화](https://arpple.tistory.com/37) |

## 회고

### MVC에서 MVVM 전환

- [**MVC 버전의 문제점**](https://www.notion.so/1-0-1-MVVM-53bba64197654ca49761865d35531d03?pvs=21)
- [**CustomDiffableDataSource와 MVVM으로 Cell 데이터 관리하기**](https://arpple.tistory.com/31)

ViewController에 View를 나타내는 것 뿐만 아니라 모든 서비스, 뷰 간 통신 로직을 모두 담당해야 했다.

특히, CollectionView에서 Cell들의 데이터와 이를 담는 View, 그리고 DB와의 연동을 하는 작업을 모두 ViewController 한 곳에서 담당해 매우 복잡했다.

이를 해결하기 위해 CollectionView는 상속을 이용해 각각의 상위 View에 맞는 커스텀 타입을 만들어 ViewController에서 코드를 분리시키고, ViewController의 DB 및 외부 서비스와의 연동 작업을 ViewModel로 역할을 분리해 가독성 및 유지 보수(기능 추가)를 더 쉽게 할 수 있었다.

### 이미지 처리 과정에서 최적화를 위한 DownSampling 과 캐싱 처리

- [UIImage 최적화](https://arpple.tistory.com/37)

처음에는 사용자의 앨범이나 검색해서 얻은 이미지들을 그대로 파일 매니저에 저장하고 카드 셀이 나타날 때마다 파일 매니저에서 그 이미지를 불러와 화면에 띄우는 로직으로 구성했다. 이 로직을 기반으로 테스트를 하니 카드에 이미지를 3개~4개 정도만 첨부해도 앱이 엄청 느려지는 문제가 발생했다. 우선 CollectionView Cell이 화면에 나타날 때마다 이미지를 다시 로딩하는 문제점을 해결해야 했다. 이를 위해 `NSCache` 를 이용해 이미지 캐시를 적용했다. 하지만, 여러 이미지를 동시에 띄워야 하는 경우에 모든 이미지를 다 띄우지 못하는 문제가 발생했다. 그 이유는, 캐시가 저장하는 데이터의 양이 정해져 있고, 이미지를 DownSampling 하지 않고 불러와 하나의 이미지에 매우 많은 데이터를 사용하는 것이다. 이를 해결하기 위해 `CoreImage` 를 활용해 적용되는 이미지 뷰 크기에 따른 이미지 DownSample을 적용했고, 여러 이미지를 한 화면에 띄우고 CollectionView도 원할하게 작동하게 만들 수 있었다.
