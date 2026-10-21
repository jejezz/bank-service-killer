import 'dart:io';

import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

/// 로그온 시 관리자 권한으로 자동 실행되는 예약 작업 관리.
///
/// 관리자 권한(requireAdministrator) 앱은 Run 레지스트리 키로는 시작되지 않으므로
/// 최고 수준 권한(RunLevel Highest)의 로그온 예약 작업으로 등록한다 (UAC 프롬프트 없음).
/// 등록하려면 앱이 관리자 권한으로 떠 있어야 한다.
class StartupManager {
  static const taskName = 'BankServiceKiller';

  /// 시작프로그램으로 실행됐음을 알리는 인자 — 창 없이 트레이에만 상주한다.
  static const backgroundArg = '--background';

  static Future<bool> isRegistered() async {
    final r = await Process.run('schtasks', ['/Query', '/TN', taskName]);
    return r.exitCode == 0;
  }

  /// 실패하면 사유를 돌려주고, 성공하면 null.
  static Future<String?> register() async {
    const script =
        r'$a = New-ScheduledTaskAction -Execute $env:BSK_EXE -Argument $env:BSK_ARG; '
        r'$t = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"; '
        r'$p = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Highest; '
        r'$s = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries '
        r'-StartWhenAvailable -ExecutionTimeLimit ([TimeSpan]::Zero); '
        r'Register-ScheduledTask -TaskName $env:BSK_TASK -Action $a -Trigger $t -Principal $p -Settings $s -Force | Out-Null';
    final r = await Process.run(
      'powershell',
      ['-NoProfile', '-NonInteractive', '-Command', script],
      environment: {
        'BSK_EXE': Platform.resolvedExecutable,
        'BSK_ARG': backgroundArg,
        'BSK_TASK': taskName,
      },
    );
    return r.exitCode == 0 ? null : '${r.stderr}'.trim();
  }

  static Future<String?> unregister() async {
    final r = await Process.run('schtasks', ['/Delete', '/TN', taskName, '/F']);
    return r.exitCode == 0 ? null : '${r.stderr}'.trim();
  }
}

/// 앱 바의 시작프로그램 토글 (체크 표시가 있는 팝업 메뉴).
class StartupMenuButton extends StatefulWidget {
  const StartupMenuButton({super.key});

  @override
  State<StartupMenuButton> createState() => _StartupMenuButtonState();
}

class _StartupMenuButtonState extends State<StartupMenuButton> {
  bool _registered = false;

  @override
  void initState() {
    super.initState();
    StartupManager.isRegistered().then((v) {
      if (mounted) setState(() => _registered = v);
    });
  }

  Future<void> _toggle() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final error = _registered ? await StartupManager.unregister() : await StartupManager.register();
    if (!mounted) return;
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.startupChangeFailed(error))));
    }
    final now = await StartupManager.isRegistered();
    if (mounted) setState(() => _registered = now);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<bool>(
      tooltip: l10n.startupMenuTooltip,
      icon: Icon(
        Icons.power_settings_new_rounded,
        color: _registered ? AppColors.success : null,
      ),
      onSelected: (_) => _toggle(),
      itemBuilder: (_) => [
        CheckedPopupMenuItem<bool>(
          value: true,
          checked: _registered,
          child: Text(l10n.startupAutoRun),
        ),
      ],
    );
  }
}
