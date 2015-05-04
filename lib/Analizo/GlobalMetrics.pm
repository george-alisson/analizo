package Analizo::GlobalMetrics;
use strict;
use base qw(Class::Accessor::Fast);

use Analizo::GlobalMetric::TotalAbstractClasses;
use Analizo::GlobalMetric::MethodsPerAbstractClass;
use Analizo::GlobalMetric::TotalEloc;
use Analizo::GlobalMetric::ChangeCost;
use Analizo::GlobalMetric::TotalPackages;

use Statistics::Descriptive;


__PACKAGE__->mk_accessors(qw(
    model
    calculators
    metric_report
    values_lists
    module_metrics_list
));

sub new {
  my ($package, %args) = @_;
  my @instance_variables = (
    model => $args{model},
    calculators => _initialize_calculators($args{model}),
    metric_report => _initialize_metric_report(),
    values_lists => {},
  );
  return bless { @instance_variables }, $package;
}

sub _initialize_calculators {
  my ($model) = @_;
  my %calculators = (
    total_abstract_classes            => new Analizo::GlobalMetric::TotalAbstractClasses(model => $model),
    total_methods_per_abstract_class  => new Analizo::GlobalMetric::MethodsPerAbstractClass(model => $model),
    total_eloc                        => new Analizo::GlobalMetric::TotalEloc(model => $model),
    total_packages                    => new Analizo::GlobalMetric::TotalPackages(model => $model),
    change_cost                       => Analizo::GlobalMetric::ChangeCost->new(model => $model),
  );
  return \%calculators;
}

sub _initialize_metric_report {
  my %metric_report = (
    total_modules => 0,
    total_modules_with_defined_methods => 0,
    total_modules_with_defined_attributes => 0,
    total_nom => 0,
    total_loc => 0,
    total_cof => 0,
    total_cyclo => 0,
    total_ndd => 0,
    total_hit => 0,
    total_fout => 0,
    total_calls => 0,
  );
  return \%metric_report;
}

sub list {
  my ($self) = @_;
  my %list = (
    total_cof => "Total Coupling Factor",
    total_modules => "Total Number of Modules",
    total_nom => "Total Number of Methods",
    total_loc => "Total Lines of Code",
    total_cyclo => "Total Cyclomatic Complexity",
    total_ndd => "Total Number of Direct Descendants",
    total_hit => "Total Height of Inheritance Tree",
    total_fout => "Total Fan Out",
    total_calls => "Total Calls",
    total_modules_with_defined_methods => "Total number of modules with at least one defined method",
    total_modules_with_defined_attributes => "Total number of modules with at least one defined attributes"
  );
  for my $metric (keys %{$self->calculators}) {
    $list{$metric} = $self->calculators->{$metric}->description;
  }
  return %list;
}

sub add_module_values {
  my ($self, $values) = @_;

  $self->_update_metric_report($values);
  $self->_add_values_to_values_lists($values);
}

sub _update_metric_report {
  my ($self, $values) = @_;
  $self->metric_report->{'total_modules'} += 1;
  $self->metric_report->{'total_modules_with_defined_methods'} += 1 if $values->{'nom'} > 0;
  $self->metric_report->{'total_modules_with_defined_attributes'} += 1 if $values->{'noa'} > 0;
  $self->metric_report->{'total_nom'} += $values->{'nom'};
  $self->metric_report->{'total_loc'} += $values->{'loc'};
  $self->metric_report->{'total_cyclo'} += $values->{'cyclo'};
  $self->metric_report->{'total_ndd'} += $values->{'noc'};
  $self->metric_report->{'total_hit'} += $values->{'hit'};
  $self->metric_report->{'total_fout'} += $values->{'fout'};
  $self->metric_report->{'total_calls'} += $values->{'calls'};
}

sub _add_values_to_values_lists {
  my ($self, $values) = @_;
  for my $metric (keys %{$values}) {
    $self->_add_metric_value_to_values_list($metric, $values->{$metric});
  }
}

sub _add_metric_value_to_values_list {
  my ($self, $metric, $metric_value) = @_;
  if( $metric ne '_module' && $metric ne '_filename' ) {
    $self->values_lists->{$metric} = [] unless ($self->values_lists->{$metric});
    push @{$self->values_lists->{$metric}}, $metric_value;
  }
}

sub report {

  my ($self) = @_;

  $self->_include_metrics_from_calculators;
  $self->_add_statistics;
  $self->_add_total_coupling_factor;
  $self->_add_metric_pyramid;

  return \%{$self->metric_report};
}

sub _include_metrics_from_calculators {
  my ($self) = @_;
  for my $metric (keys %{$self->calculators}) {
    $self->metric_report->{$metric} = $self->calculators->{$metric}->calculate();
  }
}

sub _add_statistics {
  my ($self) = @_;

  for my $metric (keys %{$self->values_lists}) {
    my $statistics = Statistics::Descriptive::Full->new();
    $statistics->add_data(@{$self->values_lists->{$metric}});

    $self->_add_descriptive_statistics($metric, $statistics);
    $self->_add_distributions_statistics($metric, $statistics);
  }
}

sub _add_descriptive_statistics {
  my ($self, $metric, $statistics) = @_;
  $self->metric_report->{$metric . "_mean"} = $statistics->mean();
  $self->metric_report->{$metric . "_mode"} = $statistics->mode();
  $self->metric_report->{$metric . "_standard_deviation"} = $statistics->standard_deviation();
  $self->metric_report->{$metric . "_sum"} = $statistics->sum();
  $self->metric_report->{$metric . "_variance"} = $statistics->variance();

  $self->metric_report->{$metric . "_quantile_min"}   = $statistics->min(); #minimum
  $self->metric_report->{$metric . "_quantile_lower"}   = $statistics->quantile(1); #lower quartile
  $self->metric_report->{$metric . "_quantile_median"}   = $statistics->median(); #median
  $self->metric_report->{$metric . "_quantile_upper"}   = $statistics->quantile(3); #upper quartile
  $self->metric_report->{$metric . "_quantile_ninety_five"}  = $statistics->percentile(95); #95th percentile
  $self->metric_report->{$metric . "_quantile_max"} = $statistics->max(); #maximum
}

sub _add_distributions_statistics {
  my ($self, $metric, $statistics) = @_;

  if (($statistics->count >= 4) && ($statistics->variance() > 0)) {
    $self->metric_report->{$metric . "_kurtosis"} = $statistics->kurtosis();
    $self->metric_report->{$metric . "_skewness"} = $statistics->skewness();
  }
  else {
    $self->metric_report->{$metric . "_kurtosis"} = 0;
    $self->metric_report->{$metric . "_skewness"} = 0;
  }
}

sub _add_total_coupling_factor {
  my ($self) = @_;
  my $total_modules = $self->metric_report->{'total_modules'};
  my $total_acc = $self->metric_report->{'acc_sum'};

  $self->metric_report->{"total_cof"} = $self->coupling_factor($total_acc, $total_modules);
}

sub coupling_factor {
  my ($self, $total_acc, $total_modules) = @_;
  return ($total_modules > 1) ? $total_acc / _number_of_combinations($total_modules) : 1;
}

sub _number_of_combinations {
  my ($total_modules) = @_;
  return $total_modules * ($total_modules - 1);
}

sub _add_metric_pyramid {
  my ($self) = @_;

  $self->metric_report->{'pyramid_ave_ndd'} = 0;
  $self->metric_report->{'pyramid_ave_hit'} = 0;
  $self->metric_report->{'pyramid_mod_nop'} = 0;
  $self->metric_report->{'pyramid_nom_mod'} = 0;
  $self->metric_report->{'pyramid_loc_nom'} = 0;
  $self->metric_report->{'pyramid_cyc_loc'} = 0;
  
  $self->metric_report->{'pyramid_cal_nom'} = 0;
  $self->metric_report->{'pyramid_fou_cal'} = 0;

  $self->metric_report->{'pyramid_ave_ndd'} = ($self->metric_report->{'total_ndd'} / $self->metric_report->{'total_modules'}) if $self->metric_report->{'total_modules'} > 0;
  $self->metric_report->{'pyramid_ave_hit'} = ($self->metric_report->{'total_hit'} / $self->metric_report->{'total_modules'}) if $self->metric_report->{'total_modules'} > 0;
  $self->metric_report->{'pyramid_mod_nop'} = ($self->metric_report->{'total_modules'} / $self->metric_report->{'total_packages'}) if $self->metric_report->{'total_packages'} > 0;
  $self->metric_report->{'pyramid_nom_mod'} = ($self->metric_report->{'total_nom'} / $self->metric_report->{'total_modules'}) if $self->metric_report->{'total_modules'} > 0;
  $self->metric_report->{'pyramid_loc_nom'} = ($self->metric_report->{'total_loc'} / $self->metric_report->{'total_nom'}) if $self->metric_report->{'total_nom'} > 0;
  $self->metric_report->{'pyramid_cyc_loc'} = ($self->metric_report->{'total_cyclo'} / $self->metric_report->{'total_loc'}) if $self->metric_report->{'total_loc'} > 0;
  
  $self->metric_report->{'pyramid_cal_nom'} = ($self->metric_report->{'total_calls'} / $self->metric_report->{'total_nom'}) if $self->metric_report->{'total_nom'} > 0;
  $self->metric_report->{'pyramid_fou_cal'} = ($self->metric_report->{'total_fout'} / $self->metric_report->{'total_calls'}) if $self->metric_report->{'total_calls'} > 0;
}

1;

