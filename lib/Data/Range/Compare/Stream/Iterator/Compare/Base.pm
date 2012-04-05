package Data::Range::Compare::Stream::Iterator::Compare::Base;

use strict;
use warnings;
use Carp qw(croak);

use Data::Range::Compare::Stream::Iterator::Compare::Result;
use constant RESULT_CLASS=>'Data::Range::Compare::Stream::Iterator::Compare::Result';

sub new {
  my ($class,%args)=@_;
  bless {last_row=>0,iterators_empty=>0,prepared=>0,consolidateors=>[],raw_row=>[],%args},$class;
}

sub prepared { $_[0]->{prepared} }

sub add_consolidator {
  my ($self,$consolidator)=@_;

  croak "Fatal error, cannot add new objects once the consolidator has been called!!" if $self->prepared;
  push @{$self->{consolidateors}},$consolidator;
  my $id=$#{$self->{consolidateors}};

  $consolidator->set_column_id($id);
  return $id
}

sub set_column_id { $_[0]->{column_id}=$_[1] }

sub get_column_id { $_[0]->{column_id} }

sub set_root_column_id { $_[0]->{root_id}=$_[1] }

sub get_root_column_id { $_[0]->{root_id} }

sub is_child { defined($_[0]->{root_id}) }

sub insert_consolidator {
  my ($self,$consolidator)=@_;

  push @{$self->{consolidateors}},$consolidator;
  my $id=$#{$self->{consolidateors}};

  $consolidator->set_column_id($id);

  if($self->prepared) {
    croak "cannot insert empty consolidators!" unless $consolidator->has_next;
    $self->{raw_row}->[$id]=$consolidator->get_next;
  }

  return $id;
}

sub get_iterator_by_id {
  my ($self,$id)=@_;
  croak "id out of bounds" if !defined($id) or $id>$#{$_[0]->{consolidateors}} or $id<0;
  return $self->{consolidateors}->[$id];
}
sub get_column_count_human_readable { 1 + $_[0]->get_column_count}

sub get_column_count { $#{$_[0]->{consolidateors}} }

sub get_consolidateors { @{$_[0]->{consolidateors}} }

sub get_current_row { $_[0]->{current_row} } 

sub has_next { 0 }

sub iterators_empty { $_[0]->{iterators_empty} }

sub get_next { undef }

1;
