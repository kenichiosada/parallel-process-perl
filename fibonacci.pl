#!/usr/local/env perl

use strict;
use warnings;

use Parallel::ForkManager;
use Benchmark qw/ cmpthese timethese /;

sub fibonacci {
  my $n = shift;
  if ( $n == 0 ) {
    return 0;
  } elsif ( $n == 1 ) {
    return 1;
  }elsif( $n > 1){
    return fibonacci( $n - 1 ) + fibonacci( $n - 2 );
  }
}

# 1 process, calculating 10000 times 
my $total1 = 0;
my $procedural = sub {
  my $cnt = 0;
  while ( $cnt < 10000 ) {
    $total1 += fibonacci(20);
    $cnt++;
  }
};

# 8 processes, calculating 1250 times each 
my $total2 = 0;
my $num_children = 8;
my $parallel = sub {
  my $pm = Parallel::ForkManager->new($num_children);

  $pm->run_on_finish( sub {
    my ( $pid, $exit_code, $ident, $exit_signal, $core_dump, $data_ref ) = @_;
    if ( defined $data_ref ) {
      $total2 += $data_ref->{result};
    }
  });

  for ( 1 .. $num_children ) {
    $pm->start and next;
    my $result;
    for ( 1 .. 1250 ) {
      $result += fibonacci(20);
    }
    $pm->finish( 0, { result => $result} );
  }

  $pm->wait_all_children;
};

cmpthese timethese 1, {
  'Procedural'  => $procedural,
  'Parallel'    => $parallel,
};

print "Total1:  $total1\n";
print "Total2:  $total2\n";


