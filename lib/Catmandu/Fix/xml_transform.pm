package Catmandu::Fix::xml_transform;
use Catmandu::Sane;
use Moo;
use XML::LibXML;
use XML::LibXSLT;
use Data::Dumper;

with 'Catmandu::Fix::Base';

has field => (
  is => 'ro',
  required => 1
);
has file => (
  is => 'ro',
  required => 1
);
has _transformer => (
  is => 'ro',
  lazy => 1,
  default => sub {
    XML::LibXSLT->new()->parse_stylesheet(XML::LibXML->load_xml(location => $_[0]->file));
  }
);

around BUILDARGS => sub {
  my($orig,$class,$field,%opts) = @_;
  $orig->($class,field => $field,file => $opts{file});
};

# Transforms xml
sub emit {  
  my($self,$fixer) = @_;  

  my $perl = "";

  my $path = $fixer->split_path($self->field());
  my $key = pop @$path;
  
  my $transformer = $fixer->capture($self->_transformer()); 

  $perl .= $fixer->emit_walk_path($fixer->var,$path,sub{
    my $var = $_[0];   
    $fixer->emit_get_key($var,$key,sub{
      my $var = $_[0];
      my $perl = "";
      my $results = $fixer->generate_var();   
      $perl .= "my ${results} = ${transformer}->transform(XML::LibXML->load_xml(string => ${var}));";
      $perl .= "${var} = ${transformer}->output_as_chars(${results});";
      $perl;
    });
  });

  $perl;

}

=head1 NAME

Catmandu::Fix::xml_transform - transform xml using xslt-stylesheets

=head1 SYNOPSIS
   
   # Transforms the 'xml' from marcxml to dublin core xml
   xml_transform('xml',file => 'marcxml2dc.xsl');

=head1 SEE ALSO

L<Catmandu::Fix>

=cut

1;
