part of flare;

// TODO: come up with an improved API.

Map DEFAULT_METADATA = {
  'date': new DateTime.now().toString()
};

const String OPEN_DELIMITER = "<!--";
const String CLOSE_DELIMITER = "-->\n";

/// Tries to extract 'front matter' metadata.
List extractMetadata(String content, [Map data]) {
  if (data == null) {
    data = new Map();
  }

  // TODO: do it with a single regular expression.

  if (content.startsWith(OPEN_DELIMITER)) {
    final parts = content.split(CLOSE_DELIMITER);
    final yaml = parts.removeAt(0).replaceFirst(OPEN_DELIMITER, "");
    data.addAll(loadYaml(yaml));
    return [parts.join(CLOSE_DELIMITER), data];
  } else {
    return [content, data];
  }
}

Map addExternalMetadata(Asset asset, [Map data]) {
  if (data == null) {
    data = new Map();
  }

  final metaPath = '${asset.id.path.split(".").first}.yaml';
  final metaFile = new File(metaPath);

  if (metaFile.existsSync()) {
    data.addAll(loadYaml(metaFile.readAsStringSync()));
  }

  return data;
}
