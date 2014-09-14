library flare.partials_transformer;

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
      final List<Future> futures = [];
      final Map<String, String> partials = {};

      _INCLUDE_RE.allMatches(content).forEach((match) {
        var includePath = match.group(2);

        if (!includePath.startsWith('/')) {
          includePath = '$relativeRootPath/$includePath';
        } else {
          includePath = 'web$includePath';
        }

        futures.add(transform.getInput(new AssetId(asset.id.package, includePath)).then((partial) {
          return partial.readAsString().then((content) {
            partials[match.group(2)] = content;
          });
        }).catchError((_) {
          transform.logger.error("Fragment '$includePath' not found!");
        }));
      });

      return Future.wait(futures).then((_) {
        final newContent = content.replaceAllMapped(_INCLUDE_RE, (match) {
          return partials[match.group(2)];
        });

        transform.addOutput(new Asset.fromString(asset.id, newContent));
      });
    });
  }

  @override
  Future<bool> isPrimary(AssetId id) {
    // Only xxx.tmpl.yyy paths are primary assets for transformation.
    // TODO: also check that .inc. is not included in the path?
    return new Future.value(TMPL_RE.hasMatch(id.path));
  }
}