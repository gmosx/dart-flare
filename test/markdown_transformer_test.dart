library flare.markdown_transformer.test;

import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:code_transformers/src/test_harness.dart';

import 'package:flare/markdown_transformer.dart';

import 'testing_utils.dart';

void main() {
  final phases = [[new MarkdownTransformer.asPlugin(emptyDebugSettings)]];

  group("The MarkdownTransformer", () {
    test("renders markdown into html", () async {
      final files = {
        'a|index.tmpl.md': new File('resources/index.tmpl.md').readAsStringSync()
      };

      final helper = new TestHelper(phases, files, const [])..run();

      final result = await helper['a|index.tmpl.html'];

      expect(result, stringContainsInOrder([
        '<h1>Title</h1>',
        '<p>Some great markdown content. Ignore.</p>'
      ]));
    });
 });
}