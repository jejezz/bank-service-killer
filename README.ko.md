<!-- From jejezz/application-release-templates common/tool/readme @ conventions-v1.
     tool/readme/init_readme.py가 만든 파일입니다 — conventions/readme-guide.md 참고.
     {{TODO: …}}를 모두 채우십시오. 하나라도 남아 있으면 tool/readme/check_readme.py가 실패합니다. -->

<p align="center">
  <img src="assets/icon/app_icon.png" width="128" alt="Bank Service Killer 아이콘">
</p>

<h1 align="center">Bank Service Killer</h1>

<p align="center">
  뱅킹할 때만 금융보안·키보드보안 같은 상주 서비스를 켜고 끄고, 실제로 반영됐는지까지 확인하는 <b>Windows 서비스 on/off 도구</b>입니다.
</p>

<p align="center">
  <a href="https://github.com/jejezz/bank-service-killer/releases/latest"><img src="https://img.shields.io/github/v/release/jejezz/bank-service-killer?style=flat-square&color=4c9dff" alt="최신 릴리스"></a>
  <a href="https://github.com/jejezz/bank-service-killer/releases"><img src="https://img.shields.io/github/downloads/jejezz/bank-service-killer/total?style=flat-square&color=7c5cff" alt="다운로드"></a>
  <img src="https://img.shields.io/badge/platform-Windows-34d399?style=flat-square" alt="Windows">
  <img src="https://img.shields.io/badge/built%20with-Flutter-02569b?style=flat-square" alt="Flutter">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/jejezz/bank-service-killer?style=flat-square" alt="MIT 라이선스"></a>
</p>

<p align="center">
  <a href="README.md">English</a> · <b>한국어</b>
</p>

<p align="center">
  <img src="docs/screenshots/demo.gif" width="720" alt="Bank Service Killer 데모: 서비스 목록에서 전체 켜기와 전체 끄기">
</p>

## 기능

- **서비스 매칭** — 감시 목록의 이름을 설치된 서비스(Win32_Service)와 맞춥니다. 정확히 같은 이름을 먼저, 없으면 부분 일치를 씁니다
- **켜기·끄기와 검증** — 명령 뒤 실제 상태를 폴링으로 확인하고, 중지는 3초 뒤 다시 확인해 자동 복구(감시 프로세스)도 알려 줍니다
- **시작 유형 변경** — 자동 / 수동 / 사용 안 함을 바꾸고, msconfig에서 비활성화한 서비스는 따로 표시합니다
- **감시 목록 편집** — `+`로 설치된 서비스를 검색해 추가합니다. 목록은 `%APPDATA%\BankServiceKiller\watchlist.json`에 저장되며 직접 고쳐도 됩니다
- **라이트·다크, 한국어·English** — 시스템 설정을 따르거나 툴바에서 고를 수 있습니다

<p align="center">
  <img src="docs/screenshots/home.png" width="360" alt="감시 서비스 목록 화면">
  <img src="docs/screenshots/detail.png" width="360" alt="서비스 추가 대화상자">
</p>

## 설치

[**Releases**](https://github.com/jejezz/bank-service-killer/releases/latest)에서 받습니다.

| OS | 파일 |
|---|---|
| Windows 10/11 (x64) | `BankServiceKiller-<버전>-windows-x64-setup.exe` |

**Windows:** 설치 프로그램에 아직 코드 서명이 없어서 SmartScreen이 "Windows의 PC 보호" 창을 띄웁니다. **추가 정보 → 실행**을 누르세요.

## 동작 방식

별도 네이티브 코드 없이 Dart에서 `sc.exe`, PowerShell(`Get-CimInstance Win32_Service`), `reg.exe`만 호출합니다. 서비스를 제어하려면 관리자 권한이 필요해서 앱 매니페스트가 `requireAdministrator`를 요청합니다.

## 개발

```bash
flutter pub get
flutter run -d windows
```

Windows와 Flutter 데스크톱 도구(Visual Studio C++ 워크로드)가 필요합니다. 앱이 관리자 권한을 요청하므로 `flutter run`은 관리자 터미널에서 실행하세요.

릴리스: `scripts/bump-version.sh patch` → 병합 → `vX.Y.Z` 태그. CI가 Windows 설치 프로그램을 빌드해서 올립니다. 규칙: [application-release-templates/conventions](https://github.com/jejezz/application-release-templates/tree/main/conventions).

## 크레딧

- 글꼴: [서울남산체](https://www.seoul.go.kr/seoul/font.do) (서울특별시)
- 아이콘: [Icons8](https://icons8.com)

## 라이선스

[MIT](LICENSE) © 2026 Jongyun Ahn
