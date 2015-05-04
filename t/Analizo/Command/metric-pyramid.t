package t::Analizo::Command::metric_pyramid;
use strict;
use warnings;
use base qw(t::Analizo::Test::Class);
use Test::More;
use t::Analizo::Test;
use Analizo;

BEGIN {
  use_ok 'Analizo::Command::metric_pyramid'
};

sub constructor : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('metric-pyramid');
  isa_ok($cmd, 'Analizo::Command::metric_pyramid');
}

sub is_a_subclass_of_Analizo_Command : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('metric-pyramid');
  isa_ok($cmd, 'Analizo::Command');
}

__PACKAGE__->runtests;