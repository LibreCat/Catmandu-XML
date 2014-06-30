use strict;
use warnings;
use Test::More;

use Catmandu::Fix::xml_transform as => 'transform';

my ($xml, $struct) = ('<doc attr="bar"/>', [ doc => { attr => "bar" }, [ ] ]);
my $data = { xml => $xml };
transform($data,'xml', file => 't/transform1.xsl');
is $data->{xml}, "<?xml version=\"1.0\"?>\n<foo>bar</foo>\n", 'xml_transform string';

$data = { xml => $struct };
transform($data,'xml', file => 't/transform1.xsl');
is_deeply $data->{xml}, [ foo => { }, ['bar'] ], 'xml_transform struct';

$data = { xml => $xml };
transform($data,'xml', file => 't/transform2.xsl');
is $data->{xml}, 'DOC: bar', 'xsl:output method=text (string)';

$data = { xml => $struct };
transform($data,'xml', file => 't/transform2.xsl');
is $data->{xml}, 'DOC: bar', 'xsl:output method=text (struct)';

$data = { xml => $struct };
transform($data,'xml', file => [] );
is_deeply $data, { xml => $struct }, 'empty transformation (struct)';

$data = { xml => $xml };
transform($data,'xml', file => [] );
is_deeply $data, { xml => "<?xml version=\"1.0\"?>\n$xml\n" }, 'empty transformation (string)';

$data = { xml => $struct };
transform($data,'xml', file => [qw(t/transform1.xsl t/transform3.xsl)]);
is_deeply $data, { xml => [ doz => { }, [ ] ] }, 'transformation pipeline';

done_testing;
