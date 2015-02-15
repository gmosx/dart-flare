library flare.partials_transformer.test;

import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:code_transformers/src/test_harness.dart';

import 'package:flare/partials_transformer.dart';

import 'testing_utils.dart';

// TODO: test include on inlcude
// TODO: test absolute include

void main() {
  final phases = [[new PartialsTransformer.asPlugin(emptyDebugSettings)]];

  group("The PartialsTransformer", () {
    test("extracts metadata from a content file", () async {
      final files = {
        'a|parent.tmpl.html': new File('resources/parent.tmpl.html').readAsStringSync(),
        'a|_child.inc.html': new File('resources/_child.inc.html').readAsStringSync()
      };

      final helper = new TestHelper(phases, files, const [])..run();

      final result = await helper['a|parent.tmpl.html'];

      expect(result, equals('<html><b>hello from the child</b></html>'));
    });
 });
}