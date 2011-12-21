package Data::Range::Compare::Stream::Iterator::Compare::Asc;

use strict;
use warnings;
use base qw(Data::Range::Compare::Stream::Iterator::Compare::Base);

sub has_next {
  my ($self)=@_;
  $self->prepare unless $self->prepared;
  $self->{has_next};
}

sub prepare {
  my ($self,%args)=@_;
  return undef if $self->prepared;
  $self->{prepared}=1;
  
  my $column_count=$self->get_column_count_human_readable;

  my $min_range_start;
  my $min_range_end;
  my $iterators_has_next_count;
  my $min_range_start_column_id=0;
  for(my $id=0;$id<$column_count;++$id)  {
    my $iterator=$self->{consolidateors}->[$id];
    unless($iterator->has_next) {
      $self->{has_next}=0;
      return undef;
    }
    my $raw_range=$iterator->get_next;

    push @{$self->{raw_row}},$raw_range;
    push @{$self->{last_column_value}},$raw_range->get_common;
    if(defined($min_range_start)) {
      my $common_raw=$raw_range->get_common;
      my $common_start=$min_range_start->get_common;
      my $common_end=$min_range_end->get_common;
      if($common_raw->cmp_range_start($common_start)==-1) {
        $min_range_start=$raw_range;
        $min_range_start_column_id=$id;
      }
      if($common_raw->cmp_range_end($common_end)==-1) {
       $min_range_end=$raw_range;
        $min_range_start_column_id=$id;
      }
    } else {
     $min_range_start=$raw_range;
     $min_range_end=$raw_range;
    }
    ++$iterators_has_next_count if $iterator->has_next;
  }

  $self->{iterators_empty}=!$iterators_has_next_count;

  my $next_range=$min_range_end->get_common->NEW_FROM_CLASS->new($min_range_start->get_common->range_start,$min_range_end->get_common->range_end);

  for(my $id=0;$id<$column_count;++$id)  {
    # stop here if this is the column started on
    
    my $cmp=$self->{raw_row}->[$id]->get_common;
    my $cmp_end=$cmp->previous_range_end;

    if($next_range->contains_value($cmp_end)) {
      if($next_range->cmp_values($next_range->range_end,$cmp_end)==1){
        $next_range=$next_range->NEW_FROM_CLASS->new($next_range->range_start,$cmp_end);
      }
    }

  }

  $self->{has_next}=1;
  $self->{current_row}=$next_range;
  $self->{processed_ranges}=1;

  1;
}

sub get_next {
  my ($self)=@_;
  return undef unless $self->has_next;

  # get the current row
  my $current_row=$self->get_current_row;

  my $result=[];
  my $column_count=$self->get_column_count_human_readable;

  my $next_range_start=$current_row->next_range_start;
  my $iterators_has_next_count;
  my $max_range_end;

  my $overlap_count=0;
  my $overlap_ids=[];
  my $non_overlap_ids=[];
  my $created_range=0;
  my $next_range;

  for(my $id=0;$id<$column_count;++$id)  {
    
    # Objects we will use throught the loop
    my $raw_range=$self->{raw_row}->[$id];
    my $iterator=$self->{consolidateors}->[$id];
    my $cmp=$raw_range->get_common;

    # current row computations
    if($current_row->overlap($cmp)) {
      push @$result,$raw_range;
      ++$overlap_count;
      push @$overlap_ids,$id;
    } else {
      push @$result,undef;
      push @$non_overlap_ids,$id;
    }

    if($cmp->cmp_ranges($current_row)==0 or $cmp->cmp_range_end($current_row)==0) {
      if($iterator->has_next) {
        my $next_range=$iterator->get_next;

        $raw_range=$next_range;
	  $cmp=$raw_range->get_common;
        $self->{raw_row}->[$id]=$next_range;
	}
    } 

    ++$iterators_has_next_count if $iterator->has_next;

    if(defined($next_range)) {
      my $cmp_end=$cmp->previous_range_end;
      if($next_range->contains_value($cmp_end)) {
        if($next_range->cmp_values($next_range->range_end,$cmp_end)!=-1){
          $next_range=$next_range->NEW_FROM_CLASS->new($next_range->range_start,$cmp_end);
        }
      } elsif($next_range->cmp_range_end($cmp)==1 and $cmp->cmp_values($next_range_start,$cmp->range_end)!=1) {
          $next_range=$next_range->NEW_FROM_CLASS->new($next_range->range_start,$cmp->range_end);
      }
    } else {
      my $cmp_end=$cmp->previous_range_end;
      if($cmp->cmp_values($next_range_start,$cmp_end)!=1) {
          $next_range=$cmp->NEW_FROM_CLASS->new($next_range_start,$cmp_end);
      } elsif($cmp->cmp_values($next_range_start,$cmp->range_end)!=1) {
          $next_range=$cmp->NEW_FROM_CLASS->new($next_range_start,$cmp->range_end);
      }
    
    }
    
    if(defined($max_range_end)) {
      $max_range_end=$cmp if $max_range_end->cmp_range_end($cmp)==-1;
    } else {
      $max_range_end=$cmp;
    }
  }

  $self->{iterators_empty}=!$iterators_has_next_count;

  if($self->{last_row}) {
    $self->{has_next}=0;
  } else {

    unless(defined($next_range)) {
      $next_range=$current_row->NEW_FROM_CLASS->new($next_range_start,$next_range_start);
    }

    $self->{current_row}=$next_range;
    $self->{last_row}=($self->{iterators_empty} and $next_range->cmp_range_end($max_range_end)!=-1);
  }

  my $obj=$self->RESULT_CLASS->new(
    $current_row,
    $result,
    $overlap_count,
    $overlap_ids,
    $non_overlap_ids,
  );
  return $obj;
}

1;
