package Catmandu::Fix::xml_write;
#ABSTRACT: parse XML
#VERSION

use Catmandu::Sane;
use Moo;
use XML::Struct::Writer;
use XML::LibXML::Reader;

with 'Catmandu::Fix::Base';

has field      => (is => 'ro', required => 1);
has attributes => (is => 'ro'); 
has pretty     => (is => 'ro');
# has encoding   => (is => 'ro');
# has version    => (is => 'ro');
# has standalone => (is => 'ro');
# has xmlDecl    => (is => 'ro');

around BUILDARGS => sub {
    my ($orig,$class,$field,%opts) = @_;
    $orig->($class, 
        field      => $field,
        attributes => $opts{attributes},
#        encoding   => $opts{encoding},
        pretty     => $opts{pretty},
    );
};

has _writer => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        XML::Struct::Writer->new(
            map { $_ => $_[0]->$_ } grep { defined $_[0]->$_ }
            qw(attributes pretty)
        );
    }
);

sub emit {    
    my ($self,$fixer) = @_;    

    my $path = $fixer->split_path($self->field);
    my $key = pop @$path;
    
    my $writer = $fixer->capture($self->_writer); 
    my $pretty = $fixer->capture($self->pretty); 

    return $fixer->emit_walk_path($fixer->var,$path,sub{
        my $var = $_[0];     
        $fixer->emit_get_key($var,$key,sub{
            my $var = $_[0];
            return "${var} = ${writer}->write($var) if ref(${var}) !~ 'XML::LibXML::Document=';" .
                   "${var} = ${var}->serialize(${pretty});";
        });
    });
}

=head1 SYNOPSIS
     
  # serialize XML structure given in field 'xml' 
  xml_write(xml)
  xml_write(xml, pretty: 1)

=head1 DESCRIPTION

This L<Catmandu::Fix> serializes XML documents (given in MicroXML form
as used by L<XML::Struct> or as instance of L<XML::LibXML::Document>).
In short, this is a wrapper around L<XML::Struct::Reader>.

=head1 OPTIONS

=over

=item attributes

Set to false to not expect attribute hashes in the XML structure.

=item pretty

Pretty-print XML if set to C<1>.

=back

=head1 SEE ALSO

L<Catmandu::Fix::xml_read>

=cut

1;
