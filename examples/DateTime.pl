#!/usr/bin/perl

use strict;
use warnings;
use lib qw(../lib);

use Data::Range::Compare::Stream::Iterator::Array;
use Data::Range::Compare::Stream::Iterator::Consolidate;
use Data::Range::Compare::Stream::Iterator::Compare::Asc;

my $vpn_a=new Data::Range::Compare::Stream::Iterator::Array(new_from=>'MyDateTypeRangeCompare');
my $vpn_b=new Data::Range::Compare::Stream::Iterator::Array(new_from=>'MyDateTypeRangeCompare');;
my $vpn_c=new Data::Range::Compare::Stream::Iterator::Array(new_from=>'MyDateTypeRangeCompare');;

#
# Outage block for vpn_a
$vpn_a->create_range(
   DateTime->new(qw(year 2010 month 01 day 02 hour 10 minute 01 second 59)),
   DateTime->new(qw(year 2010 month 01 day 02 hour 10 minute 05 second 47))
);

$vpn_a->create_range(
   DateTime->new(qw(year 2010 month 05 day 02 hour 07 minute 41 second 32)),
   DateTime->new(qw(year 2010 month 05 day 02 hour 08 minute 00 second 16))
);


#
# Outage block for vpn_b
$vpn_b->create_range( 
   DateTime->new(qw(year 2010 month 05 day 02 hour 07 minute 41 second 32)),
   DateTime->new(qw(year 2010 month 05 day 02 hour 07 minute 58 second 13))
);

$vpn_b->create_range( 
   DateTime->new(qw(year 2010 month 01 day 02 hour 10 minute 03 second 59)),
   DateTime->new(qw(year 2010 month 01 day 02 hour 10 minute 04 second 37))
);


#
# Outage block for vpn_c
$vpn_c->create_range( 
    DateTime->new(qw(year 2010 month 01 day 02 hour 10 minute 03 second 59)),
    DateTime->new(qw(year 2010 month 01 day 02 hour 10 minute  04 second 37))
);

$vpn_c->create_range( 
    DateTime->new(qw(year 2010 month 05 day 02 hour 07 minute 41 second 32)),
    DateTime->new(qw(year 2010 month 05 day 02 hour 07 minute 58 second 13))
);

$vpn_c->create_range( 
    DateTime->new(qw(year 2010 month 05 day 02 hour 07 minute 59 second 07)),
    DateTime->new(qw(year 2010 month 05 day 02 hour 08 minute 00 second 16))
);

$vpn_c->create_range( 
    DateTime->new(qw(year 2010 month 06 day 18 hour 10 minute 58 second 21)),
    DateTime->new(qw(year 2010 month 06 day 18 hour 22 minute 06 second 55))
  );



#
# Make sure our list of vpns are sorted
$vpn_a->prepare_for_consolidate_asc;
$vpn_b->prepare_for_consolidate_asc;
$vpn_c->prepare_for_consolidate_asc;

#
# create our consolidation interface for each Array Iterator
my $column_a=Data::Range::Compare::Stream::Iterator::Consolidate->new($vpn_a);
my $column_b=Data::Range::Compare::Stream::Iterator::Consolidate->new($vpn_b);
my $column_c=Data::Range::Compare::Stream::Iterator::Consolidate->new($vpn_c);

#
# Create our compare object
my $compare=Data::Range::Compare::Stream::Iterator::Compare::Asc->new;

$compare->add_consolidator($column_a);
$compare->add_consolidator($column_b);
$compare->add_consolidator($column_c);

my @column_names=(qw(vpn_a vpn_b vpn_c));

while($compare->has_next) {
  my $row=$compare->get_next;
  
  # skip all rows that don't complety overlap
  next unless $row->all_overlap;

  my $common=$row->get_common;
  
  my $outage=$common->range_end->subtract_datetime($common->range_start);
  print "Common outage range: $common\n";
  print "Total Downtime: Months: $outage->{months} Days: $outage->{days} Minutes: $outage->{minutes} Seconds: $outage->{seconds}\n";

  for(my $id=0;$id<=$#column_names;++$id) {
    print $column_names[$id],' ',$row->get_consolidator_result_by_id($id)->get_common,"\n";
  }
  print "\n";
}


package MyDateTypeRangeCompare;

use strict;
use warnings;
use DateTime;
use lib qw(../lib);
use base qw(Data::Range::Compare::Stream);

#
# Define the class internals will use when creating a new object instance(s)
use constant NEW_FROM_CLASS=>'MyDateTypeRangeCompare';

sub cmp_values ($$) {
  my ($self,$value_a,$value_b)=@_;
  return DateTime->compare($value_a,$value_b);
}

sub add_one ($) {
  my ($self,$value)=@_;
  return $value->clone->add(seconds=>1);
}

sub sub_one ($) {
  my ($self,$value)=@_;
  return $value->clone->subtract(seconds=>1);
}

sub range_start_to_string {
  my ($self)=@_;
  return $self->range_start->strftime('%F %T');
}

sub range_end_to_string {
  my ($self)=@_;
  return $self->range_end->strftime('%F %T');
}

1;
