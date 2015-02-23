library flare.metadata_aggregator;

import 'dart:convert' show JSON;

import 'package:barback/barback.dart';
import 'package:barback/src/transformer/aggregate_transform.dart';
import 'package:barback/src/transformer/aggregate_transformer.dart';

import 'package:flare/flare.dart';

/// Aggregates all metadata files into a single metadata map which is accessible
/// everywhere under the [site] key.
class MetadataAggregator extends AggregateTransformer {
  static const String _metadataKey = 'meta';

  final BarbackSettings _settings;

  MetadataAggregator.asPlugin(this._settings);

  @override
  apply(AggregateTransform transform) async {
    String package;

    if (transform.key == _metadataKey) {
      final list = await transform.primaryInputs.toList();
      final metadata = await list.fold({'sitemap': {}}, (acc, asset) async {
        final metadata = await acc;
        package = asset.id.package;
        final json = await asset.readAsString();
        if (privateRE.hasMatch(asset.id.path)) {
          metadata.addAll(JSON.decode(json));
        } else {
          metadata['sitemap'][asset.id.path] = JSON.decode(json);
        }
        return metadata;
      });
      metadata['update_time'] = {
        'iso': new DateTime.now().toIso8601String()
      };
      final id = new AssetId(package, 'web/__site.$metadataExtension');
      transform.addOutput(new Asset.fromString(id, JSON.encode(metadata)));
    }
  }

  @override
  classifyPrimary(AssetId id) {
    if (id.path.endsWith(metadataExtension)) {
      return _metadataKey;
    } else {
      return null;
    }
  }
}
