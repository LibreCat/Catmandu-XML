use strict;
use warnings;
use Test::More;

use XML::Struct::Writer;

use_ok('Catmandu::Exporter::XML');

my $out = "";
my $exporter = Catmandu::Exporter::XML->new( file => \$out );

$exporter->add( [ foo => { bar => 'doz' }, ['&'] ] );
is $exporter->count, 1, 'count';

$exporter->add( [ foo => {}, ['<'] ] );
is $exporter->count, 2, 'count';

my $xml = <<XML;
<?xml version="1.0" encoding="UTF-8"?>
<foo bar="doz">&amp;</foo>
<?xml version="1.0" encoding="UTF-8"?>
<foo>&lt;</foo>
XML

is $out, $xml, 'exporter';

$out = "";
$exporter = Catmandu::Exporter::XML->new( 
    attributes => 0, pretty => 1, declaration => 0,
    file => \$out
);
$exporter->add( [ foo => [ [ bar => ['doz'] ] ] ] );
$xml = <<XML;
<foo>
  <bar>doz</doz>
</foo>
XML
is $out, $xml, 'exporter';

# TODO: export from selected field
# TODO: export each record to one file

done_testing;
