library flare.html_optimizer.test;

import 'package:unittest/unittest.dart';
import 'package:code_transformers/src/test_harness.dart';

import 'package:flare/html_optimizer.dart';

final _phases = [[new HtmlOptimizer.asPlugin()]];

void main() {
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

      final helper = new TestHelper(_phases, files, const [])..run();

      final result = await helper['a|index.html'];
      expect(result, equals('<html lang="el"><head></head><body>Nice <span class="new">stuff</span> man!</body></html>'));
    });
 });
}