library flare.metadata_extractor;

import 'dart:io';
import 'dart:convert' show JSON;
import 'dart:async';

import 'package:intl/intl.dart';
import 'package:barback/barback.dart';
import 'package:yaml/yaml.dart' show loadYaml;

import 'package:flare/flare.dart';

const String DEFAULT_OPEN_DELIMITER = "<!--\n";
const String DEFAULT_CLOSE_DELIMITER = "-->\n";

/// Extracts metadata from content files. Metadata can be included as 'front-matter'
/// inside the content file, or attached to an external file with the same basename
/// and .yaml extension. Metadata is defined in YAML format.
class MetadataExtractor extends Transformer {
  static final _CONTENT_RE = new RegExp(r'(.html$)|(.md$)');
  static final _DATE_RE = new RegExp(r'[Dd]ate$');

  final BarbackSettings _settings;
  DateFormat _dateFormat;
  String _openDelimiter;
  String _closeDelimiter;

  MetadataExtractor.asPlugin(this._settings) {
    _openDelimiter = _settings.configuration.containsKey('open_delimiter') ?
        _settings.configuration['open_delimiter'] : DEFAULT_OPEN_DELIMITER;

    _closeDelimiter = _settings.configuration.containsKey('close_delimiter') ?
        _settings.configuration['close_delimiter'] : DEFAULT_CLOSE_DELIMITER;

    _dateFormat = new DateFormat('yMMMMd'); // TODO: make customizable.
  }

  @override
  apply(Transform transform) {
    final asset = transform.primaryInput;

    return asset.readAsString().then((content) {
      final data = {};

      content = _addFrontMatterMetadata(content, data);
      _addExternalMetadata(asset, data);

      if (data.isNotEmpty) {
        final id = new AssetId(asset.id.package, "${asset.id.path.split(".").first}.$METADATA_EXTENSION");
        transform.addOutput(new Asset.fromString(id, JSON.encode(_normalizeData(data))));
        transform.addOutput(new Asset.fromString(asset.id, content));
      }
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

  // Formats dates as human, iso.
  Map _normalizeData(Map data) {
    data.keys.forEach((key) {
      if (_DATE_RE.hasMatch(key)) {
        try {
          var date = DateTime.parse(data[key]);
          data[key] = {
            'human': _dateFormat.format(date),
            'iso': date.toIso8601String()
          };
        } on FormatException catch (e) {
          // TODO: Temp hack-fix until I convert all my blog posts.
          data[key] = {
            'human': data[key],
            'iso': new DateTime.now().toIso8601String()
          };
        }
      }
    });

    return data;
  }
}