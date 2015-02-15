library flare.metadata_extractor.test;

import 'dart:io';
import 'dart:convert' show JSON;

import 'package:unittest/unittest.dart';
import 'package:code_transformers/src/test_harness.dart';

import 'package:flare/metadata_extractor.dart';

import 'testing_utils.dart';

void main() {
  final phases = [[new MetadataExtractor.asPlugin(emptyDebugSettings)]];
  
  group("The MetadataExtractor", () {
    test("extracts metadata from a content file", () async {
      final files = {
        'a|index.tmpl.md': new File('resources/index.tmpl.md').readAsStringSync()
      };

      final helper = new TestHelper(phases, files, const [])..run();

      final result = JSON.decode(await helper['a|index.meta.json']);

      expect(result['works'], equals(2));
      expect(result['front_matter'], equals("yes"));
    });
 });
}