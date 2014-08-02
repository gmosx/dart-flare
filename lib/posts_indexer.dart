library flare.posts_indexer;

import 'dart:convert' show JSON;

import 'package:barback/barback.dart';
import 'package:barback/src/transformer/aggregate_transform.dart';
import 'package:barback/src/transformer/aggregate_transformer.dart';
import 'package:quiver/async.dart';

import 'package:flare/flare.dart';

/// Computes indexing metadata for the posts.
class PostsIndexer extends AggregateTransformer {
  static const _POSTS_KEY = 1;
  static final _PATH_PREFIX = new RegExp(r'^web/');

  final BarbackSettings _settings;
  String _rootPath;

  PostsIndexer.asPlugin(this._settings) {
    _rootPath = _settings.configuration['root'];
  }

  @override
  apply(AggregateTransform transform) {
    String package;

    if (transform.key == _POSTS_KEY) {
      return transform.primaryInputs.toList().then((list) {
        return reduceAsync(list, [], (posts, asset) {
          package = asset.id.package;
          return asset.readAsString().then((content) {
            return transform.getInput(new AssetId(asset.id.package, '${asset.id.path.split(".").first}.$METADATA_EXTENSION')).then((meta) {
              return meta.readAsString().then((json) {
                final data = JSON.decode(json);
                data['path'] = asset.id.path.replaceAll(_PATH_PREFIX, ''); // TODO: temp hack.
                data['content'] = content;
                posts.add(data);
                return posts;
              });
            });
          });
        });
      }).then((List<Map> posts) {
        // Sort the posts by path (effectively by inverse chronological order).
        posts.sort((x, y) => y['path'].compareTo(x['path']));

        final id = new AssetId(package, 'web/_posts.$METADATA_EXTENSION');
        transform.addOutput(new Asset.fromString(id, JSON.encode({'posts': posts})));
      });
    }
  }

  @override
  classifyPrimary(AssetId id) {
    if (id.path.startsWith(_rootPath) && id.path.endsWith('.html')) {
      return _POSTS_KEY;
    } else {
      return null;
    }
  }
}
