library flare.mustache_transformer;

// TODO: embed metadata.dart here.
// TODO: handle original input form both yaml and json.

import 'dart:convert' show JSON;
import 'dart:async';

import 'package:barback/barback.dart';
import 'package:flare/flare.dart';

class MetadataTransformer extends Transformer {
  static const String METADATA_EXTENSION = '.meta.json';
  static final _CONTENT_RE = new RegExp(r'(.html$)|(.md$)');

  final BarbackSettings _settings;

  MetadataTransformer.asPlugin(this._settings) {
  }

  @override
  apply(Transform transform) {
    final asset = transform.primaryInput;

    return asset.readAsString().then((content) {
      final data = new Map.from(DEFAULT_METADATA);
      final result = extractMetadata(content, data);
      content = result.first;
      addExternalMetadata(asset, data);

      final id = new AssetId(asset.id.package, "${asset.id.path.split(".").first}$METADATA_EXTENSION");
      transform.addOutput(new Asset.fromString(id, JSON.encode(data)));
      transform.addOutput(new Asset.fromString(asset.id, content));
    });
  }

  @override
  Future<bool> isPrimary(AssetId id) {
    // Only xxx.tmpl.yyy paths are primary assets for transformation.
    return new Future.value(_CONTENT_RE.hasMatch(id.path));
  }
}