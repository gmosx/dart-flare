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
  apply(Transform transform) {
    final asset = transform.primaryInput;

    return asset.readAsString().then((content) {
      return _loadMetadata(transform, asset).then((metadata) {
        return transform.getInput(new AssetId(asset.id.package, 'web/__site.$metadataExtension')).then((meta) {
          return meta.readAsString().then((json) {
            metadata['site'] = JSON.decode(json);
          });
        }).catchError((e) {
          // No global site meta data found, consume the exception and continue.
        }).whenComplete(() {
          final template = new Template(content, lenient: true, htmlEscapeValues: false);
          final newId = new AssetId(asset.id.package, asset.id.path.replaceAll('.tmpl', ''));
          final newContent = template.renderString(metadata);
          transform.addOutput(new Asset.fromString(newId, newContent));
          transform.consumePrimary();
        });
      });
    });
  }

  @override
  Future<bool> isPrimary(AssetId id) {
    // Only xxx.tmpl.yyy paths are primary assets for transformation.
    return new Future.value(tmplRE.hasMatch(id.path) &&
        (!privateRE.hasMatch(id.path)));
  }

  // TODO: better merge additional metadata.
  Future<Map> _loadMetadata(Transform transform, Asset asset) {
    return transform.getInput(new AssetId(asset.id.package, '${asset.id.path.split(".").first}.$metadataExtension')).then((meta) {
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