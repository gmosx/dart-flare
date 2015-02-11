library flare.metadata_transformer.test;

import 'dart:io';
import 'dart:convert' show JSON;

import 'package:unittest/unittest.dart';
import 'package:code_transformers/src/test_harness.dart';

import 'package:flare/metadata_transformer.dart';

final _phases = [[new MetadataTransformer.asPlugin()]];

void main() {
  group("The MetadataTransformer", () {
    test("translates metadata from yaml to json", () async {
      final files = {
        'a|index.yaml': new File('resources/index.yaml').readAsStringSync()
      };

      final helper = new TestHelper(_phases, files, const [])..run();

      final result = JSON.decode(await helper['a|index.meta.json']);

      expect(result['works'], equals(2));
      expect(result['front_matter'], equals("yes"));
    });
 });
}