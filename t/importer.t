use strict;
use warnings;
use Test::More;

use_ok('Catmandu::Importer::XML');

sub check_import(@) {
    my $options = shift;
    my $file    = shift;
    my $importer = Catmandu::Importer::XML->new(file => $file, %$options);
#    use Data::Dumper; print Dumper($importer->to_array)."\n";
    is_deeply $importer->to_array, @_;
}

check_import { },
    \"<root><element>content</element></root>" => [ { element => 'content' } ],
    'simple';

check_import { type => 'ordered' },
    \"<root><element>content</element></root>" => [ 
        "root", {}, [
            [ "element", {}, 'content' ]
        ]
    ],
    'simple';


done_testing;
