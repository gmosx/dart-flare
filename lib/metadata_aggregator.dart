library flare.metadata_aggregation_transformer;

import 'dart:convert' show JSON;

import 'package:barback/barback.dart';
import 'package:barback/src/transformer/aggregate_transform.dart';
import 'package:barback/src/transformer/aggregate_transformer.dart';
import 'package:quiver/async.dart';

import 'package:flare/flare.dart';

class MetadataAggregator extends AggregateTransformer {
  final BarbackSettings _settings;

  MetadataAggregator.asPlugin(this._settings) {
  }

  @override
  apply(AggregateTransform transform) {
    String package;

    if (transform.key == 'meta') {
      return transform.primaryInputs.toList().then((list) {
        return reduceAsync(list, {}, (metadata, asset) {
          package = asset.id.package;
          return asset.readAsString().then((content) {
            metadata[asset.id.path] = JSON.decode(content);
            return metadata;
          });
        });
      }).then((metadata) {
        final id = new AssetId(package, 'web/_site.$METADATA_EXTENSION');
        transform.addOutput(new Asset.fromString(id, JSON.encode(metadata)));
      });
    }
  }

  @override
  classifyPrimary(AssetId id) {
    if (id.path.endsWith(METADATA_EXTENSION)) {
      return 'meta'; // TODO: replace with enum.
    } else {
      return 'content';
    }
  }
}
