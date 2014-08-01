library flare.includes_transformer;

import 'dart:io';
import 'dart:async';

import 'package:barback/barback.dart';
import 'package:path/path.dart' as posix;

import 'package:flare/flare.dart';

/// Includes partials into content files. Mustache-like syntax is used.
class PartialsTransformer extends Transformer {
  static final _INCLUDE_RE = new RegExp(r'{{>(\s*)(.*)}}(\s*)');

  final BarbackSettings _settings;

  PartialsTransformer.asPlugin(this._settings) {
  }

  @override
  apply(Transform transform) {
    final asset = transform.primaryInput;

    final relativeRootPath = posix.dirname(asset.id.path);

    return asset.readAsString().then((content) {
      final newContent = content.replaceAllMapped(_INCLUDE_RE, (match) {
        var includePath = match.group(2);
        if (!includePath.startsWith('/')) {
          includePath = '$relativeRootPath/$includePath';
        } else {
          includePath = 'web$includePath';
        }

        final file = new File(includePath);

        // TODO: maybe async methods can be used here?

        if (file.existsSync()) {
          return new File(includePath).readAsStringSync();
        } else {
          transform.logger.error("Fragment '$includePath' not found!");
          return "";
        }
      });

      transform.addOutput(new Asset.fromString(asset.id, newContent));
    });
  }

  @override
  Future<bool> isPrimary(AssetId id) {
    // Only xxx.tmpl.yyy paths are primary assets for transformation.
    // TODO: also check that .inc. is not included in the path?
    return new Future.value(TMPL_RE.hasMatch(id.path));
  }
}