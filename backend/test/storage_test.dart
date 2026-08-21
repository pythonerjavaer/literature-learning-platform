import 'dart:convert';
import 'dart:io';

import 'package:english_reader_backend/storage.dart';
import 'package:test/test.dart';

void main() {
  test('registration hashes credentials and login returns a session', () async {
    final directory = await Directory.systemTemp.createTemp('literature-store-');
    addTearDown(() => directory.delete(recursive: true));
    final store = JsonStore(directory.path);
    await store.init();

    await store.register('reader@example.test', 'correct-horse', 'Reader');
    final raw = jsonDecode(
      await File('${directory.path}/users.json').readAsString(),
    ) as Map<String, dynamic>;
    final user = (raw['users'] as List).first as Map<String, dynamic>;
    expect(user['passwordHash'], isNot('correct-horse'));
    expect(await store.login('reader@example.test', 'wrong'), isNull);
    expect(await store.login('reader@example.test', 'correct-horse'), isNotNull);
  });
}
