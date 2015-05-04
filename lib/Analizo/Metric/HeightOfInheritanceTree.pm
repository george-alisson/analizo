package Analizo::Metric::HeightOfInheritanceTree;
use strict;
use base qw(Class::Accessor::Fast Analizo::ModuleMetric);

__PACKAGE__->mk_accessors(qw( model ));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model}
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return "Height of Inheritance Tree";
}

sub calculate {
  my ($self, $module) = @_;

  my @children = ($module,);
  my $brothers = 0;
  my $has_children = 0;
  for my $curent_module (@children) {
    for my $other_module ($self->model->module_names) {
      if ($self->_module_parent_of_other($curent_module, $other_module)) {
        push(@children, $other_module);
        if ($has_children) {
          $brothers++;
        }
        $has_children = 1;
      }
    }
    $has_children = 0;
  }
  my $tree = scalar(@children);
  if ($tree > 1) {
    return  $tree - $brothers;
  }
  return 0;
}

sub _module_parent_of_other {
  my ($self, $module, $other_module) = @_;
  return grep {$_ eq $module} $self->model->inheritance($other_module);
}

1;

