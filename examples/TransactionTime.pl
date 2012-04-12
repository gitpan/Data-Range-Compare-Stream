#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use lib qw(../lib);

use Data::Range::Compare::Stream::Iterator::Compare::Asc;
use Data::Range::Compare::Stream::Iterator::Consolidate::OverlapAsColumn;


my $cmp=new Data::Range::Compare::Stream::Iterator::Compare::Asc;


foreach my $file (qw(posix_time_a.src posix_time_b.src posix_time_c.src posix_time_d.src posix_time_e.src)) {
  my $iterator=new MyPosixDateFile(filename=>$file);
  my $con=new Data::Range::Compare::Stream::Iterator::Consolidate::OverlapAsColumn($iterator,$cmp);
  $cmp->add_consolidator($con);
}


my $total=0;
my $time=0;
my $non_overlaps=0;
my $non_time=0;
while($cmp->has_next) {
  my $result=$cmp->get_next;
  next if $result->is_empty;
  if($result->get_overlap_count>1) {
    $total +=$result->get_overlap_count;
    $time +=$result->get_common->time_count;
  } else {
    $non_overlaps++;
    $non_time +=$result->get_common->time_count;
  }
  next if 0==scalar(grep { $_>5 } @{$result->get_overlap_ids});

  
}

print "Total Trade Overlaps: $total\n";
print "Average Trade Time: ",int($time/$total),"\n\n";

print "Total Non Overlaps: $non_overlaps\n";
print "Average Non Overlap Trade time: ",int($non_time/$non_overlaps),"\n";

package Data::Range::Compare::Stream::PosixTime;

use strict;
use warnings;
use POSIX qw(strftime);

use base qw(Data::Range::Compare::Stream);

use constant NEW_FROM_CLASS=>'Data::Range::Compare::Stream::PosixTime';
sub format_range_value {
  my ($self,$value)=@_;
  strftime('%Y%m%d%H%M%S',localtime($value));
}

sub range_start_to_string {
  my ($self)=@_;
  $self->format_range_value($self->range_start);
}

sub time_count {
  my ($self)=@_;
  $self->range_end - $self->range_start
}


sub range_end_to_string {
  my ($self)=@_;
  $self->format_range_value($self->range_end);
}

1;

package MyPosixDateFile;
use strict;
use warnings;
use POSIX qw(mktime);
use Data::Dumper;

use base qw(Data::Range::Compare::Stream::Iterator::File);
use constant NEW_FROM=>'Data::Range::Compare::Stream::PosixTime';

sub parse_line {
  my ($self,$line)=@_;
  my $ref=[$line=~ /(\d+)/g];
  foreach my $date (@$ref) {
    my @info=unpack('a4a2a2a2a2a2',$date);
    $info[0] -=1900;
    $info[1] -=1;
    $date=mktime($info[5],$info[4],$info[3],$info[2],$info[1],$info[0], 0, 0, 0);
  }
  return $ref;
}

1;
