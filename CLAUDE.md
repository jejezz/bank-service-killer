릴리스·버전·패키징·정보 창·아이콘·라이선스·UI/UX·글꼴·언어·테마는
https://github.com/jejezz/application-release-templates/tree/main/conventions
규약을 따른다. 이 앱에 적용된 규약 버전: conventions-v1 (미적용: 아이콘 소품 글리프는 임시, README 스크린샷·GIF)

# Bank Service Killer

금융보안·키보드보안 같은 상주 서비스를 뱅킹할 때만 켜고 끄고, 실제로 on/off 되었는지 검증하는 **Windows 전용** Flutter 앱.
macOS/Linux 플랫폼은 만들지 않는다 (릴리스 워크플로도 Windows 잡만 둔다). 서비스 제어에 관리자 권한이 필요해 `runner.exe.manifest`가 `requireAdministrator`를 요청한다.
서비스 제어는 `sc.exe`/PowerShell/`reg.exe` 호출 (`lib/service_manager.dart`), 감시 목록은 `%APPDATA%\BankServiceKiller\watchlist.json`.
