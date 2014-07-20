import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:flare/flare.dart';

void main() {
  group("Extracting 'front matter' data", () {
    final source = new File('resources/index.tmpl.md').readAsStringSync();
    final result = extractMetadata(source);
    final data = result.last as Map;

    test("removes the 'front matter' from the input", () {
      expect(result.first, startsWith("Title"));
    });

    test("parses data from the 'front matter'", () {
      expect(data.length, equals(2));
    });
  });
}