package Data::Range::Compare::Stream;

use strict;
use warnings;
use overload '""'=>\&to_string,fallback=>1;
use Data::Range::Compare::Stream::Constants qw(RANGE_START RANGE_END RANGE_DATA);

use constant NEW_FROM_CLASS=>'Data::Range::Compare::Stream';

our $VERSION='0.002';

sub new {
  my ($class,@args)=@_;
  bless [@args],$class;
}

sub to_string () {
  my $notation=join ' - ',$_[0]->range_start_to_string,$_[0]->range_end_to_string;
  $notation;
}

sub range_start () { $_[0]->[RANGE_START] }
sub range_end () { $_[0]->[RANGE_END] }

sub range_start_to_string () { $_[0]->range_start }
sub range_end_to_string () { $_[0]->range_end }

sub add_one ($) {
  my ($self,$value)=@_;
  $value + 1;
}

sub sub_one ($) {
  my ($self,$value)=@_;
  $value - 1;
}

sub cmp_values ($$) {
  my ($self,$value_a,$value_b)=@_;
  $value_a <=> $value_b
}

sub next_range_start () { $_[0]->add_one($_[0]->range_end)  }
sub previous_range_end () { $_[0]->sub_one($_[0]->range_start)  }

sub data {
  my ($self,$data)=@_;
  return $self->[RANGE_DATA] unless defined($data);
  $self->[$self->RANGE_DATA]=$data;
}

sub get_common_range ($) {
  my ($class,$ranges)=@_;

  my ($range_start,$range_end)=@{$ranges}[0,0];

  for( my $x=1;$x<=$#$ranges;++$x) {
    $range_start=$ranges->[$x] if $class->cmp_values($range_start->range_start,$ranges->[$x]->range_start)==-1;
    $range_end=$ranges->[$x] if $class->cmp_values($range_end->range_end,$ranges->[$x]->range_end)==1;
  }

  $class->NEW_FROM_CLASS->new($range_start->range_start,$range_end->range_end);
}

sub get_overlapping_range ($) {
  my ($class,$ranges)=@_;

  my ($range_start,$range_end)=@{$ranges}[0,0];

  for( my $x=1;$x<=$#$ranges;++$x) {
    $range_start=$ranges->[$x] if $class->cmp_values($range_start->range_start,$ranges->[$x]->range_start)==1;
    $range_end=$ranges->[$x] if $class->cmp_values($range_end->range_end,$ranges->[$x]->range_end)==-1;
  }

  $class->NEW_FROM_CLASS->new($range_start->range_start,$range_end->range_end);
}


sub cmp_range_start($) {
  my ($self,$cmp)=@_;
  $self->cmp_values($self->range_start,$cmp->range_start)
}

sub cmp_range_end($) {
  my ($self,$cmp)=@_;
  $self->cmp_values($self->range_end,$cmp->range_end)
}

sub cmp_range_start_to_range_end ($) {
  my ($self,$cmp)=@_;
  $self->cmp_values($self->range_start,$cmp->range_end)
}


sub contains_value ($) {
  my ($self,$cmp)=@_;
  return 0 if $self->cmp_values($self->range_start,$cmp)==1;
  return 0 if $self->cmp_values($cmp,$self->range_end)==1;
  1
}

sub contiguous_check ($) {
  my ($cmp_a,$cmp_b)=@_;
  $cmp_a->cmp_values(
   $cmp_a->next_range_start
   ,$cmp_b->range_start
  )==0
}

sub cmp_ranges ($) {
  my ($range_a,$range_b)=@_;
  my $cmp=$range_a->cmp_range_start($range_b);
  if($cmp==0) {
    return $range_a->cmp_range_end($range_b);
  }
  return $cmp;
}

sub overlap ($) {
  my ($range_a,$range_b)=@_;

  return 1 if $range_a->contains_value($range_b->range_start);
  return 1 if $range_a->contains_value($range_b->range_end);

  return 1 if $range_b->contains_value($range_a->range_start);
  return 1 if $range_b->contains_value($range_a->range_end);

  return 0
}

1;
