package Data::Range::Compare::Stream::Iterator::Consolidate::OverlapAsColumn;

use strict;
use warnings;
use Carp qw(croak);

use Data::Dumper;

use base qw(Data::Range::Compare::Stream::Iterator::Consolidate);
use Data::Range::Compare::Stream::Iterator::Array;

use constant NEW_ARRAY_ITERATOR_FROM=>'Data::Range::Compare::Stream::Iterator::Array';
use constant NEW_CHILD_CONSOLIDATOR_FROM=>'Data::Range::Compare::Stream::Iterator::Consolidate::OverlapAsColumn';

sub new {
  my ($class,$it,$cmp)=@_;
  croak('Required Arguments are: $iterator,$compare') unless defined($cmp);
  my $self=$class->SUPER::new($it);
  $self->{compare}=$cmp;
  $self->{buffer}=[];
  $self;
}

sub get_child { $_[0]->{consolidator} }

sub on_consolidate {
  my ($self,$new_range,$last_range,$next_range)=@_;

  my $cmp=$self->{compare};
  my $iterator;

  if(defined($self->{iterator_array})) { 
     $iterator=$self->{iterator_array};
     $iterator->insert_range($next_range);
  } else {
     $iterator=$self->{iterator_array}=$self->NEW_ARRAY_ITERATOR_FROM->new(sorted=>1);
     $iterator->insert_range($next_range);
     my $consolidator=$self->{consolidator}=$self->NEW_CHILD_CONSOLIDATOR_FROM->new($iterator,$cmp);
     $consolidator->set_root_column_id($self->get_column_id);
  }

}
sub get_compare { $_[0]->{compare} }

sub get_root { 
  my ($self)=@_;
  $self->get_compare->get_iterator_by_id($self->get_root_column_id)
}

sub has_next {
  my ($self)=@_;

  return 1 if $#{$self->{buffer}}!=-1;
  return 1 if $self->SUPER::has_next;

  if($self->is_child) {
    my $cmp=$self->get_compare;
    my $root=$self->get_root;
    if($root->SUPER::has_next) {
      $root->push_to_buffer;
      return 1 if $#{$self->{buffer}}!=-1;
    }
  }
  return 0;
}

sub get_current_result { $_[0]->{current_result} }

sub get_next {
  my ($self)=@_;

  if($#{$self->{buffer}}==-1 and $self->SUPER::has_next) {
    $self->push_to_buffer;
  }
  my $result=shift @{$self->{buffer}};
  $self->{current_result}=$result;
  return $result;

}

sub buffer_count { 1 + $#{$_[0]->{buffer}} } 

sub get_buffer { $_[0]->{buffer} }

sub iterator_has_next { $_[0]->{iterator}->has_next }

sub push_to_buffer {
  my ($self)=@_;

  my $overlapping_range;
  if(defined($self->{last_range})) {
    $overlapping_range=$self->{last_range};
    $self->{last_range}=undef;
  } else {
    $overlapping_range=$self->{iterator}->get_next;
    $self->{last_range}=$overlapping_range;
  }
  return 0 unless defined($overlapping_range);

  my $result=$overlapping_range;
  my $pushed_to_child=0;
  if($self->iterator_has_next) {
    OVERLAP_CHECK: while($self->iterator_has_next) {
  
      my $next_range=$self->{iterator}->get_next;
  
      if($overlapping_range->overlap($next_range)) {
  
        $overlapping_range=$overlapping_range->get_overlapping_range([$overlapping_range,$next_range]);
        $self->on_consolidate($overlapping_range,$result,$next_range);
        $pushed_to_child++;
        $self->{last_range}=undef;
  
      } else {
  
        $self->{last_range}=$next_range;
        last OVERLAP_CHECK;
  
      }
    }
  } else {
      $self->{last_range}=undef;
  }

  if($pushed_to_child) {
    my $child=$self->get_child;
    $child->push_to_buffer;
    $self->{compare}->insert_consolidator($child) unless defined($child->get_column_id);
  }


  push @{$self->{buffer}},$self->RESULT_CLASS->new($result,$result,$result); 
  return 1;
}

1;
