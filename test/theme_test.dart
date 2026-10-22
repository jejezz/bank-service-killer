import 'package:bank_service_killer/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final (name, theme) in [('다크', AppTheme.dark()), ('라이트', AppTheme.light())]) {
    group('$name 테마', () {
      test('입력칸은 대화상자 바탕과 다른 색으로 채우고 테두리가 있어 입력칸으로 보인다', () {
        final t = theme.inputDecorationTheme;
        expect(t.filled, isTrue);
        expect(t.fillColor, isNot(theme.dialogTheme.backgroundColor), reason: '같은 색이면 입력칸이 바탕에 묻힌다');
        for (final b in [t.border, t.enabledBorder, t.focusedBorder]) {
          expect((b as OutlineInputBorder).borderSide.style, BorderStyle.solid);
          expect(b.borderSide.width, greaterThan(0));
        }
      });

      test('포커스를 받은 입력칸은 강조색의 굵은 테두리다', () {
        final focused = (theme.inputDecorationTheme.focusedBorder! as OutlineInputBorder).borderSide;
        final normal = (theme.inputDecorationTheme.enabledBorder! as OutlineInputBorder).borderSide;
        expect(focused.color, theme.colorScheme.primary);
        expect(focused.width, greaterThan(normal.width));
      });

      test('탭은 탭 전체 너비에 굵은 표시와 옅은 바탕을 둔다 (가는 밑줄이 아니다)', () {
        final t = theme.tabBarTheme;
        expect(t.indicatorSize, TabBarIndicatorSize.tab);
        final deco = t.indicator! as BoxDecoration;
        expect(deco.color, isNotNull);
        final bottom = (deco.border! as Border).bottom;
        expect(bottom.width, greaterThanOrEqualTo(3));
        expect(bottom.color, theme.colorScheme.primary);
      });
    });
  }
}
