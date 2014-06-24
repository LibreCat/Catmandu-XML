package Catmandu::Fix::xml_simple;
#ABSTRACT: parse XML
#VERSION

use Catmandu::Sane;
use Moo;
use XML::Struct::Reader;
use XML::LibXML::Reader;

with 'Catmandu::Fix::Base';

# TODO: avoid code duplication with xml_read

has field      => (is => 'ro', required => 1);
has attributes => (is => 'ro'); 
has ns         => (is => 'ro');
has content    => (is => 'ro');
has root       => (is => 'ro');
has depth      => (is => 'ro');
has path       => (is => 'ro');
has whitespace => (is => 'ro');

sub simple { 1 }

around BUILDARGS => sub {
    my ($orig,$class,$field,%opts) = @_;
    $orig->($class, 
        field => $field,
        map { $_ => $opts{$_} } 
        qw(attributes ns root depth content path whitespace)
    );
};

has _reader => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        XML::Struct::Reader->new(
            map { $_ => $_[0]->$_ } grep { defined $_[0]->$_ }
            qw(attributes ns simple root depth content whitespace)
        );
    }
);

sub emit {    
    my ($self,$fixer) = @_;    

    my $path = $fixer->split_path($self->field);
    my $key = pop @$path;
    
    my $reader = $fixer->capture($self->_reader); 
    my $xpath  = $fixer->capture($self->path);

    return $fixer->emit_walk_path($fixer->var,$path,sub{
        my $var = $_[0];     
        $fixer->emit_get_key($var,$key,sub{
            my $var = $_[0];
            return "print STDERR ${var}; if (ref ${var} and ref ${var} =~ /^ARRAY/) {" .
                "${var} = XML::Struct::simpleXML( ${var} );" . # TODO: support options 
                "} else {" .
                # TODO: code duplication with xml_read
                "my \$stream = XML::LibXML::Reader->new( string => ${var} );".
                "${var} = ${xpath} ? [ ${reader}->readDocument(\$stream, ${xpath}) ] " .
                ": ${reader}->readDocument(\$stream);";
                "}";
        });
    });
}

=head1 SYNOPSIS
     
  xml_simple(xml)

=head1 DESCRIPTION

This L<Catmandu::Fix> transforms MicroXML or parses XML strings simple XML with
L<XML::Struct>.

=head1 OPTIONS

See L<Catmandu::Fix::xml_read> for parsing options.

=cut

1;
