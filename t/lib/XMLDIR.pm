package XMLDIR;

use Moo;
use Catmandu::Importer::XML;

with 'Catmandu::Importer';

has dir => (
    is => 'ro', 
    required => '.', 
    coerce => sub {
        my $dir;
        opendir($dir, $_[0]) or die "can't opendir $_[0] $!";
        $dir;
    }
);

sub generator {
    my ($self) = @_;

    sub {
        state $importer;

        if ($importer) {
            my $item = $importer->first;
            return if defined $item;
        }

        while( readdir($self->dir) ) {
            /\.xml/ or next;
            $importer = Catmandu::Importer::XML->new(
                file => $_
            );
        }

        return $importer ? $importer->first : undef;
    };
}

1;
