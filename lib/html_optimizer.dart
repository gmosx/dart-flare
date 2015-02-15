library flare.html5_optimizer;

import 'dart:async';

import 'package:barback/barback.dart';
import 'package:html5lib/dom.dart' as dom;
import 'package:html5lib/parser.dart' as html_parser;

typedef void _VisitorCallback(dom.Node node, List<dom.Node> nodes);

final RegExp _squeezeRE0 = new RegExp(r'\s+', multiLine: true);
final RegExp _squeezeRE1 = new RegExp(r'^\s+$', multiLine: true);

void squeezeWhitespace(dom.Node node, List<dom.Node> nodes) {
  if (node is dom.Text) {
    // Squeeze the whitespace.
    node.text = node.text.replaceAll(_squeezeRE0, " ");

    if (_squeezeRE1.hasMatch(node.text)) {
      // Remove whitespace-only text nodes.
      nodes.remove(node);
    }

    final idx = nodes.indexOf(node);

    if (idx == 0) {
      // Trim the leading whitespace if the text node is the first child.
      node.text = node.text.trimLeft(); //= node.text.replaceAll(_squeezeRE2, "");
    }

    if (idx == (nodes.length - 1)) {
      // Trim the trailing whitespace if the text node is the last child.
      node.text = node.text.trimRight();
    }
  }
}

void removeComments(dom.Node node, List<dom.Node> nodes) {
  if (node is dom.Comment) {
    nodes.remove(node);
  }
}

// TODO: implement as generator/sequence.
void visitNodes(List<dom.Node> nodes, _VisitorCallback fn) {
  var list = new List.from(nodes);
  list.forEach((node) {
    fn(node, nodes);
    visitNodes(node.nodes, fn);
  });
}

/// Optimizes .html files by:
///
/// * removing html comments
/// * squeezing whitespace
class HtmlOptimizer extends Transformer {
  final BarbackSettings _settings;

  HtmlOptimizer.asPlugin(this._settings);

  @override
  apply(Transform transform) {
    return transform.primaryInput.readAsString().then((content) {
      var id = transform.primaryInput.id;

      final doc = html_parser.parse(content);

      visitNodes(doc.nodes, removeComments);
      visitNodes(doc.nodes, squeezeWhitespace);

      String newContent = doc.outerHtml;

      transform.addOutput(new Asset.fromString(id, newContent));
    });
  }

  @override
  Future<bool> isPrimary(AssetId id) {
    return new Future.value(id.extension == '.html');
  }
}