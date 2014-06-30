package Catmandu::XML::Transformer;
#ABSTRACT: Utility module for XSLT processing
#VERSION

use Catmandu::Sane;
use Moo;
use XML::LibXML;
use XML::LibXSLT;
use Scalar::Util qw(blessed);
use XML::Struct::Reader;
use XML::Struct::Writer;

has stylesheet => (
    is       => 'ro',
    required => 1,
    coerce   => sub {
        [ 
            map {
                XML::LibXSLT->new()->parse_stylesheet(
                    XML::LibXML->load_xml(location => $_, no_cdata=>1)
                )
            } (ref $_[0] // '' eq 'ARRAY' ? @{$_[0]} : $_[0])
        ]
    }
);

has has_text_output => (
    is      => 'lazy',
    default => sub {
        @{$_[0]->stylesheet} and $_[0]->stylesheet->[-1]->output_method eq 'text'
    }
);

sub transform_dom {
    my ($self, $dom) = @_;

    foreach (@{$self->stylesheet}) {
        $dom = $_->transform($dom);
    }

    return $dom;
}

sub transform {
    my ($self, $xml) = @_;
    my $result;

    # DOM to DOM
    if (blessed $xml && $xml->isa('XML::LibXML::Document')) {
        $result = $self->transform_dom($xml);
        unless ($self->has_text_output) {
            return $result;
        }
    # MicroXML to MicroXML
    } elsif (ref $xml) {
        $xml = XML::Struct::Writer->new->write($xml);
        $result = $self->transform_dom($xml);
        unless ($self->has_text_output) {
            return XML::Struct::Reader->new( from => $result )->readDocument;
        }
    # string to string
    } else {
        $xml = XML::LibXML->load_xml(string => $xml);
        $result = $self->transform_dom($xml);
    }

    if ($result and $self->stylesheet->[-1]) {
        return $self->stylesheet->[-1]->output_as_chars($result);
    } else {
        return $result;
    }
}

=head1 SYNOPISIS

    my $transformer = Catamandu::XML::Transformer->new( stylesheet => 'file.xsl' );

    $xml_string = $transformer->transform( $xml_string );
    $xml_dom    = $transformer->transform( $xml_dom );
    $xml_struct = $transformer->transform( $xml_struct );

=head1 CONFIGURATION

=head1 stylesheet

XSLT filename or array reference with multiple files to apply as transformation
pipeline.

=cut

1;
