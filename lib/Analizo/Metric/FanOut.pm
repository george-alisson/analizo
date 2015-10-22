package Analizo::Metric::FanOut;
use strict;
use base qw(Class::Accessor::Fast Analizo::ModuleMetric);

__PACKAGE__->mk_accessors(qw( model ));

=head1 DESCRIPTION

FANOUT is the number of functions defined in other modules that are called by function X.

=cut

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model}
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return "Fan Out";
}

sub calculate {
  my ($self, $module) = @_;
  return $self->_fan_out_by($module);
}

sub _fan_out_by {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);
  my $number_of_functions_called_by_module = $self->_number_of_diferent_functions_called_by($module, @functions);
  return $number_of_functions_called_by_module;
}

sub _number_of_diferent_functions_called_by {
  my ($self, $module, @functions) = @_;

  my @modules = ($module,);
  for my $function (@functions) {
    my $key;
    my $value;
    while (($key, $value) = each %{$self->model->calls->{$function}}) {
      #if($value eq "direct") {
        my $function_module = $self->model->members->{$key}; 
        push(@modules, $function_module) unless grep{$_ eq $function_module} @modules;
      #}
    }
  }
  return scalar(@modules) -1;
}

1;

