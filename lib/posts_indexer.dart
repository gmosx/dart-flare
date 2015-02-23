library flare.posts_indexer;

import 'dart:convert' show JSON;

import 'package:barback/barback.dart';
import 'package:barback/src/transformer/aggregate_transform.dart';
import 'package:barback/src/transformer/aggregate_transformer.dart';
import 'package:quiver/async.dart';

import 'package:flare/flare.dart';

/// Computes indexing metadata for the posts.
class PostsIndexer extends AggregateTransformer {
  static const _postsKey = 'posts';
  static final _pathPrefix = new RegExp(r'^web/');

  final BarbackSettings _settings;
  String _rootPath;

  PostsIndexer.asPlugin(this._settings) {
    _rootPath = _settings.configuration['root'];
  }

  @override
  apply(AggregateTransform transform) {
    String package;
    Map<String, List<String>> labels = {};

    if (transform.key == _postsKey) {
      return transform.primaryInputs.toList().then((list) {
        return reduceAsync(list, [], (posts, asset) {
          package = asset.id.package;
          return asset.readAsString().then((content) {
            return transform.getInput(new AssetId(asset.id.package, '${asset.id.path.split(".").first}.$metadataExtension')).then((meta) {
              return meta.readAsString().then((json) {
                final data = JSON.decode(json);
                data['path'] = asset.id.path.replaceAll(_pathPrefix, ''); // TODO: temp hack.
                data['content'] = content;
                posts.add(data);

                // TODO: extract to separate labels_indexer.
                data['labels'].forEach((label) {
                  if (!labels.containsKey(label)) {
                    labels[label] = [];
                  }
                  labels[label].add(data['path']);
                });

                return posts;
              });
            });
          });
        });
      }).then((List<Map> posts) {
        // Sort the posts by path (effectively by inverse chronological order).
        posts.sort((x, y) => y['path'].compareTo(x['path']));

        final labelsList = [];

        labels.forEach((title, paths) {
          labelsList.add({
            'title': title,
            'count': paths.length,
            'posts': paths
          });
        });

        // TODO: make posts count a configuration parameter!
        final metadata = {
          'posts': {
            'latest': posts.length > 10 ? posts.sublist(0, 10) : posts,
            'all': posts,
            'labels': labelsList
          }
        };

        final id = new AssetId(package, 'web/_posts.$metadataExtension');
        transform.addOutput(new Asset.fromString(id, JSON.encode(metadata)));
      });
    }
  }

  @override
  classifyPrimary(AssetId id) {
    if (id.path.startsWith(_rootPath) && id.path.endsWith('.html')) {
      return _postsKey;
    } else {
      return null;
    }
  }
}
