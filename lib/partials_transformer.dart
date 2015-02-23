library flare.partials_transformer;

import 'dart:async';

import 'package:barback/barback.dart';
import 'package:path/path.dart' as posix;

import 'package:flare/flare.dart';

/// Includes partials into content files. Mustache-like syntax is used.
class PartialsTransformer extends Transformer {
  static final _includeRE = new RegExp(r'{{>(\s*)(.*)}}(\s*)');

  final BarbackSettings _settings;

  PartialsTransformer.asPlugin(this._settings);

  @override
  apply(Transform transform) async {
    final asset = transform.primaryInput;

    final relativeRootPath = posix.dirname(asset.id.path);

    final content = await asset.readAsString();
    final List<Future> futures = [];
    final Map<String, String> partials = {};

    _includeRE.allMatches(content).forEach((match) {
      final path = match.group(2);

      futures.add(transform.getInput(new AssetId(asset.id.package, _normalizePath(path, relativeRootPath))).then((partial) async {
        // TODO: cache partials between invocations.
        final content = await partial.readAsString();
        partials[path] = content;
      }).catchError((_) {
        transform.logger.error("Fragment '$path' (${_normalizePath(path, relativeRootPath)}) not found!");
      }));
    });

    await Future.wait(futures);
    final newContent = content.replaceAllMapped(_includeRE, (match) {
      final path = match.group(2);
      return partials[path];
    });

    transform.addOutput(new Asset.fromString(asset.id, newContent));
  }

  @override
  Future<bool> isPrimary(AssetId id) async {
    // Only xxx.tmpl.yyy paths are primary assets for transformation.
    // TODO: also check that .inc. is not included in the path?
    return tmplRE.hasMatch(id.path);
  }

  String _normalizePath(String path, String relativeRootPath) {
    if (!path.startsWith('/')) {
      return '$relativeRootPath/$path';
    } else {
      return 'web$path';
    }
  }
}