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
  my $cnt = 0;
  my $max_record = 100000;
  while ( my $row = $csv->getline($fh) ) {
    if ( defined $row->[5] ) {
      if ( $cnt < $max_record ) {
        push @rows, $row;
        $cnt++;
      }
    }
  }
  close $fh;
  return \@rows;
}

sub put_data {
  my $rows = shift;
  foreach ( @{$rows} ) {

    my $command = qq( 
      curl -XPUT -s http://localhost:9200/ldgourmet/restaurant/$_->[0] -d '{
        "id": "$_->[0]",
        "name": "",
        "property": "",
        "alphabet": "",
        "name_kana": "",
        "pref_id": "$_->[5]",
        "area_id": "$_->[6]",
        "station_id1": "$_->[7]",
        "station_time1": "$_->[8]",
        "station_distance1": "$_->[9]",
        "station_id2": "$_->[10]",
        "station_time2": "$_->[11]",
        "station_distance2": "$_->[12]",
        "station_id3": "$_->[13]",
        "station_time3": "$_->[14]",
        "station_distance3": "$_->[15]",
        "category_id1": "$_->[16]",
        "category_id2": "$_->[17]",
        "category_id3": "$_->[18]",
        "category_id4": "$_->[19]",
        "category_id5": "$_->[20]",
        "zip": "$_->[21]",
        "address": "",
        "north_latitude": "$_->[23]",
        "east_longitude": "$_->[24]",
        "description": "",
        "purpose": "",
        "open_morning": "$_->[27]",
        "open_lunch": "$_->[28]",
        "open_late": "$_->[29]",
        "photo_count": "$_->[30]",
        "special_count": "$_->[31]",
        "menu_count": "$_->[32]",                                                                                              
        "fan_count": "$_->[33]",                                                                                               
        "access_count": "$_->[34]",
        "created_on": "$_->[35]",
        "modified_on": "$_->[36]",
        "closed": "$_->[37]"
      }'
    );

    `$command >/dev/null 2>&1`;
  }
}

my $procedural = sub {
  my $data = read_csv();
  put_data($data);
};

my $parallel = sub {
  my $data = read_csv();

  my $num_children = 4;
  my $pm = Parallel::ForkManager->new($num_children);

  # make copy
  my @sample_data = @{$data};

  my $task_per_child = 25000;
  while ( my @data_to_work = splice @sample_data, 0, $task_per_child ) {
    $pm->start and next;
    put_data(\@data_to_work);
    $pm->finish;
  }
  $pm->wait_all_children;
};

cmpthese timethese 1, {
  'Parallel' => $parallel,
  'Procedural' => $procedural,
};

