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

* MarkdownTransformer
* MetadataExtractor
* MetadataAggregator
* PostsIndexer
* PostsTransformer
* MustacheTransformer
* CleanupTransformer
* HtmlOptimizer

## Status

Flare is currently just an experiment. The goal is to validate the hypothesis
that Barback is versatile enough to support an extensible static site generation
system. I am publishing this as a package in the hope to receive feedback 
from the community. Pull requests will not hurt either ;-)

The API is *not stable* yet!
  
## Links

* [Author's blog using Flare](http://www.gmosx.com)
* [Pub Assets and Transformers](https://www.dartlang.org/tools/pub/assets-and-transformers.html)
* [Writing Transformers](https://www.dartlang.org/tools/pub/transformers/examples/)
