library flare.mustache_transformer;

import 'dart:io';
import 'dart:async';

import 'package:barback/barback.dart';
import 'package:yaml/yaml.dart' show loadYaml, YamlMap;
import 'package:mustache/mustache.dart' as mustache;

// TODO: add a setting to point to yaml file with default data.

/// A Barback [Transformer] that evaluates Mustache template files.
class MustacheTransformer extends Transformer {
  static final _TMPL_RE = new RegExp(r'.tmpl.');

  final BarbackSettings _settings;

  MustacheTransformer.asPlugin(this._settings) {
  }

  @override
  apply(Transform transform) {
    final asset = transform.primaryInput;

    return asset.readAsString().then((content) {
      final template = mustache.parse(content);
      final newContent = template.renderString(_getTemplateData(asset.id), htmlEscapeValues: false);
      final newId = new AssetId(asset.id.package, asset.id.path.replaceAll('.tmpl', ''));
      transform.consumePrimary();
      transform.addOutput(new Asset.fromString(newId, newContent));
    });
  }

  @override
  Future<bool> isPrimary(AssetId id) {
    // Only xxx.tmpl.yyy paths are primary assets for transformation.
    return new Future.value(_TMPL_RE.hasMatch(id.path));
  }

  Map _getTemplateData(AssetId id) {
    // Default template data.
    var data = {
      'date': new DateTime.now().toString()
    };

    final metaPath = '${id.path.split(".").first}.yaml';
    final metaFile = new File(metaPath);

    if (metaFile.existsSync()) {
      data.addAll(loadYaml(metaFile.readAsStringSync()));
    }

    return data;
  }
}