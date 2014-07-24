library flare.metadata_transformer;

// TODO: handle original input form both yaml and json.

import 'dart:io';
import 'dart:convert' show JSON;
import 'dart:async';

import 'package:barback/barback.dart';
import 'package:yaml/yaml.dart' show loadYaml;

import 'package:flare/flare.dart';

// TODO: add support for user-defined defaults through [BarbackSettings].
Map DEFAULT_METADATA = {
  'time': new DateTime.now().toString()
};

const String DEFAULT_OPEN_DELIMITER = "<!--\n";
const String DEFAULT_CLOSE_DELIMITER = "-->\n";

class MetadataTransformer extends Transformer {
  static final _CONTENT_RE = new RegExp(r'(.html$)|(.md$)');

  final BarbackSettings _settings;
  String _openDelimiter;
  String _closeDelimiter;

  MetadataTransformer.asPlugin(this._settings) {
    _openDelimiter = _settings.configuration.containsKey('open_delimiter') ?
        _settings.configuration['open_delimiter'] : DEFAULT_OPEN_DELIMITER;

    _closeDelimiter = _settings.configuration.containsKey('close_delimiter') ?
        _settings.configuration['close_delimiter'] : DEFAULT_CLOSE_DELIMITER;
  }

  @override
  apply(Transform transform) {
    final asset = transform.primaryInput;

    return asset.readAsString().then((content) {
      final data = new Map.from(DEFAULT_METADATA);

      content = _addFrontMatterMetadata(content, data);
      _addExternalMetadata(asset, data);

      final id = new AssetId(asset.id.package, "${asset.id.path.split(".").first}.$METADATA_EXTENSION");
      transform.addOutput(new Asset.fromString(id, JSON.encode(data)));
      transform.addOutput(new Asset.fromString(asset.id, content));
    });
  }

  @override
  Future<bool> isPrimary(AssetId id) {
    return new Future.value(_CONTENT_RE.hasMatch(id.path));
  }

  // Try to add 'front matter' metadata.
  String _addFrontMatterMetadata(String content, Map data) {
    // TODO: do it with a single regular expression.
    if (content.startsWith(_openDelimiter)) {
      final parts = content.split(_closeDelimiter);
      final yaml = parts.removeAt(0).replaceFirst(_openDelimiter, "");
      data.addAll(loadYaml(yaml));
      content = parts.join(_closeDelimiter);
    }

    return content;
  }

  // Try to add external file metadata.
  void _addExternalMetadata(Asset asset, Map data) {
    final metaPath = '${asset.id.path.split(".").first}.yaml';
    final metaFile = new File(metaPath);

    if (metaFile.existsSync()) {
      data.addAll(loadYaml(metaFile.readAsStringSync()));
    }
  }
}