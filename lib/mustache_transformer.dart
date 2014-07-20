library flare.mustache_transformer;

import 'dart:io';
import 'dart:async';
import 'dart:convert' show JSON;

import 'package:barback/barback.dart';
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
      final metaPath = '${asset.id.path.split(".").first}.meta.json';
      // Metadata is generated for all content files (.html, .md)
      return transform.getInput(new AssetId(asset.id.package, '${asset.id.path.split(".").first}.meta.json')).then((meta) {
        return meta.readAsString().then((json) {
          final data = JSON.decode(json);
          final template = mustache.parse(content);
          final newContent = template.renderString(data, htmlEscapeValues: false);
          final newId = new AssetId(asset.id.package, asset.id.path.replaceAll('.tmpl', ''));
          transform.consumePrimary();
          transform.addOutput(new Asset.fromString(newId, newContent));
        });
      });
    });
  }

  @override
  Future<bool> isPrimary(AssetId id) {
    // Only xxx.tmpl.yyy paths are primary assets for transformation.
    return new Future.value(_TMPL_RE.hasMatch(id.path));
  }
}