package Catmandu::XML::Transformer;
#ABSTRACT: Utility module for XSLT processing
#VERSION

use Catmandu::Sane;
use Moo;
use XML::LibXML;
use XML::LibXSLT;
use Scalar::Util qw(blessed reftype);
use XML::Struct::Reader;
use XML::Struct::Writer;

has stylesheet => (
    is       => 'ro',
    coerce   => sub {
        [ 
            map {
                XML::LibXSLT->new()->parse_stylesheet(
                    XML::LibXML->load_xml(location => $_, no_cdata=>1)
                )
            } (ref $_[0] // '' eq 'ARRAY' ? @{$_[0]} : split /,/, $_[0])
        ]
    },
    default => sub { [] }
);

has output_format => (is => 'ro', coerce => sub { uc($_[0]) });

sub transform {
    my ($self, $xml) = @_;
    my ($format, $result);

    return if !defined $xml;

    if (blessed $xml && $xml->isa('XML::LibXML::Document')) {
        $format = 'DOM';
    } elsif (ref $xml) {
        if (reftype $xml eq 'ARRAY') {
            ($format, $xml) = (STRUCT => XML::Struct::Writer->new->write($xml));
        } else {
            ($format, $xml) = (SIMPLE => XML::Struct::Writer->new(simple => 1)->write($xml));
        }
    } else {
        ($format, $xml) = (STRING => XML::LibXML->load_xml(string => $xml));
    }

    $format = $self->output_format if $self->output_format;

    if (@{$self->stylesheet}) {
        $format = 'STRING' if $_[0]->stylesheet->[-1]->output_method eq 'text';
        foreach (@{$self->stylesheet}) {
            $xml = $_->transform($xml);
        }
    }

    if ($format eq 'STRING') {
        if ($self->stylesheet->[-1]) {
            return $self->stylesheet->[-1]->output_as_chars($xml);
        } else {
            return $xml->toString;
        }
    } elsif ($format eq 'STRUCT') {
        return XML::Struct::Reader->new( from => $xml )->readDocument;
    } elsif ($format eq 'SIMPLE') {
        # TODO: is root => 1 the right choice?
        $xml = XML::Struct::Reader->new( from => $xml, simple => 1, root => 1 )->readDocument;
        return $xml;
    } else {
        return $xml;
    }
}

=head1 SYNOPISIS

    my $transformer = Catamandu::XML::Transformer->new( stylesheet => 'file.xsl' );

    $xml_string = $transformer->transform( $xml_string );
    $xml_dom    = $transformer->transform( $xml_dom );
    $xml_struct = $transformer->transform( $xml_struct );

=head1 CONFIGURATION

=over

=item stylesheet

XSLT file, comma-separated list of files or array reference with multiple files
to apply as transformation pipeline. If no stylesheet is given, the input
document will just as DOM, string, or structure/simple (L<XML::Struct>).

=item output_format

Expected output format C<DOM>, C<string>, C<struct>, C<simple>. By default the
input format triggers the output format. If the last stylesheet has text output
(C<< <xsl:output method="text"/> >>) then output format is always C<string>.

=back

=cut

1;
