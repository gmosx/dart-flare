library flare.markdown_transformer.test;

import 'dart:io';
import 'dart:convert' show JSON;

import 'package:unittest/unittest.dart';
import 'package:code_transformers/src/test_harness.dart';

import 'package:flare/markdown_transformer.dart';

import 'testing_utils.dart';

void main() {
  final phases = [[new MarkdownTransformer.asPlugin(emptyDebugSettings)]];

  group("The MarkdownTransformer", () {
    test("renders markdown files into html files", () async {
//      final files = {
//        'a|index.tmpl.md': new File('resources/index.tmpl.md').readAsStringSync()
//      };
//
//      final helper = new TestHelper(phases, files, const [])..run();
//
//      final result = JSON.decode(await helper['a|index.meta.json']);
//
//      expect(result['works'], equals(2));
//      expect(result['front_matter'], equals("yes"));
    });
 });
}