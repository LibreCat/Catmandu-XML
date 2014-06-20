package Catmandu::Fix::xml_read;
#ABSTRACT: parse XML
#VERSION

use Catmandu::Sane;
use Moo;
use XML::Struct::Reader;
use XML::LibXML::Reader;

with 'Catmandu::Fix::Base';

has field => (
    is => 'ro',
    required => 1
);

has attributes => (is => 'ro'); 
has ns         => (is => 'ro');
has content    => (is => 'ro');
has simple     => (is => 'ro');
has root       => (is => 'ro');
has depth      => (is => 'ro');
has path       => (is => 'ro');
has whitespace       => (is => 'ro');

around BUILDARGS => sub {
    my ($orig,$class,$field,%opts) = @_;
    $orig->($class, 
        field => $field,
        map { $_ => $opts{$_} } 
        qw(attributes ns simple root depth content path whitespace)
    );
};

has _reader => (
    is => 'ro',
    lazy => 1,
    builder => sub {
        XML::Struct::Reader->new(
            map { $_ => $_[0]->$_ } grep { defined $_[0]->$_ }
            qw(attributes ns simple root depth content whitespace)
        );
    }
);

sub emit {    
    my ($self,$fixer) = @_;    

    my $perl = "";
    my $path = $fixer->split_path($self->field);
    my $key = pop @$path;
    
    my $reader = $fixer->capture($self->_reader); 
    my $xpath  = $fixer->capture($self->path);

    $perl .= $fixer->emit_walk_path($fixer->var,$path,sub{
        my $var = $_[0];     
        $fixer->emit_get_key($var,$key,sub{
            my $var = $_[0];
            return "my \$stream = XML::LibXML::Reader->new( string => ${var} );".
                "${var} = ${xpath} ? [ ${reader}->readDocument(\$stream, ${xpath}) ] " .
                ": ${reader}->readDocument(\$stream);";
        });
    });
    
    $perl;
}

=head1 SYNOPSIS
     
  # parse XML string given in field 'xml' 
  xml_read(xml)
  xml_read(xml, attributes: 0)
  xml_read(xml, simple: 1)

=head1 DESCRIPTION

This L<Catmandu::Fix> parses XML strings into MicroXML or simple XML with
L<XML::Struct>.

=head1 OPTIONS

Parsing can be configured with the following options of L<XML::Struct::Reader>:

=over

=item attributes

Include XML attributes (enabled by default).

=item ns

Define processing of XML namespaces (C<keep> by default).

=item whitespace

Include ignorable whitespace as text elements (disabled by default).

=item simple

Convert to simple key-value structure as known from L<XML::Simple>.

=item root

Keep (and possibly rename) root element when converting in C<simple> form.

=item depth

Only transform to a given depth with option C<simple>.

=item path

Parse only given elements (and all of its child elements) and return as array.
For instance C<< path => "p" >> in an XHTML document would return a list of
parsed paragraphs (C<< <p>...</p> >>).

=item content

not supported yet.

=back

=head1 SEE ALSO

L<Catmandu::Fix::xml_write>

=cut

1;
