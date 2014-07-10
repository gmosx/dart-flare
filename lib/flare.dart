library flare;

// TODO: extract extension handlers, make more versatile.

import 'dart:io';
import 'dart:async';

import 'package:barback/barback.dart';
import 'package:markdown/markdown.dart' show markdownToHtml;
import 'package:mustache/mustache.dart' as mustache;

final metaRE = new RegExp('/_');

/// A Barback [Transformer] that builds the target site from the source
/// files.
class FlareTransformer extends Transformer {
  final BarbackSettings _settings;
  mustache.Template _template;

  FlareTransformer.asPlugin(this._settings) {
    _template = mustache.parse(new File('web/_layout/_layout.tmpl.html').readAsStringSync());
  }

  @override
  apply(Transform transform) {
    final asset = transform.primaryInput;
    final copyright = _settings.configuration['copyright'];

    if (metaRE.hasMatch(asset.id.path)) {
      transform.consumePrimary();
    } else if (asset.id.extension == '.html') {
      return asset.readAsString().then((content) {
//        String newContent = "$copyright$content";
        var newContent = _template.renderString({'content': content}, htmlEscapeValues: false);
        transform.addOutput(new Asset.fromString(asset.id, newContent));
      });
    }
  }

  @override
  Future<bool> isPrimary(AssetId id) {
    return new Future.value(id.path.startsWith('web/'));
  }
}