use strict;
use warnings;
use Test::More;

use_ok('Catmandu::Importer::XML');

sub check_import(@) {
    my $options = shift;
    my $file    = shift;
    my $importer = Catmandu::Importer::XML->new(file => $file, %$options);
    
    my $data = $importer->to_array;
    use Data::Dumper; print Dumper($data)."\n";

    is_deeply $data, @_;
}

check_import { },
    \"<root><element>content</element></root>" => [ { element => 'content' } ],
    'simple';

check_import { type => 'ordered' },
    \"<root x='1'><element>content</element></root>" => [ [ 
        root => { x => 1 }, [
            [ element => { } , [ 'content' ] ]
        ]
    ] ],
    'ordered';

my $xml = <<'XML';
<?xml version="1.0"?>
<doc attr="value">
  <field1>foo</field1>
  <field1>bar</field1>
  <field2>
    <doz>baz</doz>
  </field2>
</doc>
XML

check_import { }, \$xml, [
      {
        attr => 'value',
        field1 => [ 'foo', 'bar' ],
        field2 => { 'doz' => 'baz' },
      }
    ], 'simple';

check_import { type => 'ordered', attributes => 1 },
    \$xml => [ 
        [ doc => { attr => "value" }, [
                [ field1 => { }, ["foo"] ],
                [ field1 => { },  ["bar"] ],
                [ field2 => { }, [ [ doz => { }, ["baz"] ] ] ]
            ]
        ] 
    ], 'ordered with attributes';

check_import { type => 'ordered', attributes => 0 },
    \$xml => [ 
        [ doc => [
                [ field1 => ["foo"] ],
                [ field1 => ["bar"] ],
                [ field2 => [ [ doz => ["baz"] ] ] ]
            ]
        ]
    ], 'ordered without attributes';

done_testing;

        
