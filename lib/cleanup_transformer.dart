library flare.includes_transformer;

import 'dart:async';

import 'package:barback/barback.dart';

class CleanupTransformer extends Transformer {
  static final PRIVATE_RE = new RegExp(r'/_');
  static final INC_RE = new RegExp(r'.inc.');
  static final META_RE = new RegExp(r'.yaml$');

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
//        id.path.startsWith('web/packages') ||
        PRIVATE_RE.hasMatch(id.path) ||
        INC_RE.hasMatch(id.path) ||
        META_RE.hasMatch(id.path));
  }
}