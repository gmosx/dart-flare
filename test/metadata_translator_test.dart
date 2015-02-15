library flare.metadata_transformer.test;

import 'dart:io';
import 'dart:convert' show JSON;

import 'package:unittest/unittest.dart';
import 'package:code_transformers/src/test_harness.dart';

import 'package:flare/metadata_translator.dart';

import 'testing_utils.dart';

void main() {
  final phases = [[new MetadataTranslator.asPlugin(emptyDebugSettings)]];

  group("The MetadataTranslator", () {
    test("translates metadata from yaml to json", () async {
      final files = {
        'a|index.yaml': new File('resources/index.yaml').readAsStringSync()
      };

      final helper = new TestHelper(phases, files, const [])..run();

      final result = JSON.decode(await helper['a|index.meta.json']);

      expect(result['works'], equals(2));
      expect(result['front_matter'], equals("yes"));
    });
 });
}