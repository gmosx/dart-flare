library flare.markdown_transformer;

import 'dart:async';

import 'package:barback/barback.dart';
import 'package:markdown/markdown.dart' show markdownToHtml;

/// A Barback [Transformer] that builds the target site from the source
/// files.
class MarkdownTransformer extends Transformer {
  final BarbackSettings _settings;

  MarkdownTransformer.asPlugin(this._settings) {
  }

  @override
  apply(Transform transform) {
    final asset = transform.primaryInput;

    return asset.readAsString().then((content) {
      transform.consumePrimary();
      transform.addOutput(new Asset.fromString(asset.id.changeExtension('.html'),
          markdownToHtml(content)));
    });
  }

  @override
  Future<bool> isPrimary(AssetId id) {
    return new Future.value(id.path.endsWith('.md'));
  }
}