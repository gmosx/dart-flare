library flare.metadata_transformer;

import 'dart:async';
import 'dart:convert' show JSON;

import 'package:barback/barback.dart';
import 'package:yaml/yaml.dart' show loadYaml;

import 'package:flare/flare.dart';

/// Converts metadata from yaml format to the internal json format.
class MetadataTransformer extends Transformer {
  final BarbackSettings _settings;

  MetadataTransformer.asPlugin(this._settings) {
  }

  @override
  apply(Transform transform) {
    final asset = transform.primaryInput;

    return asset.readAsString().then((yaml) {
      transform.consumePrimary();
      transform.addOutput(new Asset.fromString(asset.id.changeExtension('.$METADATA_EXTENSION'),
          JSON.encode(loadYaml(yaml))));
    });
  }

  @override
  Future<bool> isPrimary(AssetId id) {
    return new Future.value(id.path.endsWith('.yaml'));
  }
}