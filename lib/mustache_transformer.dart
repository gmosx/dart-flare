library flare.mustache_transformer;

import 'dart:io';
import 'dart:async';
import 'dart:convert' show JSON;

import 'package:barback/barback.dart';
import 'package:mustache/mustache.dart' as mustache;

import 'package:flare/flare.dart';

// TODO: add a setting to point to yaml file with default data.

// TODO: add support for user-defined defaults through [BarbackSettings].
Map DEFAULT_METADATA = {
  'time': new DateTime.now().toString()
};

/// A Barback [Transformer] that evaluates [Mustache](http://mustache.github.io/)
/// template files.
class MustacheTransformer extends Transformer {
  final BarbackSettings _settings;

  MustacheTransformer.asPlugin(this._settings) {
  }

  @override
  apply(Transform transform) {
    final asset = transform.primaryInput;

    return asset.readAsString().then((content) {
      return _loadMetadata(transform, asset).then((metadata) {
        return transform.getInput(new AssetId(asset.id.package, 'web/_site.$METADATA_EXTENSION')).then((meta) {
          return meta.readAsString().then((json) {
            metadata['metadata'] = JSON.decode(json);
            final template = mustache.parse(content);
            final newId = new AssetId(asset.id.package, asset.id.path.replaceAll('.tmpl', ''));
            final newContent = template.renderString(metadata, htmlEscapeValues: false);
            transform.addOutput(new Asset.fromString(newId, newContent));
            transform.consumePrimary();
          });
        });

//        metadata['metadata'] = new Map.from(_global);
//        final template = mustache.parse(content);
//        final newId = new AssetId(asset.id.package, asset.id.path.replaceAll('.tmpl', ''));
//        final newContent = template.renderString(metadata, htmlEscapeValues: false);
//        transform.addOutput(new Asset.fromString(newId, newContent));
//        transform.consumePrimary();
      });
    });
  }

  @override
  Future<bool> isPrimary(AssetId id) {
    // Only xxx.tmpl.yyy paths are primary assets for transformation.
    return new Future.value(TMPL_RE.hasMatch(id.path) &&
        (!INC_RE.hasMatch(id.path)) &&
        (!PRIVATE_RE.hasMatch(id.path)));
  }

  // TODO: better merge additional metadata.
  Future<Map> _loadMetadata(Transform transform, Asset asset) {
    return transform.getInput(new AssetId(asset.id.package, '${asset.id.path.split(".").first}.$METADATA_EXTENSION')).then((meta) {
      return meta.readAsString().then((json) {
        final metadata = JSON.decode(json);
        metadata.addAll(DEFAULT_METADATA);
        return metadata;
      });
    }).catchError((_) {
      return DEFAULT_METADATA;
    });
  }
}