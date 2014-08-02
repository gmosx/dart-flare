#!/usr/bin/env dart

import 'package:args/args.dart';

/// The 'epoch' for the id sequence is 1 Jan 2000.
final int ID_EPOCH_MS = new DateTime(2000).millisecondsSinceEpoch;

void main(List<String> args) {
  final parser = new ArgParser(allowTrailingOptions: true);
  parser.addCommand('generate-post-id');

  final cli = parser.parse(args);

  if (cli.command != null) {
    switch (cli.command.name) {
      case 'generate-post-id':
        print(generateNewPostId());
        break;
    }
  } else {
    print(parser.getUsage());
  }
}

/// Generates an persistent id for a post. This id uniquely identifies the post
/// and is independent of post metadata (e.g. title).
String generateNewPostId() {
  return ((new DateTime.now().millisecondsSinceEpoch - ID_EPOCH_MS)/ 1000).toStringAsFixed(0);
}