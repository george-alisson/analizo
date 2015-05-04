package Analizo::GlobalMetric::TotalPackages;
use strict;
use base qw(Class::Accessor::Fast);
use File::Basename;

=head1 DESCRIPTION

NOP is the packages in the system.

=cut

__PACKAGE__->mk_accessors(qw( model));

sub new {
  my ($package, %args) = @_;
  my @instance_variables = (
    model => $args{model},
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return "Total Number of Packages";
}

sub calculate {
  my ($self) = @_;
  my @modules = $self->model->module_names;
  my @packages = ();

  for my $module (@modules) {
    my @files = $self->model->files($module);

    if (@files) {
	  my $name = dirname($files[-1][0]);
	
	  push(@packages, $name) unless grep{$_ eq $name} @packages;
    }
  }
  return scalar @packages || 0;
}

1;

