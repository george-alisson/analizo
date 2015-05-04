package Analizo::Metric::Calls;
use strict;
use base qw(Class::Accessor::Fast Analizo::ModuleMetric);

__PACKAGE__->mk_accessors(qw( model ));

=head1 DESCRIPTION

CALLs is the total number of distict functions calls.

=cut

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model}
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return "Calls";
}

sub calculate {
  my ($self, $module) = @_;
  return $self->_calls_by($module);
}

sub _calls_by {
  my ($self, $module) = @_;

  my @functions = $self->model->functions($module);
  my $number_of_functions_called_by_module = $self->_number_of_functions_called_by(@functions);
  return $number_of_functions_called_by_module;
}

sub _number_of_functions_called_by {
  my ($self, @functions) = @_;

  my $count = 0;
  for my $function (@functions){
    my $key;
    my $value;
	while (($key, $value) = each %{$self->model->calls->{$function}}) {
      if ($value eq "direct") {
        $count++;
      }
    }
  }
  return $count;
}

1;

