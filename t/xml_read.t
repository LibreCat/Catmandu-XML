#use strict;
#use warnings;
use Test::More;

use Catmandu::Fix::xml_read as => 'parse';

my $data = {
    xml => '<foo bar="doz>baz</foo>'
};

parse($data,'xml');

print "----------";
use Data::Dumper;
print Dumper($data);

done_testing;
