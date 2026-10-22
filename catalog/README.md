# 보안 서비스 카탈로그

금융·공공 사이트가 요구하는 보안 서비스가 **어떤 이름·실행 파일로 설치되는지** 적어 둔 데이터예요.
앱은 이 파일을 정기적으로(24시간마다) 받아서 이 PC의 서비스와 견주고, "이 PC에서 발견했지만 목록에 없는 서비스"와
"이름이 바뀐 것 같은 항목"을 **제안**해요. 카탈로그는 서비스를 자동으로 켜거나 끄지 않아요.

- `catalog.json` — 카탈로그 본문. 앱에도 기본값으로 들어가요 (원격 갱신이 꺼져 있어도 이것은 써요).
- `catalog.json.sig` — `catalog.json` 바이트 전체에 대한 Ed25519 분리 서명(base64).
- `public_key.txt` — 서명 확인용 공개키(base64). CI 가 이것으로 검증해요.

## 형식 (`schema: 1`)

```json
{
  "schema": 1,
  "version": 2,
  "updated": "2026-10-22",
  "categories": { "web-plugin": { "ko": "웹 플러그인", "en": "Web plugin" } },
  "products": [
    {
      "id": "nxts",
      "name": "nxTS",
      "vendor": "…",
      "categories": ["keyboard-security"],
      "usedBy": ["bank"],
      "driver": true,
      "note": { "ko": "…", "en": "…" },
      "match": [
        { "service": "nxTS Process Manager Service" },
        { "service": "nxTSSvc" },
        { "exe": "nxtssvc.exe" }
      ]
    }
  ]
}
```

- **`version`은 올라가기만 해요.** 앱은 같거나 낮은 버전으로는 바꾸지 않아요 (되돌리기·재생 방지). 고칠 때마다 올리세요.
- **`match`는 규칙의 목록**이고, 하나라도 맞으면 그 제품이에요. 규칙 하나 안에서는 적은 항목이 **모두** 맞아야 해요.
  - `service` — 서비스 이름 또는 표시 이름과 (대소문자 무시) 같아야 해요.
  - `exe` — 실행 파일 이름. 버전이 바뀌어 서비스 이름이 달라져도 실행 파일은 그대로인 경우가 많아서 이름과 함께 적어 두면 좋아요.
  - `signer` — 서명자에 들어 있어야 해요. 서명자만 쓰는 규칙은 너무 넓어서 검사에서 막혀요 (`exe`나 `service`와 같이 쓰세요).
- 이름이 바뀐 서비스를 짚으려면, **옛 이름을 `service`로 남겨 두세요.** 앱은 "목록에 옛 이름 항목이 있는데 이 PC에는 없고,
  같은 제품이 다른 이름으로 설치돼 있으면" 이름 변경을 제안해요.
- 카테고리는 `categories`의 id를 쓰고, 사용자 PC에는 그 언어의 이름으로 만들어져요.

## 고치는 법

1. `catalog/catalog.json`을 고치고 `version`을 올려요.
2. 서명해요:
   ```
   $env:CATALOG_SIGNING_KEY = '<비밀 시드>'
   dart run tool/catalog/sign.dart
   ```
3. `dart run tool/catalog/verify.dart`로 확인한 뒤 `catalog.json`과 `catalog.json.sig`를 함께 커밋해요.

사용자 신고는 GitHub 이슈(`catalog` 라벨)로 들어와요. 확인한 뒤 위 순서로 반영하세요.
신고에는 서비스 이름·표시 이름·실행 파일 이름·서명자만 담겨요 (경로는 담지 않아요).

## 처음 한 번: 서명 키 만들기

```
dart run tool/catalog/keygen.dart
```

- **PUBLIC**은 `catalog/public_key.txt`에 넣고 커밋해요.
- **SECRET**은 비밀번호 관리자에만 보관하고 **저장소에 넣지 않아요.** 잃으면 새 키를 만들어 앱을 다시 배포해야 해요.
- 앱에 공개키를 박으려면 빌드 때 `--dart-define=CATALOG_PUBLIC_KEY=<PUBLIC>`을 줘요.
  릴리스 워크플로는 저장소 변수 `CATALOG_PUBLIC_KEY`를 읽어요 (Settings → Secrets and variables → Actions → Variables).
- **공개키가 비어 있으면 앱은 원격 갱신을 끄고** 앱에 들어 있는 카탈로그만 써요. 서명 없이 받은 데이터는 절대 쓰지 않아요.

## 보안 모델

이 앱은 관리자 권한으로 서비스를 멈추므로, 카탈로그가 바뀌면 곧 위험이 돼요. 그래서:

- 받은 카탈로그와 디스크에 둔 캐시 모두 **읽을 때마다 서명을 확인**해요.
- 앱에 들어 있는 공개키로만 확인하므로, 서버·저장소가 뚫려도 비밀 키가 없으면 새 카탈로그를 만들 수 없어요.
- 버전이 낮아지는 카탈로그는 거절해요.
- 카탈로그는 **제안만** 해요. 목록에 넣고 어떤 모드에서 켤지는 사용자가 정해요.
