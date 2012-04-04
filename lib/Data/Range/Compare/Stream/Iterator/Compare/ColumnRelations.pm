package Data::Range::Compare::Stream::Iterator::Compare::ColumnRelations;

use strict;
use warnings;
use Carp qw(croak);

sub new {
  my ($class,$cmp)=@_;
  croak 'Compare object cannot be undef' unless defined($cmp);
  bless {map=>{},last_id=>-1,cmp=>$cmp,root_ids=>[]},$class;
}

sub get_last_id { $_[0]->{last_id} }

sub set_last_id { $_[0]->{last_id}=$_[1] }

sub get_compare { $_[0]->{cmp} }

sub get_root_ids { 
  my ($self)=@_;
  $self->build_map;
  [@{$self->{root_ids}}] 
}

sub build_map {
  my ($self)=@_;
  my $id=$self->get_last_id;
  my $max_id=$self->get_compare->get_column_count;

  return 1 if $id==$max_id;
  
  my $map=$self->{map};
  my $next_id=1 + $max_id;
  $id++ if $id<0;

  for(;$id<$next_id;++$id) {
    my $iterator=$self->get_compare->get_iterator_by_id($id);
    while($iterator->is_child) {
      $iterator=$iterator->get_root;
    }
    push @{$self->{root_ids}},$iterator->get_column_id unless exists $map->{$iterator->get_column_id};
    $map->{$id}=$iterator->get_column_id;

  }
  $self->set_last_id($max_id);

  return 1;
}

sub get_map {
  my ($self)=@_;
  $self->build_map;
  return {%{$self->{map}}};
}

sub get_root_results {
  my ($self,$obj)=@_;

  my $result={};

  $self->build_map;
  my $map=$self->{map};

  foreach my $id (@{$obj->get_overlap_ids}) {
    my $target=$map->{$id};
    $result->{$target}=[] unless exists $result->{$target};

    my $ref=$result->{$target};
    push @$ref,$obj->get_result_by_id($id);
  }

  return $result;
}

sub get_root_result_ids {
  my ($self,$obj)=@_;

  my $result={};

  $self->build_map;
  my $map=$self->{map};

  foreach my $id (@{$obj->get_overlap_ids}) {
    my $target=$map->{$id};
    $result->{$target}=[] unless exists $result->{$target};

    my $ref=$result->{$target};
    push @$ref,$id;
  }

  return $result;
}

1;
