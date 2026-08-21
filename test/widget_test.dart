import 'package:flutter_test/flutter_test.dart';

import 'package:english_reader/main.dart';

void main() {
  test('theme provider switches between light and dark modes', () {
    final provider = ThemeProvider();
    expect(provider.isDarkMode, isFalse);
    provider.toggleTheme();
    expect(provider.isDarkMode, isTrue);
  });
}
