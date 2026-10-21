## 설치 / Install

| OS | 받을 파일 / File |
|---|---|
| Windows 10/11 (x64) | `*-windows-x64-setup.exe` |

서비스를 제어하므로 앱은 관리자 권한으로 실행됩니다. / The app runs as administrator because it controls Windows services.

**Windows**: 설치 프로그램에 아직 코드 서명이 없어서 SmartScreen이 "Windows의 PC 보호" 창을 띄웁니다. **추가 정보 → 실행**을 누르면 설치가 진행됩니다.
The installer isn't code-signed yet, so SmartScreen shows "Windows protected your PC" — choose **More info → Run anyway**.

받은 파일은 `SHA256SUMS.txt`로 확인할 수 있습니다: `sha256sum -c SHA256SUMS.txt --ignore-missing`

---
