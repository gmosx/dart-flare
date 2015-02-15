library flare.html_optimizer.test;

import 'package:unittest/unittest.dart';
import 'package:code_transformers/src/test_harness.dart';

import 'package:flare/html_optimizer.dart';

import 'testing_utils.dart';

void main() {
  final phases = [[new HtmlOptimizer.asPlugin(emptyDebugSettings)]];

  group("The html5_optimizer", () {
    test("removes html comments", () async {
      final files = {
        'a|index.html':
            '''
            <html lang="el">
              <head>
              </head>
              <body>
                <!-- this is a comment -->
                Nice     <span class="new">stuff <!-- works--></span>
                man!
              </body>
            </html>
            '''
      };

      final helper = new TestHelper(phases, files, const [])..run();

      final result = await helper['a|index.html'];
      expect(result, equals('<html lang="el"><head></head><body>Nice <span class="new">stuff</span> man!</body></html>'));
    });
 });
}