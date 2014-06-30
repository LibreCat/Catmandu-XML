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
        my $xslt = XML::LibXML->load_xml(location => $_[0], no_cdata=>1);
        XML::LibXSLT->new()->parse_stylesheet($xslt);
    }
);

sub transform {
    my ($self, $xml) = @_;

    my $result;

    # DOM to DOM
    if (blessed $xml && $xml->isa('XML::LibXML::Document')) {
        $result = $self->stylesheet->transform($xml);
        if ($self->stylesheet->output_method ne 'text') {
            return $result;
        }
    # MicroXML to MicroXML
    } elsif (ref $xml) {
        $xml = XML::Struct::Writer->new->write($xml);
        $result = $self->stylesheet->transform($xml);
        if ($self->stylesheet->output_method ne 'text') {
            return XML::Struct::Reader->new( from => $result )->readDocument;
        }
    # string to string
    } else {
        $xml = XML::LibXML->load_xml(string => $xml);
        $result = $self->stylesheet->transform($xml);
    }

    return $result ? $self->stylesheet->output_as_chars($result) : undef;
}

1;

=head1 SYNOPISIS

    my $transformer = Catamandu::XML::Transformer->new( stylesheet => 'file.xsl' );

    $xml_string = $transformer->transform( $xml_string );
    $xml_dom    = $transformer->transform( $xml_dom );
    $xml_struct = $transformer->transform( $xml_struct );

=cut
