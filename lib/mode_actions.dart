/// 뱅킹/개발 모드를 화면 밖(트레이 메뉴 등)에서 부르기 위한 연결 고리.
/// HomePage 가 살아 있는 동안만 채워 두고, 없으면 null 이다.
class ModeActions {
  Future<void> Function()? banking;
  Future<void> Function()? dev;
}
