library flare.posts_transformer;

import 'dart:io';
import 'dart:async';
import 'dart:convert' show JSON;

import 'package:barback/barback.dart';
import 'package:mustache/mustache.dart' as mustache;

import 'package:flare/flare.dart';

// TODO: Convert to AggregateTransformer.
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

  /// The output extension is changed to *.tmpl.html so that the layout
  /// template can be evaluated by a downstream transformer.
  @override
  apply(Transform transform) {
    final asset = transform.primaryInput;

    if (asset.id.path == _layoutPath) {
      transform.consumePrimary(); // TODO: remove in cleanup transformer?
    } else {
      return asset.readAsString().then((content) {
        return transform.getInput(new AssetId(asset.id.package, '${asset.id.path.split(".").first}.$METADATA_EXTENSION')).then((meta) {
          return meta.readAsString().then((json) {
            final data = JSON.decode(json);
            data['content'] = content;
            final newContent = _template.renderString(data, htmlEscapeValues: false);
            transform.consumePrimary();
            transform.addOutput(new Asset.fromString(asset.id.changeExtension('.tmpl.html'), newContent));
          });
        });
      });
    }
  }

  @override
  Future<bool> isPrimary(AssetId id) {
    return new Future.value(
        id.path == _layoutPath ||
        (id.path.startsWith(_rootPath) && id.path.endsWith('.html')));
  }
}