use strict;
use warnings;
use Test::More skip_all => 'patch required';
use Catmandu::Exporter::XML;
use File::Temp;

my ($fh, $filename) = File::Temp::tempfile;

if(0) {
    # TODO: need to use character entities in XML::Struct::Writer::Stream
    #   s/([^\0-\xFF])/'&#' . ord($1) . ';'/eg; or
    #   s/([^\0-\x7F])/'&#' . ord($1) . ';'/eg;
    my $exporter = Catmandu::Exporter::XML->new( 
        file => $filename, encoding => 'ISO-8859-1' 
    );
    #$exporter->add( [ foo => { bar => "\x{201c}hi\x{201d}" }, ['&'] ] );
    $exporter->add( [ foo => { bar => "xx{201c}hi{201d}" }, ['&'] ] );
    $exporter->commit;

    open my $fh, "<:encoding(iso-8859-1)", $filename;
    my $written = join "\n", <$fh>;
}


done_testing;
