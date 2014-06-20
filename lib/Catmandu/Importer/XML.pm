package Catmandu::Importer::XML;
#ABSTRACT: Import serialized XML documents
#VERSION

use namespace::clean;
use Catmandu::Sane;
use Moo;
use XML::Struct::Reader;

with 'Catmandu::Importer';

has type        => (is => 'ro', default => sub { 'simple' });
has path        => (is => 'ro');
has root        => (is => 'lazy');
has depth       => (is => 'ro');
has ns          => (is => 'ro', default => sub { '' });
has attributes  => (is => 'ro', default => sub { 1 });
has whitespace  => (is => 'ro', default => sub { 0 });

sub _build_root {
    defined $_[0]->path ? 1 : 0;
}

sub generator {
    my ($self) = @_;

    sub {
        state $reader = do { 
            my %options = (
                from       => ($self->file || $self->fh),
                whitespace => $self->whitespace,
                attributes => $self->attributes,
                depth      => $self->depth,
                ns         => $self->ns,
            );
            $options{path} = $self->path if defined $self->path;
            if ($self->type eq 'simple') {
                $options{simple} = 1;
                $options{root}   = $self->root;
            } elsif ($self->type ne 'ordered') {
                return;
            }
            XML::Struct::Reader->new(%options);
        };

        return $reader->readNext;
    }
}

=head1 DESCRIPTION

This importer reads XML and transforms it into a data structure. 

=head1 CONFIGURATION

=over 4

=item type

By default (type "C<simple>"), elements and attributes and converted to keys in
a key-value structure. For instance this document: 

    <doc attr="value">
      <field1>foo</field1>
      <field1>bar</field1>
      <bar>
        <doz>baz</doz>
      </bar>
    </doc>
     
is imported as

    {
        attr => 'value',
        field1 => [ 'foo', 'bar' ],
        field2 => { 'doz' => 'baz' },
    }

With type "C<ordered>" elements are preserved in the order of their appereance.
For instance the sample document above is imported as:

    [ 
        doc => { attr => "value" }, [
            [ field1 => { }, ["foo"] ],
            [ field1 => { },  ["bar"] ],
            [ field2 => { }, [ [ doz => { }, ["baz"] ] ] ]
        ]
    ] 

=item depth

Maximum depth for type "C<simple>". For instance with depth 1, the sample document above
would be imported as:

    {
        attr => 'value',
        field1 => [ 'foo', 'bar' ],
        field2 => { 
            doz => [ [ doz => { }, ["baz"] ] ]
        }
    }

=item attributes

Include XML attributes. Enabled by default.

=item path

Path expression to select XML elements. If not set the root element is
selected.

=item root

Include root element name, if enabled. Disabled by default, unless the C<path>
option is set.

=item ns

Set to 'C<strip>' for stripping namespace prefixes and xmlns-attributes.

=item whitespace

Include ignoreable whitespace. Disabled by default.

=back

=encoding utf8

=head1 SEE ALSO

This module is just a thin layer on top of L<XML::Struct::Reader>. Have a look
at L<XML::Struct> to implement Importers and Exporters for more specific
XML-based data formats.

=cut

1;
