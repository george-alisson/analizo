package Analizo::GlobalMetric::TotalPackages;
use strict;
use base qw(Class::Accessor::Fast);
use File::Basename;

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
  my @packages;

  #print "modules -> " . @modules . "\n";
  for my $module (@modules) {
	#print "MODULE: " . $module . "\n";
    my @files = $self->model->files($module);
    #print "FILE: " . dirname($files[-1][0]) . "\n";

    if (@files) {
	  my $name = dirname($files[-1][0]);
	
	  push(@packages, $name) unless grep{$_ eq $name} @packages;
    }
  }
  return scalar @packages || 0;
}

1;

