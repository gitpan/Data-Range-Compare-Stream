#!/usr/bin/perl

# custom package from FILE_EXAMPLE.pl
use strict;
use warnings;
use lib qw(./ ../lib);

use Data::Range::Compare::Stream::Iterator::File; 
use Data::Range::Compare::Stream;
use Data::Range::Compare::Stream::Iterator::Consolidate::OverlapAsColumn;
use Data::Range::Compare::Stream::Iterator::Compare::Asc;
use Data::Range::Compare::Stream::Iterator::Compare::ColumnRelations;

my $compare=new  Data::Range::Compare::Stream::Iterator::Compare::Asc();
my $relations=new Data::Range::Compare::Stream::Iterator::Compare::ColumnRelations($compare);

foreach my $file (qw(source_a.src source_b.src source_d.src source_c.src source_d.src)) {
  my $src=Data::Range::Compare::Stream::Iterator::File->new(filename=>$file);
  my $con=new Data::Range::Compare::Stream::Iterator::Consolidate::OverlapAsColumn($src,$compare);
  $compare->add_consolidator($con);
}

my $format='  | %-12s | %-26s |  %-26s|  %-26s|  %-26s|'."\n";
my $break="  +--------------+----------------------------+----------------------------+----------------------------+----------------------------+\n";
printf "$break$format$break","Intersection","Set A",'Set B','Set C','Set D';

while($compare->has_next) {

  my $result=$compare->get_next;
  next if $result->is_empty;

  my $columns=$relations->get_root_results($result);
  my @row=($result->get_common);
  foreach my $id (@{$relations->get_root_ids}) {
    if(exists $columns->{$id}) {
    push @row, join ', ',map { $_->get_common } @{$columns->{$id}};
    } else {
      push @row,"No Data";
    }
  }

  printf $format,@row;
  print $break;
}
