library flare.metadata_extractor;

import 'dart:io';
import 'dart:convert' show JSON;
import 'dart:async';

import 'package:intl/intl.dart';
import 'package:barback/barback.dart';
import 'package:yaml/yaml.dart' show loadYaml;

import 'package:flare/flare.dart';

const String defaultOpenDelimiter = "<!--\n";
const String defaultCloseDelimiter = "-->\n";
const String defaultDateFormatString = 'yMMMMd';

/// Extracts metadata from content files. Metadata can be included as 'front-matter'
/// inside the content file, or attached to an external file with the same basename
/// and .yaml extension. Metadata is defined in YAML format. The metadata is
/// normalized and translated to the internal JSON format.
class MetadataExtractor extends Transformer {
  static final _contentRE = new RegExp(r'(.html$)|(.md$)');
  static final _dateRE = new RegExp(r'[Dd]ate$');

  BarbackSettings _settings;
  DateFormat _dateFormat;
  String _openDelimiter;
  String _closeDelimiter;

  MetadataExtractor.asPlugin(this._settings) {
    _openDelimiter = _settings.configuration.containsKey('open_delimiter') ?
        _settings.configuration['open_delimiter'] : defaultOpenDelimiter;

    _closeDelimiter = _settings.configuration.containsKey('close_delimiter') ?
        _settings.configuration['close_delimiter'] : defaultCloseDelimiter;

    _dateFormat = new DateFormat(
        _settings.configuration.containsKey('date_format') ?
            _settings.configuration['date_format'] : defaultDateFormatString);
  }

  @override
  apply(Transform transform) {
    final asset = transform.primaryInput;

    return asset.readAsString().then((content) {
      final data = {};

      content = _addFrontMatterMetadata(content, data);
      _addExternalMetadata(asset, data);

      if (data.isNotEmpty) {
        final id = new AssetId(asset.id.package, "${asset.id.path.split(".").first}.$metadataExtension");
        transform.addOutput(new Asset.fromString(id, JSON.encode(_normalizeData(data))));
        transform.addOutput(new Asset.fromString(asset.id, content));
      }
    });
  }

  @override
  Future<bool> isPrimary(AssetId id) {
    return new Future.value(_contentRE.hasMatch(id.path));
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
      if (_dateRE.hasMatch(key)) {
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