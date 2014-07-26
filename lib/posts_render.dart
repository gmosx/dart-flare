library flare.posts_transformer;

import 'dart:io';
import 'dart:async';
import 'dart:convert' show JSON;

import 'package:barback/barback.dart';

import 'package:flare/flare.dart';

// TODO: Convert to AggregateTransformer.
// TODO: Add error-handling code.
// TODO: build a model of the posts, for index, categories, etc.

/// Renders a collection of posts.
class PostsRender extends Transformer {
  static final _CONTENT_RE = new RegExp(r'{{content}}');

  final BarbackSettings _settings;
  String _rootPath;
  String _layoutPath;
  String _layout;

  PostsRender.asPlugin(this._settings) {
    _rootPath = _settings.configuration['root'];
    _layoutPath = _settings.configuration['layout'];
    _layout = new File(_layoutPath).readAsStringSync();
  }

  /// The output extension is changed to *.tmpl.html so that the layout
  /// template can be evaluated by a downstream transformer.
  @override
  apply(Transform transform) {
    final asset = transform.primaryInput;

    return asset.readAsString().then((content) {
      return transform.getInput(new AssetId(asset.id.package, '${asset.id.path.split(".").first}.$METADATA_EXTENSION')).then((meta) {
        return meta.readAsString().then((json) {
          final data = JSON.decode(json);
          final newContent = _layout.replaceAll(_CONTENT_RE, content);
          transform.consumePrimary();
          final newId = _rewriteAssetId(asset.id);
          transform.addOutput(new Asset.fromString(newId.changeExtension('.meta.json'), json));
          transform.addOutput(new Asset.fromString(newId.changeExtension('.tmpl.html'), newContent));
        });
      });
    });
  }

  @override
  Future<bool> isPrimary(AssetId id) {
    return new Future.value((id.path.startsWith(_rootPath) &&
        (!PRIVATE_RE.hasMatch(id.path)) && id.path.endsWith('.html')));
  }

  AssetId _rewriteAssetId(AssetId id) {
    var path = id.path;

    // TODO: crappy, use some cool RegExp here!
    path = path.replaceFirst('-', '/');
    path = path.replaceFirst('-', '/');
    path = path.replaceFirst('-', '/');

    return new AssetId(id.package, path);
  }
}