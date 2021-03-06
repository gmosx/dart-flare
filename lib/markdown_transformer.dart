library flare.markdown_transformer;

import 'dart:async';

import 'package:barback/barback.dart';
import 'package:markdown/markdown.dart' show markdownToHtml;

/// Renders markdown files into html files.
class MarkdownTransformer extends Transformer {
  final BarbackSettings _settings;

  MarkdownTransformer.asPlugin(this._settings);

  @override
  apply(Transform transform) async {
    final asset = transform.primaryInput;
    final content = await asset.readAsString();
    transform.consumePrimary();
    transform.addOutput(new Asset.fromString(asset.id.changeExtension('.html'),
        markdownToHtml(content)));
  }

  @override
  Future<bool> isPrimary(AssetId id) async {
    return id.path.endsWith('.md');
  }
}