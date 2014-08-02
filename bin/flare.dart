#!/usr/bin/env dart

// TODO: Use the logger package.

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:args/args.dart';

/// The 'epoch' for the id sequence is 1 Jan 2000.
final int ID_EPOCH_MS = new DateTime(2000).millisecondsSinceEpoch;

final DateFormat DATE_FORMAT = new DateFormat('yyyy/MM/dd');

/// # Examples
///
/// $ flare generate-post-id
/// $ flare new-post "This is my new post"
/// $ flare new-post --date=2014/08/02 "This is another post"
void main(List<String> args) {
  final parser = new ArgParser();
  parser.addCommand('generate-post-id');
  final newPost = parser.addCommand('new-post');
  newPost.addOption('date', abbr: 'd', help: "The creation data of the post");

  final cli = parser.parse(args);

  if (cli.command != null) {
    switch (cli.command.name) {
      case 'generate-post-id':
        print(generateNewPostId());
        break;

      case 'new-post':
        var date;
        if (cli.command.wasParsed('date')) {
          date = cli.command['date'];
        } else {
          date = DATE_FORMAT.format(new DateTime.now());
        }
        createNewPost(cli.command.rest.first, date: date);
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

/// Creates subdirectories and the file for a new post.
void createNewPost(String title, {DateTime date}) {
  final dirname = 'web/posts/${date}';
  final filename = '${_slugify(title)}.md';

  new Directory(dirname).create(recursive: true);

  final file = new File('$dirname/$filename');

  // TODO: handle date formatting.

  if (file.existsSync()) {
    print("Can't create post, '$dirname/$filename' already exists!");
  } else {
    file.writeAsStringSync(
'''<!--
title: $title
date: $date
id: ${generateNewPostId()}
labels:
  - Label
-->
TODO: Add the text of your post here!'''
    );
    print("Created '$dirname/$filename'");
  }
}

String _slugify(String title) {
  return title.replaceAll(new RegExp(' '), '-').
      replaceAll(new RegExp(r"['?!.,]"), '').toLowerCase();
}