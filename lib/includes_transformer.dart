library flare.includes_transformer;

import 'dart:io';
import 'dart:async';

import 'package:barback/barback.dart';

/// Resolves fragment/partial inclusion defined by SSI tags.
class IncludesTransformer extends Transformer {
  static final TMPL_RE = new RegExp(r'.tmpl.');
  static final INCLUDE_RE = new RegExp(r'<!--#include file="(\s*)(.*)" -->');

  final BarbackSettings _settings;

  IncludesTransformer.asPlugin(this._settings) {
  }

  @override
  apply(Transform transform) {
    final asset = transform.primaryInput;

    return asset.readAsString().then((content) {
      final newContent = content.replaceAllMapped(INCLUDE_RE, (match) {
        final includePath = match.group(2);
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