// TODO: htf can we test private methods?
//
//import 'dart:io';
//import 'dart:mirrors';
//
//import 'package:barback/barback.dart';
//import 'package:unittest/unittest.dart';
//import 'package:flare/metadata_transformer.dart';
//
//void main() {
//  group("Extracting 'front matter' data", () {
//    final t = new MetadataTransformer.asPlugin(new BarbackSettings({}, BarbackMode.DEBUG));
//    final im = reflect(t);
//    final source = new File('resources/index.tmpl.md').readAsStringSync();
//    final data = {};
//    final result = im.invoke(#_addFrontMatterMetadata, [source, data]);
//
//    test("removes the 'front matter' from the input", () {
//      expect(result.reflectee, startsWith("Title"));
//    });
//
//    test("parses data from the 'front matter'", () {
//      expect(data.length, equals(2));
//    });
//  });
//}