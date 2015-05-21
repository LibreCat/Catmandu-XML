package Catmandu::XML::Parser;

use Catmandu::Sane;
use Catmandu::Util qw(require_package);
use Scalar::Util qw(blessed);
use Moo::Role;
use Carp;

our $VERSION = '0.01';

has xslt => (
    is => 'ro',
    coerce => sub {
        eval {
            require_package('Catmandu::XML::Transformer')->new( stylesheet => $_[0] )
        } or croak $@;
    }
);

has parser => (
    is => 'ro',
    coerce => sub {
        if (is_code_ref($_[0])) {
            $_[0];
        } else {
            eval {
                # TODO: pass additional options (?)
                Catmandu::Util::require_package($_[0])->new;
            } or croak $@;
        }
    }
);

sub parse {
    my ($self, $xml) = @_;

    if ( $self->xslt and defined $xml ) {
        $xml = $self->xslt->transform($xml)
    }

    if ( not defined $xml ) {
        return;
    } elsif ( not blessed($xml) ) {
        # pass text without parsing
        return { record => $xml };
    } elsif ( $xml->isa('XML::LibXML::Document') and !$xml->documentElement ) {
        # pass text of "rootless DOM" without parsing
        return { record => $xml->textContent };
    }

    if ( not $self->parser ) {
        return { record => "$xml" };
    } elsif ( is_code_ref($self->parser) ) {
        return $self->parser->($xml);
    } else {
        return $self->parser->parse($xml);
    }
}

1;
__END__

=head1 NAME

Catmandu::XML::Parser - parse XML records as simple XML

=head1 SYNOPSIS

    # implements Catmandu::XML::Parser
    use Catmandu::Importer::XML; 

    my $importer = Catmandu::Importer::XML->new(
        ...
        xslt   => 'transform.xsl', # optional XSLT transformation
        parser => 'foo',           # loads Catmandu::XML::Parser::foo
    );

=head1 DESCRIPTION

This module provides a L<Moo::Role> for transforming XML records, given as
L<XML::LibXML::Document> or as L<XML::LibXML::Element> into Perl hash
references. Transformation is done via optional XSLT script(s) followed by a
dedicated parser given as code reference or as module in the
C<Catmandu::XML::Parser::> namespace.

=cut
