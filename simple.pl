#!/usr/local/env perl

use strict;
use warnings;

use Benchmark qw/ timethis cmpthese timethese /;

my $iteration = 10;

# Sleep X number of times
my $total1 = 0;
my $procedural = sub {
  for ( 1 .. $iteration ) {
    $total1 += task();
  }
};

# Sleep total of X times by Y number of processes
my $total2 = 0;
my $num_children = 4;
my $parallel = sub {
  use Parallel::ForkManager;
  my $pm = Parallel::ForkManager->new($num_children);

  $pm->run_on_finish( sub {
    my ( $pid, $exit_code, $ident, $exit_signal, $core_dump, $data_ref ) = @_;
    if ( defined $data_ref ) {
      $total2 += $data_ref->{result};
    }
  });

  for ( 1 .. $iteration ) {
    $pm->start and next;
    my $result = task();
    $pm->finish( 0, { result => $result} );
  }
  $pm->wait_all_children;
};

sub task {
  sleep 1; # Do time consuming task in reality.  
  return 1;
}

timethese 1, {
  'Procedural'  => $procedural,
  'Parallel'    => $parallel,
};

print "Task 1 slept $total1 times\n";
print "Task 2 slept $total2 times\n";
