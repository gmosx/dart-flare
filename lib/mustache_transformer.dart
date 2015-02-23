library flare.mustache_transformer;

import 'dart:async';
import 'dart:convert' show JSON;

import 'package:barback/barback.dart';
import 'package:mustache/mustache.dart';

import 'package:flare/flare.dart';

// TODO: add a setting to point to yaml file with default data.
// TODO: don't use .tmpl. to allow this to work  through the IDE / simplify names.

// TODO: add support for user-defined defaults through [BarbackSettings].
Map DEFAULT_METADATA = {
  'time': new DateTime.now().toString()
};

/// Renders [Mustache](http://mustache.github.io/) template files.
class MustacheTransformer extends Transformer {
  final BarbackSettings _settings;

  MustacheTransformer.asPlugin(this._settings) {
  }

  @override
  apply(Transform transform) async {
    final asset = transform.primaryInput;
    final content = await asset.readAsString();
    final metadata = await _loadMetadata(transform, asset);
    try {
      final meta = await transform.getInput(new AssetId(asset.id.package, 'web/__site.$metadataExtension'));
      final json = await meta.readAsString();
      metadata['site'] = JSON.decode(json);
    } catch (e) {
      // No global site meta data found, consume the exception and continue.
    }
    final template = new Template(content, lenient: true, htmlEscapeValues: false);
    final newId = new AssetId(asset.id.package, asset.id.path.replaceAll('.tmpl', ''));
    final newContent = template.renderString(metadata);
    transform.addOutput(new Asset.fromString(newId, newContent));
    transform.consumePrimary();
  }

  @override
  Future<bool> isPrimary(AssetId id) async {
    // Only xxx.tmpl.yyy paths are primary assets for transformation.
    return
        tmplRE.hasMatch(id.path) &&
        (!privateRE.hasMatch(id.path));
  }

  // TODO: better merge additional metadata.
  Future<Map> _loadMetadata(Transform transform, Asset asset) async {
    try {
      final meta = await transform.getInput(new AssetId(asset.id.package, '${asset.id.path.split(".").first}.$metadataExtension'));
      final json = await meta.readAsString();
      final metadata = JSON.decode(json);
      metadata.addAll(DEFAULT_METADATA);
      return metadata;
    } catch (e) {
      return DEFAULT_METADATA;
    }
  }
}