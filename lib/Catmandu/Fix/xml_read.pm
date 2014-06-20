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

has attributes => (is => 'ro', default => sub { 1 }); 
has ns         => (is => 'ro', default => sub { 'keep' });
has content    => (is => 'ro', default => sub { 'content' });
has simple     => (is => 'ro', default => sub { 0 });
has root       => (is => 'ro', default => sub { 0 });
has depth      => (is => 'ro');
has path       => (is => 'ro', default => sub { '*' });

has _reader => (
    is => 'ro',
    lazy => 1,
    builder => sub {
        XML::Struct::Reader->new( 
            map { $_ => $_[0]->$_ } qw(attributes ns simple root depth content path) );
    }
);

around BUILDARGS => sub {
    my ($orig,$class,$field,%opts) = @_;
    $orig->($class, 
        field => $field,
        map { $_ => $opts{$_} } qw(attributes ns simple root depth content)
    );
};

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
            # FIXME
            return "my \$stream = XML::LibXML::Reader->new( string => ${var} );".
                "${var} = ${reader}->readDocument(\$stream);";
            #return "${var} = ${xpath} ne '*' ? [ ${reader}->readDocument(${var}, ${xpath}) ] : ${reader}->readDocument(${var});";
        });
    });

    $perl;
}

=head1 SYNOPSIS
     
  # parse XML string given in field 'xml' 
  xml_read(xml)

=head1 DESCRIPTION

This L<Catmandu::Fix> parses XML strings into MicroXML or simple XML with
L<XML::Struct>.

=head1 OPTIONS

Parsing can be configured with the following options of L<XML::Struct::Reader>:

=over

=item attributes

=item ns

=item simple

=item root

=item depth

=item content

=back

=head1 SEE ALSO

L<Catmandu::Fix::xml_write>

=cut

1;
