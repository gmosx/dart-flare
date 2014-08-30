library flare.includes_transformer;

import 'dart:async';

import 'package:barback/barback.dart';

/// Removes temporary files generated by upstream transformers.
class CleanupTransformer extends Transformer {
  static final PRIVATE_RE = new RegExp(r'/_');
  static final META_RE = new RegExp(r'(.yaml$)|(.meta.json$)');

  final BarbackSettings _settings;

  CleanupTransformer.asPlugin(this._settings) {
  }

  @override
  apply(Transform transform) {
    transform.consumePrimary();
  }

  @override
  Future<bool> isPrimary(AssetId id) {
    return new Future.value(
        PRIVATE_RE.hasMatch(id.path) ||
        META_RE.hasMatch(id.path));
  }
}