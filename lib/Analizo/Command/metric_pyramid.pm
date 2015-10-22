package Analizo::Command::metric_pyramid;
use Analizo -command;
use base qw(Analizo::Command);
use strict;
use warnings;
use YAML::Tiny;
use File::Basename;
use XML::LibXML;
use FindBin;

# ABSTRACT: generates a metric pyramid from analizo .yml metric files

=head1 NAME

analizo metric-pyramid - generates a metric pyramid from analizo .yml metric files

=head1 USAGE

  analizo metric-pyramid [OPTIONS] <ymlfile>

=cut

sub usage_desc { "%c metric-pyramid %o <ymlfile>" }

sub command_names { qw/metric-pyramid/ }

sub opt_spec {
  return (
    [ 'output|o=s', 'output file name' ],
  );
}

sub validate {
  my ($self, $opt, $args) = @_;
  $self->usage_error("No input files!") unless @$args;
  if ($opt->output && ! -w dirname($opt->output)) {
    $self->usage_error("Output is not writable!");
  }
}

sub execute {
  my ($self, $opt, $args) = @_;

  my $svg;
  foreach my $yml (@$args) {
    (my $version = $yml) =~ s/^.*-(.*)\.yml$/$1/;
    my $stream = YAML::Tiny->read($yml)
      or die YAML::Tiny->errstr;
    if (@{ $stream } > 0) {
      $svg = $self->_generate_svg($stream->[0]);
    } else {
      print STDERR "W: $yml seems to be empty\n";
    }
  }
  if (not $svg) {
    print STDERR "E: svg not generated.\n";
  }
  else {
    if ($opt->output) {
      open STDOUT, '>', $opt->output or die "$!\n";
    }
    print STDOUT $svg->toString;
    close STDOUT;
  }
}

sub _generate_svg {
  my ($self, $values) = @_;

  my $parser = XML::LibXML->new();
  my $filename = "$FindBin::Bin/templates/pyramid.svg";
  my $xml = $parser->parse_file($filename);
  my $svg = XML::LibXML::XPathContext->new($xml);
  $svg->registerNs('x', 'http://www.w3.org/2000/svg');

  $self->_set_value_color($svg, "ndd", $values->{pyramid_ave_ndd}, $self->_color_by_value($values->{pyramid_ave_ndd}, 0.25, 0.57));
  $self->_set_value_color($svg, "hit", $values->{pyramid_ave_hit}, $self->_color_by_value($values->{pyramid_ave_hit}, 0.09, 0.32));
  $self->_set_value_color($svg, "noc-nop", $values->{pyramid_mod_nop}, $self->_color_by_value($values->{pyramid_mod_nop}, 6, 26));
  $self->_set_value_color($svg, "nom-noc", $values->{pyramid_nom_mod}, $self->_color_by_value($values->{pyramid_nom_mod}, 4, 10));
  $self->_set_value_color($svg, "loc-nom", $values->{pyramid_loc_nom}, $self->_color_by_value($values->{pyramid_loc_nom}, 7, 13));
  $self->_set_value_color($svg, "cyclo-loc", $values->{pyramid_cyc_loc}, $self->_color_by_value($values->{pyramid_cyc_loc}, 0.16, 0.24));

  $self->_set_value_color($svg, "call-nom", $values->{pyramid_cal_nom}, $self->_color_by_value($values->{pyramid_cal_nom}, 2.01, 3.2));
  $self->_set_value_color($svg, "fout-call", $values->{pyramid_fou_cal}, $self->_color_by_value($values->{pyramid_fou_cal}, 0.56, 0.68));

  $self->_set_value($svg, "nop", $values->{total_packages});
  $self->_set_value($svg, "noc", $values->{total_modules});
  $self->_set_value($svg, "nom", $values->{total_nom});
  $self->_set_value($svg, "loc", $values->{total_loc});
  $self->_set_value($svg, "cyclo", $values->{total_cyclo});
  $self->_set_value($svg, "call", $values->{total_calls});
  $self->_set_value($svg, "fout", $values->{total_fout});

  return $xml;
}

sub _color_by_value {
  my ($self, $value, $low, $high) = @_;

  if ($value < $low) {
    return "royalblue";
  }
  elsif ($value > $high) {
    return "red";
  }
  return "lime";
}

sub _set_value {
  my ($self, $svg, $name, $value) = @_;
 
  my $query = "//x:text[\@id=\'$name\']/text()";
  my ($node) = $svg->findnodes($query);
  $node->setData($value);
}

sub _set_value_color {
  my ($self, $svg, $name, $value, $color) = @_;
 
  my $query = "//x:rect[\@id=\'$name-color\']";
  my($node) = $svg->findnodes($query);
  $node->setAttribute('fill' => $color);

  my $rounded = sprintf "%.2f", $value;
  $self->_set_value($svg, $name, $rounded);
}

=head1 DESCRIPTION

B<analizo metric-pyramid> generates a metric pyramid from project metrics
data.

=head1 OPTIONS

=over

=item --output <file>, -o <file>

Writes output to <file> instead of to standard output.

=back

=head1 COPYRIGHT AND AUTHORS

See B<analizo(1)>.

=cut

1;
