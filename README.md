# Flare

Flare is a collection of Barback transformers for static generation of web sites,  
similar to Jekyll, etc.

## Usage

A preliminary example is [available here](https://github.com/gmosx/dart-flare_example).

## Command-line interface

Before using the the CLI you have to activate it using the following command:

    $ pub global activate flare

Then you have access to a number of helper options:

    $ flare generate-post-id
    $ flare new-post "This is my new post"
    $ flare new-post --date=2014/08/02 "This is another post"

## Transformers

Flare provides the following default set of transformers:

### MetadataExtractor

Extracts front-end metadata from content files and transforms the data to the
internal JSON format.

### MetadataTranslator

Transforms external metadata to the internal JSON format.

### MetadataAggregator

Aggregates all metadata files into a single metadata structure accessible through
the [site] global variable.

### MarkdownTransform

Renders Markdown markup into HTML.

### PostsIndexer

Computes indexing metadata for the posts.

### PostsTransformer

Renders a collection of posts.

### MustacheTransformer

Renders Mustache templates into HTML files.

### CleanupTransformer

Removes temporary files generated by the content generation process.

### HtmlOptimizer

Optimizes the generated HTML files by removing comments and squeezing whitespace.

## Status

The API is *not stable* yet! 
  
## Links

* [Author's blog using Flare](http://www.gmosx.com)
* [Pub Assets and Transformers](https://www.dartlang.org/tools/pub/assets-and-transformers.html)
* [Writing Transformers](https://www.dartlang.org/tools/pub/transformers/examples/)
