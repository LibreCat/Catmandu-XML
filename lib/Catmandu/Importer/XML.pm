package Catmandu::Importer::XML;
# ABSTRACT: Import XML data
# VERSION

use namespace::clean;
use Catmandu::Sane;
use Moo;
# use XML::LibXML::Simple qw(XMLin);
use XML::Struct;

with 'Catmandu::Importer';

has type => (is => 'ro', default => sub { 'simple' });
has path => (is => 'ro', default => sub { '/*' }); # TODO: support
has attributes => (is => 'ro', default => sub { 1 });
has whitespace => (is => 'ro', default => sub { 0 });

sub generator {
    my ($self) = @_;
    my $read = 0;
    sub {
        state $type = $self->type;
        state $fh   = $self->fh;

        return if $read++;
        if ($type eq 'simple') {
            return XML::Struct::readXML(
                $self->file || $fh, path => $self->path,
                hashify => 1,
                whitespace => $self->whitespace,
                attributes => $self->attributes,
            );
            # return XMLin($self->file || $fh); # equivalent apart from XML::Simple hacks
        } elsif ($type eq 'ordered') {
            return XML::Struct::readXML(
                $self->file || $fh, path => $self->path,
                whitespace => $self->whitespace,
                attributes => $self->attributes,
            );
        } else {
            return;
        }
    }
}

=head1 DESCRIPTION

This importer reads XML and transforms it into a data structure. Two types of
structure can be choosen among:

=over 4

=item simple (default)

Elements and attributes and converted to keys in a key-value structure. For instance

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

=item ordered

Elements are preserved in the order of their appereance. For instance the
sample document above is imported as:

        [ 
            doc => { attr => "value" }, [
                [ field1 => { }, ["foo"] ],
                [ field1 => { },  ["bar"] ],
                [ field2 => { }, [ [ doz => { }, ["baz"] ] ] ]
            ]
        ] 

Attributes can be omitted with option C<attributes>.

=back

=encoding utf8

=cut

1;
