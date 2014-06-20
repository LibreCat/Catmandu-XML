package Catmandu::Exporter::XML;
#ABSTRACT: serialize and export XML documents
#VERSION

use Catmandu::Sane;
use Moo;

use XML::Struct::Writer;
use XML::SAX::Writer;

with 'Catmandu::Exporter';

has attributes  => (is => 'ro', default => sub { 1 });
has declaration => (is => 'ro', default => sub { 1 });
has pretty      => (is => 'ro', default => sub { 0 });

#has directory => (
#    is  => 'ro', 
#    isa => sub { die "output directory not found" unless -d $_[0] },
#);
#has _file  => (is => 'ro'); # name

sub add {
    my ($self, $data) = @_;

    # TODO: use SAX handler to be implemented in XML::Struct (based on XML::SAX::Writer)
    my $writer = XML::Struct::Writer->new( attributes => $self->attributes ); # TODO: fixed hash
    my $dom = $writer->write($data); # not very efficient

    print {$self->fh || *STDOUT} $dom->serialize( $self->pretty );
}

sub commit {
    my ($self) = @_;
}

1;
