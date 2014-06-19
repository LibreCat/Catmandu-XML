use strict;
use warnings;
use Test::More;

use Catmandu::Fix::xml_transform as => 'transform';

my $data = { xml => '<doc attr="bar"/>' };
transform($data,'xml', file => 't/example.xslt');
is $data->{xml}, "<?xml version=\"1.0\"?>\n<foo>bar</foo>\n", 'xml_transform string';

$data = { xml => [ doc => { attr => "bar" }, [ ] ] };
transform($data,'xml', file => 't/example.xslt');
is_deeply $data->{xml}, [ foo => { }, ['bar'] ], 'xml_transform struct';

done_testing;
