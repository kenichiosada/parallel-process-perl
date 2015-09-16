#!/usr/local/env perl

use strict;
use warnings;

use Text::CSV_XS;
use Parallel::ForkManager;
use Benchmark qw( timethis timethese cmpthese );
use Data::Dumper;

# Store CSV data in memory
sub read_csv {
  my @rows;
  my $csv = Text::CSV_XS->new({ binary => 1 });
  open my $fh, "<:encoding(utf8)", "restaurants.csv" or die "restaurants.csv: $!";
  $csv->getline($fh); # skip header
  while ( my $row = $csv->getline($fh) ) {
    if ( defined $row->[5] ) {
      push @rows, $row;
    }
  }
  close $fh;
  return \@rows;
}

# Count number of restaurants per prefecture
sub count_restaurants {
  my $rows = shift;
  my %result;
  foreach ( @{$rows} ) {
    my $pref_id = $_->[5];
    if ( !$result{$pref_id} ) {
      $result{$pref_id} = 1;
    } else {
      $result{$pref_id}++;
    }
  }
  return \%result; 
}

# Show top 5 
sub show_result {
  my $result = shift;
  my $cnt = 1;
  foreach my $key ( sort { $result->{$b} <=> $result->{$a} } keys %$result ) {
    if ( $cnt < 6 ) {
      print "#$cnt Prefecture ID: $key ($result->{$key} restaurants)\n";
    }
    $cnt++;
  }
};

my $procedural = sub {
  my $data = read_csv();
  my $result = count_restaurants($data); 
  show_result($result);
};

my $parallel = sub {
  my $data = read_csv();

  my $num_children = 3;
  my $pm = Parallel::ForkManager->new($num_children);

  # callback
  my %result;
  $pm->run_on_finish( sub {
    my ( $pid, $exit_code, $ident, $exit_signal, $core_dump, $data_ref ) = @_;
    if ( defined $data_ref->{count} ) {
      foreach my $key ( keys %{$data_ref->{count}} ) {
        if ( defined $result{$key} ) {
          $result{$key} += $data_ref->{count}->{$key};
        } else {
          $result{$key} = $data_ref->{count}->{$key};
        }
      }
    }
  });

  # make copy
  my @sample_data = @{$data};

  my $task_per_child = 140000;
  while ( my @data_to_work = splice @sample_data, 0, $task_per_child ) {
    $pm->start and next;
    my $result = count_restaurants(\@data_to_work);
    $pm->finish( 0, { count => $result } );
  }
  
  $pm->wait_all_children;
  show_result(\%result);
};

cmpthese timethese 10, {
  'Parallel' => $parallel,
  'Procedural' => $procedural,
};
