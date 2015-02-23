library flare.metadata_transformer;

// TODO: Reuse functionality from MetadataExtractor, e.g. normalizeData.

import 'dart:async';
import 'dart:convert' show JSON;

import 'package:barback/barback.dart';
import 'package:yaml/yaml.dart' show loadYaml;

import 'package:flare/flare.dart';

/// Translates metadata from yaml format to the internal json format.
class MetadataTranslator extends Transformer {
  final BarbackSettings _settings;

  MetadataTranslator.asPlugin([this._settings]) {
  }

  @override
  apply(Transform transform) async {
    final asset = transform.primaryInput;
    final yaml = await asset.readAsString();
    transform.consumePrimary();
    transform.addOutput(new Asset.fromString(asset.id.changeExtension('.$metadataExtension'),
        JSON.encode(loadYaml(yaml))));
  }

  @override
  Future<bool> isPrimary(AssetId id) async {
    return id.path.endsWith('.yaml');
  }
}