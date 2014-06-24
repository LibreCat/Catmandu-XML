package Catmandu::XML;
#ABSTRACT: Modules for handling XML data within the Catmandu framework
#VERSION

=head1 DESCRIPTION

L<Catmandu::XML> contains modules for handling XML data within the L<Catmandu>
framework. Parsing and serializing is based on L<XML::LibXML> with
L<XML::Struct>.

=head1 MODULES

=over 4

=item L<Catmandu::Importer::XML>

Import serialized XML documents as data structures.

=item L<Catmandu::Exporter::XML>

Serialize data structures as XML documents.

=item L<Catmandu::Fix::xml_read>

Fix function to parse XML to MicroXML as implemented by L<XML::Struct>

=item L<Catmandu::Fix::xml_write>

Fix function to seralize XML.

=item L<Catmandu::Fix::xml_simple>

Fix function to parse XML or convert MicroXML to simple form as known from
L<XML::Simple>.

=item L<Catmandu::Fix::xml_transform>

Fix function to transform XML using XSLT stylesheets.

=back

=head1 SEE ALSO

This module requires the non-perl libraries libxml2 and libxslt installed. To
install for instance on Ubuntu Linux call C<sudo apt-get install libxslt-dev
libxml2-dev>.

=encoding utf8

=cut

1;
