# NAME

Catmandu::XML - modules for handling XML data within the Catmandu framework

# Status

[![Build Status](https://travis-ci.org/LibreCat/Catmandu-XML.png)](https://travis-ci.org/LibreCat/Catmandu-XML)
[![Coverage Status](https://coveralls.io/repos/LibreCat/Catmandu-XML/badge.png)](https://coveralls.io/r/LibreCat/Catmandu-XML)
[![Kwalitee Score](http://cpants.cpanauthors.org/dist/Catmandu-XML.png)](http://cpants.cpanauthors.org/dist/Catmandu-XML)

# DESCRIPTION

[Catmandu::XML](https://metacpan.org/pod/Catmandu::XML) contains modules for handling XML data within the [Catmandu](https://metacpan.org/pod/Catmandu)
framework. Parsing and serializing is based on [XML::LibXML](https://metacpan.org/pod/XML::LibXML) with
[XML::Struct](https://metacpan.org/pod/XML::Struct). XSLT transformation is based on [XML::LibXSLT](https://metacpan.org/pod/XML::LibXSLT).

# MODULES

- [Catmandu::Importer::XML](https://metacpan.org/pod/Catmandu::Importer::XML)

    Import serialized XML documents as data structures.

- [Catmandu::Exporter::XML](https://metacpan.org/pod/Catmandu::Exporter::XML)

    Serialize data structures as XML documents.

- [Catmandu::XML::Transformer](https://metacpan.org/pod/Catmandu::XML::Transformer)

    Utility module for XML/XSLT processing.

- [Catmandu::Fix::xml\_read](https://metacpan.org/pod/Catmandu::Fix::xml_read)

    Fix function to parse XML to MicroXML as implemented by [XML::Struct](https://metacpan.org/pod/XML::Struct).

- [Catmandu::Fix::xml\_write](https://metacpan.org/pod/Catmandu::Fix::xml_write)

    Fix function to seralize XML.

- [Catmandu::Fix::xml\_simple](https://metacpan.org/pod/Catmandu::Fix::xml_simple)

    Fix function to parse XML or convert MicroXML to simple form as known from
    [XML::Simple](https://metacpan.org/pod/XML::Simple).

- [Catmandu::Fix::xml\_transform](https://metacpan.org/pod/Catmandu::Fix::xml_transform)

    Fix function to transform XML using XSLT stylesheets.

# SEE ALSO

This module requires the libraries `libxml2` and `libxslt`. For instance on
Ubuntu Linux call `sudo apt-get install libxslt-dev libxml2-dev` before
installation of Catmandu::XML.

# COPYRIGHT AND LICENSE

Copyright Jakob Voss, 2014-

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself.
