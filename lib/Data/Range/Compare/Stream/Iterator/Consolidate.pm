package Data::Range::Compare::Stream::Iterator::Consolidate;

use strict;
use warnings;

use constant RESULT_CLASS=>'Data::Range::Compare::Stream::Iterator::Consolidate::Result';
use Data::Range::Compare::Stream::Iterator::Consolidate::Result;

sub new {
  my ($class,$iterator)=@_;
  bless {iterator=>$iterator},$class;
}

sub has_next {
  my ($self)=@_;
  return 1 if $self->{iterator}->has_next;
  return 1 if defined($self->{last_range});
  return undef;
}

sub get_next {
  my ($self)=@_;

  unless(defined($self->{last_range})) {
    return undef unless $self->{iterator}->has_next;
    $self->{last_range}=$self->{iterator}->get_next;
  }

  my $start_range=$self->{last_range};
  return undef unless defined($start_range);

  my $overlapping_range=$start_range;
  my $end_range=$start_range;

  while($self->{iterator}->has_next) {
    my $next_range=$self->{iterator}->get_next;
    if($overlapping_range->overlap($next_range)) {
      $overlapping_range=$overlapping_range->get_overlapping_range([$overlapping_range,$next_range]);
      $end_range=$next_range;
    } else {
      $self->{last_range}=$next_range;
      return $self->RESULT_CLASS->new($overlapping_range,$start_range,$end_range);
    }

    
  }
  $self->{last_range}=undef;
  return $self->RESULT_CLASS->new($overlapping_range,$start_range,$end_range);
}

1;

