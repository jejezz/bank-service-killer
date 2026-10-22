import 'package:bank_service_killer/list_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  bool m(String q, {String name = 'nxTSSvc', String display = 'nxTS Process Manager Service', String note = '키보드보안, 드라이버', List<String> cats = const ['키보드보안']}) =>
      matchesSearch(q, name: name, displayName: display, note: note, categories: cats);

  test('빈 검색어(공백 포함)는 모두 맞는다', () {
    expect(m(''), isTrue);
    expect(m('   '), isTrue);
  });

  test('이름·표시 이름·메모·카테고리 어디든 들어 있으면 맞고, 대소문자를 가리지 않는다', () {
    expect(m('NXTSS'), isTrue);
    expect(m('process manager'), isTrue);
    expect(m('드라이버'), isTrue);
    expect(m('키보드'), isTrue);
  });

  test('어디에도 없으면 맞지 않는다', () {
    expect(m('wizvera'), isFalse);
  });

  test('앞뒤 공백은 무시한다', () {
    expect(m('  nxts  '), isTrue);
  });

  test('표시 이름·메모·카테고리가 없어도 이름만으로 검색된다', () {
    expect(matchesSearch('foo', name: 'FooSvc'), isTrue);
    expect(matchesSearch('bar', name: 'FooSvc'), isFalse);
  });
}
