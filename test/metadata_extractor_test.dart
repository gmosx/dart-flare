library flare.metadata_extractor.test;

import 'dart:io';
import 'dart:convert' show JSON;

import 'package:unittest/unittest.dart';
import 'package:code_transformers/src/test_harness.dart';

import 'package:flare/metadata_extractor.dart';

final _phases = [[new MetadataExtractor.asPlugin()]];

void main() {
  group("The MetadataExtractor", () {
    test("extracts metadata from a content file", () async {
      final files = {
        'a|index.tmpl.md': new File('resources/index.tmpl.md').readAsStringSync()
      };

      final helper = new TestHelper(_phases, files, const [])..run();

      final result = JSON.decode(await helper['a|index.meta.json']);

      expect(result['works'], equals(2));
      expect(result['front_matter'], equals("yes"));
    });
 });
}