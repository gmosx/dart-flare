library flare.posts_transformer;

import 'dart:io';
import 'dart:async';

import 'package:barback/barback.dart';
import 'package:mustache/mustache.dart' as mustache;

// TODO: Add error-handling code.
// TODO: build a model of the posts, for index, categories, etc.

/// Renders a collection of posts.
class PostsTransformer extends Transformer {
  final BarbackSettings _settings;
  String _rootPath;
  String _layoutPath;
  mustache.Template _template;

  PostsTransformer.asPlugin(this._settings) {
    _rootPath = _settings.configuration['root'];
    _layoutPath = _settings.configuration['layout'];
    _template = mustache.parse(new File(_layoutPath).readAsStringSync());
  }

  @override
  apply(Transform transform) {
    final asset = transform.primaryInput;

    if (asset.id.path == _layoutPath) {
      transform.consumePrimary();
    } else {
      return asset.readAsString().then((content) {
        final newContent = _template.renderString({'content': content}, htmlEscapeValues: false);
        transform.consumePrimary();
        transform.addOutput(new Asset.fromString(asset.id, newContent));
      });
    }
  }

  @override
  Future<bool> isPrimary(AssetId id) {
    return new Future.value(
        id.path == _layoutPath ||
        id.path.startsWith(_rootPath));
  }
}