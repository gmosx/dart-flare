#!/usr/bin/env dart

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:args/command_runner.dart';
import 'package:uuid/uuid_server.dart';

final DateFormat dateFormat = new DateFormat('yyyy/MM/dd');

/// Displays the version of Flare.
class VersionCommand extends Command {
  @override
  String get name => 'version';

  @override
  String get description => "Displays the version of Flare";

  @override
  void run() {
    print("Flare version 0.6.0");
  }
}

/// Generates a persistent id for a post.
class GeneratePostIdCommand extends Command {
  @override
  String get name => 'generate-post-id';

  @override
  String get description => "Generates a unique id for a new post";

  @override
  void run() {
    print(generateNewPostId());
  }
}

/// Creates a new (scaffold) post.
class NewPostCommand extends Command {
  @override
  String get name => 'new-post';

  @override
  String get description => "Create a scaffold for a new post";

  NewPostCommand() {
    argParser.addOption('date', abbr: 'd', help: "The creation date of the post");
  }

  @override
  void run() {
    var date;
    if (argResults['date'] != null) {
      date = argResults['date'];
    } else {
      date = dateFormat.format(new DateTime.now());
    }
    createNewPost(argResults.rest.first, date: date);
  }
}

/// # Examples
///
/// $ flare generate-post-id
/// $ flare new-post "This is my new post"
/// $ flare new-post --date=2014/08/02 "This is another post"
void main(List<String> args) {
  final runner = new CommandRunner('flare', "CLI for flare")
      ..addCommand(new VersionCommand())
      ..addCommand(new GeneratePostIdCommand())
      ..addCommand(new NewPostCommand());

  runner.run(args);
}

/// Generates a persistent id for a post. This id uniquely identifies the post
/// and is independent of post metadata (e.g. title). Moreover, the id does not
/// imply ordering of posts. Currenlyt we use a v4 UUID.
String generateNewPostId() {
  return new Uuid().v4();
}

/// Creates subdirectories and the file for a new post.
void createNewPost(String title, {String date}) {
  final dirname = 'web/posts/${date}';
  final filename = '${_slugify(title)}.md';

  new Directory(dirname).createSync(recursive: true);

  final file = new File('$dirname/$filename');

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

String _slugify(String title) { // TODO: use inflection package for this!
  return title.replaceAll(new RegExp(' '), '-').
      replaceAll(new RegExp(r"['?!.,]"), '').toLowerCase();
}