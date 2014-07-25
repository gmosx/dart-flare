library flare.posts_indexer;

import 'dart:convert' show JSON;

import 'package:barback/barback.dart';
import 'package:barback/src/transformer/aggregate_transform.dart';
import 'package:barback/src/transformer/aggregate_transformer.dart';
import 'package:quiver/async.dart';

import 'package:flare/flare.dart';

class PostsIndexer extends AggregateTransformer {
  final BarbackSettings _settings;
  String _rootPath;

  PostsIndexer.asPlugin(this._settings) {
    _rootPath = _settings.configuration['root'];
  }

  @override
  apply(AggregateTransform transform) {
    String package;

    if (transform.key == 'post') {
      return transform.primaryInputs.toList().then((list) {
        return reduceAsync(list, [], (posts, asset) {
          package = asset.id.package;
          return asset.readAsString().then((content) {
            return transform.getInput(new AssetId(asset.id.package, '${asset.id.path.split(".").first}.$METADATA_EXTENSION')).then((meta) {
              return meta.readAsString().then((json) {
                final data = JSON.decode(json);
                data['content'] = content;
                final newId = _rewriteAssetId(asset.id);
                data['path'] = newId.path;
                posts.add(data);
                return posts;
              });
            });
          });
        });
      }).then((posts) {
        final id = new AssetId(package, 'web/_posts.$METADATA_EXTENSION');
        transform.addOutput(new Asset.fromString(id, JSON.encode(posts)));
      });
    }
  }

  @override
  classifyPrimary(AssetId id) {
    if (id.path.startsWith(_rootPath) && id.path.endsWith('.html')) {
      return 'post';
    } else {
      return null;
    }
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
