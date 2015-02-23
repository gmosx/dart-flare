library flare.html5_optimizer;

import 'dart:async';

import 'package:barback/barback.dart';
import 'package:html5lib/dom.dart' as dom;
import 'package:html5lib/parser.dart' as html_parser;

/// Type of visitor callbacks. If the callback returns true, the visitor descends into the
/// current node's children.
typedef bool _VisitorCallback(dom.Node node, List<dom.Node> nodes);

final RegExp _squeezeRE0 = new RegExp(r'\s+', multiLine: true);
final RegExp _squeezeRE1 = new RegExp(r'^\s+$', multiLine: true);

bool _isPreElement(dom.Node node) {
  // TODO: hackish way to check for <pre> element, any better solution?
  return node is dom.Element && node.outerHtml.startsWith('<pre>');
}

bool squeezeWhitespace(dom.Node node, List<dom.Node> siblings) {
  if (node is dom.Text) {
    // Squeeze the whitespace.
    node.text = node.text.replaceAll(_squeezeRE0, " ");

    if (_squeezeRE1.hasMatch(node.text)) {
      // Remove whitespace-only text nodes.
      siblings.remove(node);
    }

    final idx = siblings.indexOf(node);

    if (idx == 0) {
      // Trim the leading whitespace if the text node is the first child.
      node.text = node.text.trimLeft();
    }

    if (idx == (siblings.length - 1)) {
      // Trim the trailing whitespace if the text node is the last child.
      node.text = node.text.trimRight();
    }

    return false;
  } if (_isPreElement(node)) {
    return false;
  }

  return true;
}

bool removeComments(dom.Node node, List<dom.Node> siblings) {
  if (node is dom.Comment) {
    siblings.remove(node);
    return false;
  } if (_isPreElement(node)) {
    return false;
  }

  return true;
}

// TODO: implement as generator/sequence.
void visitNodes(List<dom.Node> siblings, _VisitorCallback fn) {
  var list = new List.from(siblings);
  list.forEach((node) {
    if (fn(node, siblings)) {
      visitNodes(node.nodes, fn);
    }
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
  apply(Transform transform) async {
    final content = await transform.primaryInput.readAsString();

    var id = transform.primaryInput.id;

    final doc = html_parser.parse(content);

    visitNodes(doc.nodes, removeComments);
    visitNodes(doc.nodes, squeezeWhitespace);

    String newContent = doc.outerHtml;

    transform.addOutput(new Asset.fromString(id, newContent));
  }

  @override
  Future<bool> isPrimary(AssetId id) async {
    return id.extension == '.html';
  }
}