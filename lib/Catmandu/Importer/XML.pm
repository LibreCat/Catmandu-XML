package Catmandu::Importer::XML;
# ABSTRACT: Import XML data
# VERSION

use namespace::clean;
use Catmandu::Sane;
use Moo;
use XML::LibXML::Simple qw(XMLin);

with 'Catmandu::Importer';

has type => (is => 'ro', default => sub { 'simple' });
has reader => (is => 'ro', lazy => 1, builder => '_build_reader');

sub _build_reader {
    my $self = shift;

    my $ishandle = eval { fileno($self->file); }; # TODO: cleanup
    XML::LibXML::Reader->new( ($ishandle ? 'IO' : 'location') => $self->file );
}

sub generator {
    my ($self) = @_;
    my $read =0;
    sub {
        state $type = $self->type;
        state $fh   = $self->fh;

        return if $read++;;
        if ($type eq 'simple') {
            return XMLin($self->file); # TODO: $fh
        } elsif ($type eq 'ordered') {
            # TODO
        } else {
            return;
        }
    }
}

1;
