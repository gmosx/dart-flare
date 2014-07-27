library flare.includes_transformer;

import 'dart:io';
import 'dart:async';

import 'package:barback/barback.dart';
import 'package:path/path.dart' as posix;

import 'package:flare/flare.dart';

/// Resolves fragment/partial inclusion defined by SSI tags.
class IncludesTransformer extends Transformer {
  static final _INCLUDE_RE = new RegExp(r'<!--#include file="(\s*)(.*)" -->');

  final BarbackSettings _settings;

  IncludesTransformer.asPlugin(this._settings) {
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
        return new File(includePath).readAsStringSync();
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