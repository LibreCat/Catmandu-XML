package Catmandu::XML::Parser::simple;

use Catmandu::Sane;
use Moo;
use Scalar::Util qw(blessed);
use XML::Struct::Simple;

our $VERSION = '0.01';

sub parse {
    my ($self, $xml) = @_;
    return unless blessed $xml;
    return { record => XML::Struct::Simple->new->transform($xml) };
}

1;
__END__

=head1 NAME

Catmandu::XML::Parser::simple - parse XML records as simple XML

=head1 DESCRIPTION

This L<Catmandu::XML::Parser> parses an XML document or element into simple
form as known from L<XML::Simple>. Parsing is based on L<XML::Struct::Simple>.

On success the parsed XML record is returned in field C<record> of the result
hash.

=cut
